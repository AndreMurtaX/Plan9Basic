<#
.SYNOPSIS
  Builds and runs NoFmxProbe: the engine core in a console host, no window.

.DESCRIPTION
  Compiles tests\NoFmxProbe.dpr and runs a BASIC program through it, with the
  host's PrintProc writing to stdout and its InputProc reading stdin. What that
  demonstrates is that the interpreter runs with no windowing system driving it
  -- INPUT included, which used to be hardwired to an FMX dialog.

  It does NOT prove the engine links without FireMonkey, though it used to say
  so. The search path here was described as the RTL with no FMX directory on
  it, but dcc64 keeps the FMX .dcu files in lib\Win64\release beside the RTL's
  own, so removing the FMX *source* directories excluded nothing: this probe
  links 58 FMX units. The unit-level boundary is checked for real, by reading
  the uses clauses, in tools\check-fmx-boundary.py.
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
    & $studio.Exe -B "-NU$dcuDir" "-E$binDir" "-U$searchPath" "-I$searchPath" `
        --no-config 'NoFmxProbe.dpr' 2>&1 |
        Where-Object { $_ -match 'Error|Fatal|Warning|lines,' }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "the engine no longer builds into a console host (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

$exe = Join-Path $binDir 'NoFmxProbe.exe'
Write-Host "console host built: $exe"

if (-not $Run) { exit 0 }

& $exe
exit $LASTEXITCODE
