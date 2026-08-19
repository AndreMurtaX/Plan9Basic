<#
.SYNOPSIS
  Builds every target and runs every check. One command, one verdict.

.DESCRIPTION
  There used to be no single answer to "does this work". The suites were two
  invocations of tests\build.ps1 with different switches, the console-host probe
  was a third script, the documentation checks were a Python entry point that
  assumed someone had already built the test runner, and nothing at all built
  the two applications -- so the IDE and the applet runner could stop compiling
  and every check would still pass.

  This runs all of it, in the order that fails cheapest first, and prints one
  table at the end. A failing step does not stop the run: knowing that three
  things broke is worth more than knowing the first one did.

.PARAMETER Quick
  Skip the two application builds, which are most of the wall clock and the
  least likely to be what you just changed.

.PARAMETER Dcc
  Full path to dcc64.exe, overriding registry detection.

.EXAMPLE
  .\tools\verify.ps1
#>
[CmdletBinding()]
param(
    [switch] $Quick,
    [string] $Dcc
)

$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot

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

$results = @()

function Step {
    param([string] $Label, [scriptblock] $Body)
    Write-Host "--- $Label" -ForegroundColor DarkGray
    $detail = ''
    try {
        $detail = & $Body
        $ok = $?
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) { $ok = $false }
    } catch {
        $ok = $false
        $detail = $_.Exception.Message
    }
    # Some steps report more than one line worth keeping -- the suite prints its
    # own totals and the negative suite's -- so keep up to three, joined.
    $lines = @($detail | Where-Object { $_ } | Select-Object -Last 3)
    $script:results += [pscustomobject]@{
        Label = $Label; Ok = $ok; Detail = ($lines -join '  |  ')
    }
    $global:LASTEXITCODE = 0
}

# An application that does not compile is the cheapest thing to discover, and
# the only failure the suites cannot see: they link the units directly.
if (-not $Quick) {
    $dcc = Find-Dcc64
    Write-Host "compiler: $dcc"
    foreach ($app in @(
        @{ Label = 'IDE builds';    Dir = $root;                       Proj = 'Plan9Basic.dpr' },
        @{ Label = 'runner builds'; Dir = (Join-Path $root 'runner');  Proj = 'Plan9BasicApplet.dpr' })) {
        Step $app.Label {
            $out = Join-Path $app.Dir '__verify'
            New-Item -ItemType Directory -Force (Join-Path $out 'dcu') | Out-Null
            Push-Location $app.Dir
            try {
                $log = & $dcc -B "-E$out" "-N$(Join-Path $out 'dcu')" $app.Proj 2>&1
                $log | Select-String 'lines,|Fatal|error E' | ForEach-Object { $_.Line.Trim() }
            } finally {
                Pop-Location
                Remove-Item -Recurse -Force $out -ErrorAction SilentlyContinue
            }
        }
    }
}

$tests = Join-Path $root 'tests'

Step 'suite' {
    (& (Join-Path $tests 'build.ps1') -Run 2>&1 | Out-String) -split "`n" |
        Select-String 'file\(s\):' | ForEach-Object { $_.Line.Trim() }
}

Step 'gui suite' {
    (& (Join-Path $tests 'build.ps1') -Run -Gui 2>&1 | Out-String) -split "`n" |
        Select-String 'file\(s\):' | ForEach-Object { $_.Line.Trim() }
}

Step 'console host' {
    (& (Join-Path $tests 'build-nofmx.ps1') -Run 2>&1 | Out-String) -split "`n" |
        Select-String 'OK -|Fatal|Error' | ForEach-Object { $_.Line.Trim() }
}

