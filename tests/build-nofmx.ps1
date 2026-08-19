<#
.SYNOPSIS
  Builds and runs NoFmxProbe: the engine core in a console host, no window.

.DESCRIPTION
  Compiles tests\NoFmxProbe.dpr and runs a BASIC program through it, with the
  host's PrintProc writing to stdout and its InputProc reading stdin. What that
  demonstrates is that the interpreter runs with no windowing system driving it
  -- INPUT included, which used to be hardwired to an FMX dialog.

  It also proves the engine links without FireMonkey, which it claimed for
  months without doing. The old proof was the search path: the RTL with no FMX
  directory on it. That excluded nothing, because dcc64 keeps the compiled FMX
  .dcu files in lib\Win64\release beside the RTL's own, and the probe linked 58
  of them while reporting success.

  The proof now is the linker's own answer. -GD writes a map naming every unit
  that made it in, and a single FMX line fails the run. As of 2026-08-19 there
  are none, StdLib and StrLib having moved to HostServices.

  tools\check-fmx-boundary.py asks the same question of the source, so a new
  import is named before it can be linked.
#>
[CmdletBinding()]
param(
    [switch] $Run,
    [string] $Dcc
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Find-Dcc64 {
    if ($Dcc) {
        if (-not (Test-Path $Dcc)) { throw "dcc64 not found at $Dcc" }
        return $Dcc
    }
    $roots = @()
    foreach ($hive in @('HKLM:\SOFTWARE\Embarcadero\BDS', 'HKCU:\SOFTWARE\Embarcadero\BDS')) {
        if (-not (Test-Path $hive)) { continue }
        foreach ($key in Get-ChildItem $hive) {
            $rootDir = (Get-ItemProperty $key.PSPath -ErrorAction SilentlyContinue).RootDir
            if ($rootDir) {
                $roots += [pscustomobject]@{
                    Version = [double] $key.PSChildName
                    Exe     = Join-Path $rootDir 'bin\dcc64.exe'
                    Root    = $rootDir
                }
            }
        }
    }
    $found = $roots | Where-Object { Test-Path $_.Exe } | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $found) { throw 'dcc64.exe not found. Install RAD Studio or pass -Dcc <path>.' }
    return $found
}

$studio = Find-Dcc64
Write-Host "compiler: $($studio.Exe)"

$binDir = Join-Path $here 'bin'
$dcuDir = Join-Path $binDir 'nofmx'
New-Item -ItemType Directory -Force $dcuDir | Out-Null

# The RTL. This does not exclude FMX -- the FMX .dcu files live here too --
# see tools/check-fmx-boundary.py for the check that does. dcc64 reads its
# defaults from dcc64.cfg, so they are replaced rather than appended to.
$rtl = Join-Path $studio.Root 'lib\Win64\release'
$searchPath = $rtl

Push-Location $here
try {
    # -GD writes a detailed map naming every unit that was linked, which is
    # how the claim below is checked rather than asserted.
    & $studio.Exe -B "-NU$dcuDir" "-E$binDir" "-U$searchPath" "-I$searchPath" -GD `
        --no-config 'NoFmxProbe.dpr' 2>&1 |
        Where-Object { $_ -match 'Error|Fatal|Warning|lines,' }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "the engine no longer builds into a console host (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

# The real check, and the one this script got wrong for months. Excluding the
# FMX *source* directories proves nothing, because dcc64 keeps the compiled
# .dcu files beside the RTL's own -- so ask the linker what it actually took.
$map = Join-Path $binDir 'NoFmxProbe.map'
if (Test-Path $map) {
    $fmx = Select-String -Path $map -Pattern '\bFMX\.\w+' -AllMatches |
           ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } |
           Sort-Object -Unique
    if ($fmx.Count -gt 0) {
        Write-Host ''
        Write-Host "$($fmx.Count) FireMonkey unit(s) linked into the console host:"
        $fmx | Select-Object -First 12 | ForEach-Object { Write-Host "  $_" }
        Write-Error 'the engine reached FireMonkey; tools/check-fmx-boundary.py names which unit'
        exit 1
    }
    Write-Host 'no FireMonkey unit linked'
}

$exe = Join-Path $binDir 'NoFmxProbe.exe'
Write-Host "console host built: $exe"

if (-not $Run) { exit 0 }

& $exe
exit $LASTEXITCODE
