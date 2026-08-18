<#
.SYNOPSIS
  Builds and runs NoFmxProbe, which proves the engine links without FireMonkey.

.DESCRIPTION
  Compiles tests\NoFmxProbe.dpr with the FMX unit directories removed from the
  compiler's search path, so any reference to FireMonkey from the engine is a
  hard compile error rather than something that quietly resolves.

  This is the regression guard for the decoupling: if someone adds an FMX
  reference back into lexer, parser, exec, basic, UnitUtils, UnitGC or
  HandleRegistry, this build fails and the ordinary suites do not.
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

# The RTL only, with no FMX directory anywhere on the path. dcc64 reads its
# defaults from dcc64.cfg, so they are replaced rather than appended to.
$rtl = Join-Path $studio.Root 'lib\Win64\release'
$searchPath = $rtl

Push-Location $here
try {
    & $studio.Exe -B "-NU$dcuDir" "-E$binDir" "-U$searchPath" "-I$searchPath" `
        --no-config 'NoFmxProbe.dpr' 2>&1 |
        Where-Object { $_ -match 'Error|Fatal|Warning|lines,' }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "the engine still needs FireMonkey (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

$exe = Join-Path $binDir 'NoFmxProbe.exe'
Write-Host "built without FMX: $exe"

if (-not $Run) { exit 0 }

& $exe
exit $LASTEXITCODE