Step 'vm thread' {
    # Compiled here rather than by a script of its own, because it is one file
    # and the interesting part is running it under a timeout: the failure this
    # probe guards against is a deadlock, and a deadlocked test does not fail,
    # it waits.
    $probeDir = Join-Path $tests 'bin'
    New-Item -ItemType Directory -Force (Join-Path $probeDir 'vmthread') | Out-Null
    Push-Location $tests
    try {
        $dcc2 = Find-Dcc64
        $log = & $dcc2 -B "-NU$(Join-Path $probeDir 'vmthread')" "-E$probeDir" `
                       'VMThreadProbe.dpr' 2>&1
        # The colon matters: a hint naming PrintSyntaxError contains 'Error'
        # and is not one. Compiler diagnostics carry 'Error:' or 'Fatal:'.
        $bad = $log | Select-String 'Error:|Fatal:'
        if ($bad) { $bad | ForEach-Object { $_.Line.Trim() }; return }

        $out = Join-Path $probeDir 'vmthread.out'
        $proc = Start-Process -FilePath (Join-Path $probeDir 'VMThreadProbe.exe') `
                    -NoNewWindow -PassThru -RedirectStandardOutput $out `
                    -RedirectStandardError (Join-Path $probeDir 'vmthread.err')
        if (-not $proc.WaitForExit(60000)) {
            $proc.Kill()
            'the probe did not finish in 60s -- the handover deadlocked'
            $global:LASTEXITCODE = 1
            return
        }
        $global:LASTEXITCODE = $proc.ExitCode
        Get-Content $out | Where-Object { $_ -match 'OK -|FAIL|failed' } |
            ForEach-Object { $_.Trim() }
    } finally {
        Pop-Location
    }
}

Step 'IDE self-test' {
    # The IDE loads a program, runs it, and checks its own console. It is the
    # application on the download page and the larger of the two hosts, and
    # until this landed nothing exercised it at all.
    $exe = Join-Path $root 'bin\Plan9Basic.exe'
    $out = Join-Path $root 'bin\ide-selftest.out'
    Remove-Item $out -ErrorAction SilentlyContinue

    New-Item -ItemType Directory -Force (Join-Path $root 'bin\dcu') | Out-Null
    Push-Location $root
    try {
        $log = & (Find-Dcc64) '-E.\bin' '-N.\bin\dcu' 'Plan9Basic.dpr' 2>&1
        # The colon matters: a hint naming PrintSyntaxError contains 'Error'
        # and is not one. Compiler diagnostics carry 'Error:' or 'Fatal:'.
        $bad = $log | Select-String 'Error:|Fatal:'
        if ($bad) { $bad | ForEach-Object { $_.Line.Trim() }; $global:LASTEXITCODE = 1; return }
    } finally {
        Pop-Location
    }

    $proc = Start-Process -FilePath $exe -ArgumentList '--selftest' -PassThru -WindowStyle Minimized
    if (-not $proc.WaitForExit(90000)) {
        $proc.Kill()
        'the IDE did not finish in 90s -- its interface is wedged'
        $global:LASTEXITCODE = 1
        return
    }
    $global:LASTEXITCODE = $proc.ExitCode
    if (Test-Path $out) { (Get-Content $out | Select-Object -First 1).Trim() }
}

Step 'applet self-test' {
    # The applet presses its own Run, answers its own dialogs and reports. This
    # covers what VMThreadProbe cannot: the host's own threading -- the worker's
    # lifetime, the output drain timer, the marshaller, and the teardown.
    #
    # The outer kill is not belt-and-braces. A deadlocked UI thread cannot run
    # the applet's own timeout either, so the only thing that can call it is a
    # process that is not the applet.
    $runner = Join-Path $root 'runner'
    $exe = Join-Path $runner 'bin\Plan9BasicApplet.exe'
    $out = Join-Path $runner 'bin\selftest.out'
    Remove-Item $out -ErrorAction SilentlyContinue

    New-Item -ItemType Directory -Force (Join-Path $runner 'bin\dcu') | Out-Null
    Push-Location $runner
    try {
        $log = & (Find-Dcc64) '-E.\bin' '-N.\bin\dcu' 'Plan9BasicApplet.dpr' 2>&1
        # The colon matters: a hint naming PrintSyntaxError contains 'Error'
        # and is not one. Compiler diagnostics carry 'Error:' or 'Fatal:'.
        $bad = $log | Select-String 'Error:|Fatal:'
        if ($bad) { $bad | ForEach-Object { $_.Line.Trim() }; $global:LASTEXITCODE = 1; return }
    } finally {
        Pop-Location
    }

    $proc = Start-Process -FilePath $exe -ArgumentList '--selftest' -PassThru -WindowStyle Minimized
    if (-not $proc.WaitForExit(90000)) {
        $proc.Kill()
        'the applet did not finish in 90s -- its interface is wedged'
        $global:LASTEXITCODE = 1
        return
    }
    $global:LASTEXITCODE = $proc.ExitCode
    if (Test-Path $out) { (Get-Content $out | Select-Object -First 1).Trim() }
}

Step 'documentation' {
    $args = @((Join-Path $root 'tools\check-all.py'))
    if ($Quick) { $args += '--quick' }
    (& python @args 2>&1 | Out-String) -split "`n" |
        Select-String 'check\(s\) (passed|failed)' | ForEach-Object { $_.Line.Trim() }
}

Write-Host ''
$width = ($results | ForEach-Object { $_.Label.Length } | Measure-Object -Maximum).Maximum
foreach ($r in $results) {
    $mark = if ($r.Ok) { 'ok  ' } else { 'FAIL' }
    $colour = if ($r.Ok) { 'Green' } else { 'Red' }
    Write-Host ("  {0}  {1}  {2}" -f $mark, $r.Label.PadRight($width), $r.Detail) -ForegroundColor $colour
}

$bad = @($results | Where-Object { -not $_.Ok })
Write-Host ''
if ($bad.Count) {
    Write-Host "$($bad.Count) step(s) failed: $(($bad | ForEach-Object { $_.Label }) -join ', ')"
    Write-Host 'run that step on its own for the detail'
    exit 1
}
$note = if ($Quick) { '  (--quick: the application builds were skipped)' } else { '' }
Write-Host "$($results.Count) step(s) passed$note"
exit 0
