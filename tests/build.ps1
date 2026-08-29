<#
.SYNOPSIS
  Builds (and optionally runs) the Plan9Basic headless test runner.

.DESCRIPTION
  Compiles tests\Plan9BasicTest.dpr with dcc64 into tests\bin. The Delphi
  command-line compiler is located through the Embarcadero BDS registry keys,
  so no RAD Studio environment setup is required.

.PARAMETER Run
  Run the suite after a successful build.

.PARAMETER Gui
  Register the FMX libraries too, so the suite can exercise forms and controls.
  Implies running tests\gui unless -Path says otherwise.

.PARAMETER Smoke
  Passed through to the runner: only require that files compile and run,
  without demanding assertions. Use with -Path to exercise Examples\ or Demos\.

.PARAMETER Path
  One or more .bas files or directories to run. Defaults to tests\suite.

.PARAMETER Bench
  Build and run tests\Plan9BasicBench.dpr over tests\bench instead of the test
  runner: how long the engine takes, rather than whether it is right. Implies
  -Run. The council in docs\ENGINE-COUNCIL-2026-08.md measured everything and
  committed nothing; this is the instrument that stops that happening again.

.PARAMETER Repeat
  Benchmark only: how many times to run each file, reporting the best.
  Default 3.

.PARAMETER Csv
  Benchmark only: append one row per benchmark to this file, to compare a
  change against the run before it.

.PARAMETER Dcc
  Full path to dcc64.exe, overriding registry detection.

.EXAMPLE
  .\build.ps1 -Run

.EXAMPLE
  .\build.ps1 -Run -Smoke -Path ..\Examples

.EXAMPLE
  .\build.ps1 -Bench

.EXAMPLE
  .\build.ps1 -Bench -Repeat 5 -Csv bench.csv
#>
[CmdletBinding()]
param(
    [switch] $Run,
    [switch] $Smoke,
    [switch] $Gui,
    [switch] $Verbose2,
    [switch] $Bench,
    [int]    $Repeat = 3,
    [string] $Csv,
    [string[]] $Path,
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
                }
            }
        }
    }
    $found = $roots | Where-Object { Test-Path $_.Exe } | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $found) { throw 'dcc64.exe not found. Install RAD Studio or pass -Dcc <path>.' }
    return $found.Exe
}

$dcc64 = Find-Dcc64
Write-Host "compiler: $dcc64"

$binDir = Join-Path $here 'bin'
$dcuDir = Join-Path $binDir 'dcu'
New-Item -ItemType Directory -Force $dcuDir | Out-Null

# The .dpr references project units by relative path, so the compiler has to run
# from the tests directory. Implicit units (TimerLib, pulled in by exec.pas) are
# resolved through the search path below.
$searchPath = '..;..\Libs;..\Libs\GUI;..\Libs\GUI\Effects;..\Libs\GUI\Animations;..\utils;' +
              '..\engine;..\engine\Libs;..\engine\Libs\GUI;..\engine\Libs\AI;..\engine\utils'

# The benchmark harness is a second program over the same engine sources. It
# registers no FMX library on purpose: a benchmark that needs a form is timing
# FireMonkey, not this engine.
$project = if ($Bench) { 'Plan9BasicBench.dpr' } else { 'Plan9BasicTest.dpr' }

Push-Location $here
try {
    & $dcc64 -B "-NU$dcuDir" "-E$binDir" "-U$searchPath" $project 2>&1 |
        Where-Object { $_ -match 'Error|Fatal|Warning|lines,' }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "build failed (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

$exe = Join-Path $binDir ([IO.Path]::ChangeExtension($project, '.exe'))
Write-Host "built: $exe"

if ($Bench) {
    $benchArgs = @('--repeat', $Repeat)
    if ($Csv)  { $benchArgs += @('--csv', $Csv) }
    if ($Path) { $benchArgs += $Path }
    Push-Location $here
    try { & $exe @benchArgs; $code = $LASTEXITCODE } finally { Pop-Location }
    exit $code
}

if (-not $Run) { exit 0 }

$runArgs = @()
if ($Smoke)    { $runArgs += '--smoke' }
if ($Gui)      { $runArgs += '--gui' }
if ($Verbose2) { $runArgs += '--verbose' }
if ($Path)     { $runArgs += $Path }
elseif ($Gui)  { $runArgs += 'gui' }

Push-Location $here
try {
    & $exe @runArgs
    $code = $LASTEXITCODE

    # With no explicit -Path the default run covers both suites: suite\ must
    # pass, negative\ must be rejected. Skipping the negative half would let a
    # guard silently stop guarding.
    if (-not $Path -and -not $Gui) {
        Write-Host ''
        & $exe --expect-fail 'negative'
        if ($LASTEXITCODE -ne 0) { $code = $LASTEXITCODE }
    }
} finally {
    Pop-Location
}
exit $code
