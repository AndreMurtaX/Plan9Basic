#!/usr/bin/env python3
"""Run the shipped applets several at a time, each in its own directory.

WHY THIS EXISTS

The full suite cost about an hour, so it was not run before pushing, and on
2026-08-31 three documentation examples that do not compile reached main because
of it. The fix is not discipline. It is making the thing cheap enough that
running it is not a decision.

Measuring first, rather than guessing: of the 1096 seconds the Examples folder
took, five files were 942 of them -- 86 per cent -- and seventy-eight files
finished under 200 ms and came to 4 seconds between them. The runner is strictly
sequential, so those five held everything else behind them. Two are slow because
they fetch images across the network; the rest are effect tests doing real
rendering work, and that work is not waste, it just should not be done in
single file.

So the files are packed longest-first across several workers. The wall time
cannot go below the slowest single file, which is the honest floor here.

HOW MUCH FASTER, HONESTLY

Less certain than it looks. The effect tests are timed by the GPU finishing its
work, and the same file measured three ways on the same machine gave 333.8 s in
the sequential run, 236.5 s alone in a fresh process, and 100.6 s alone on a
worker while three other workers ran -- faster under contention than alone. A
spread of three to one is not noise to average out, it is a measurement that
does not mean what a stopwatch usually means.

Two things follow. The wall-clock figure this prints is worth reading as an
order of magnitude and nothing finer. And the cache below keeps the SMALLEST
time ever seen for a file rather than the most recent: contention and
accumulated state can only add, so the minimum is the closest thing available
to the cost of the file itself. It is a scheduling hint, not a measurement, and
it is used for nothing else.

EACH WORKER GETS ITS OWN DIRECTORY

The applets write scratch files -- fileA.txt, test_create.zip, subdir/fileB.txt
-- by plain relative name into the working directory. Sequentially that is
merely untidy: it is how b64_test_input.txt and two others came to be committed
in 6df7f38. Concurrently it is a correctness problem, because two applets would
write the same name at the same time. A temporary directory per worker settles
both, and leaves the repository clean afterwards.

    python tools/run-applets.py Examples Demos
    python tools/run-applets.py --workers 1 Examples     one at a time
    python tools/run-applets.py --list Examples          what would run, and its cost
"""
import concurrent.futures
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUNNER = os.path.join(ROOT, 'tests', 'bin', 'Plan9BasicTest.exe')
#tests/bin is ignored by git, so the cache cannot be committed by accident.
CACHE = os.path.join(ROOT, 'tests', 'bin', 'applet-times.json')

DEFAULT_WORKERS = 4

RESULT = re.compile(r'^\s*(PASS|FAIL|OUTPUT|ERROR)\s+(\S+)\s+.*?(\d+)\s*ms\s*$')
SUMMARY = re.compile(r'(\d+) file\(s\): (\d+) passed, (\d+) failed')


def load_times():
    try:
        with open(CACHE, encoding='utf-8') as f:
            return json.load(f)
    except (OSError, ValueError):
        return {}


def save_times(times):
    try:
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        with open(CACHE, 'w', encoding='utf-8') as f:
            json.dump(times, f, indent=1, sort_keys=True)
    except OSError:
        pass


def collect(folders):
    files = []
    for folder in folders:
        d = os.path.join(ROOT, *folder.split('/'))
        if not os.path.isdir(d):
            print(f'  no such folder: {folder}')
            continue
        for f in sorted(os.listdir(d)):
            if f.endswith('.bas'):
                files.append(os.path.join(d, f))
    return files


def pack(files, times, n):
    """Longest-first onto the lightest worker: the standard greedy schedule.

    A file never seen before is given the median cost, so a new applet is not
    assumed free and does not all pile onto one worker.
    """
    known = [times[os.path.basename(f)] for f in files
             if os.path.basename(f) in times]
    default = sorted(known)[len(known) // 2] if known else 1000
    cost = {f: times.get(os.path.basename(f), default) for f in files}

    shards = [[] for _ in range(n)]
    load = [0] * n
    for f in sorted(files, key=lambda f: -cost[f]):
        i = load.index(min(load))
        shards[i].append(f)
        load[i] += cost[f]
    return [s for s in shards if s], load, cost


def run_shard(paths):
    """One runner process, in a directory of its own."""
    work = tempfile.mkdtemp(prefix='p9b-applets-')
    try:
        res = subprocess.run([RUNNER, '--gui', '--smoke', *paths],
                             capture_output=True, text=True, cwd=work,
                             encoding='utf-8', errors='replace')
        return res.returncode, res.stdout or ''
    except OSError as e:
        return 1, f'could not run: {e}'
    finally:
        shutil.rmtree(work, ignore_errors=True)


def main():
    argv = sys.argv[1:]
    workers = DEFAULT_WORKERS
    if '--workers' in argv:
        i = argv.index('--workers')
        workers = max(1, int(argv[i + 1]))
        del argv[i:i + 2]
    listing = '--list' in argv
    folders = [a for a in argv if not a.startswith('--')]
    if not folders:
        print('usage: run-applets.py [--workers N] [--list] <folder> [folder...]')
        return 2
    if not os.path.exists(RUNNER):
        print(f'  the runner is not built: {os.path.relpath(RUNNER, ROOT)}')
        return 1

    files = collect(folders)
    if not files:
        print('  no applets found')
        return 1

    times = load_times()
    shards, load, cost = pack(files, times, workers)

    if listing:
        for i, s in enumerate(shards):
            print(f'  worker {i + 1}: {len(s)} file(s), {load[i] / 1000:.1f} s')
            for f in sorted(s, key=lambda f: -cost[f])[:4]:
                print(f'      {cost[f] / 1000:7.1f} s  {os.path.basename(f)}')
        print(f'\n  {len(files)} file(s), {sum(load) / 1000:.1f} s of work, '
              f'floor {max(cost.values()) / 1000:.1f} s (the slowest single file)')
        return 0

    started = time.time()
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(shards)) as ex:
        results = list(ex.map(run_shard, shards))
    wall = time.time() - started

    total = passed = failed = 0
    detail = []
    for code, out in results:
        lines = out.split('\n')
        for i, line in enumerate(lines):
            m = RESULT.match(line)
            if m:
                kind, name, ms = m.group(1), m.group(2), int(m.group(3))
                #Smallest ever seen: see the note on measurement in the header.
                times[name] = min(ms, times.get(name, ms))
                if kind != 'PASS':
                    detail.append(f'{kind:6} {name}')
                    #The runner explains itself on the lines that follow.
                    for extra in lines[i + 1:i + 4]:
                        if extra.strip().startswith(('!', '-')):
                            detail.append(f'         {extra.strip()}')
        m = SUMMARY.search(out)
        if m:
            total += int(m.group(1))
            passed += int(m.group(2))
            failed += int(m.group(3))
        elif code != 0:
            failed += 1
            detail.append(f'a worker produced no summary and exited {code}')

    save_times(times)

    for d in detail:
        print(f'  {d}')

    work = sum(load) / 1000
    print(f'{total} file(s): {passed} passed, {failed} failed | '
          f'{len(shards)} worker(s), {wall:.1f} s wall'
          + (f', {work:.0f} s of work packed' if work else ''))
    return 1 if failed or total != len(files) else 0


if __name__ == '__main__':
    sys.exit(main())
