#!/usr/bin/env python3
r"""The catalogue of examples, against the files it lists.

The Examples Browser applet asks the site for a catalogue and shows it in a
grid. Until now that catalogue was `api/examples.php`, generated from a database
on the host: 97 records with a name, a description and a category each, and not
one of them in this repository. The applet fetched it with `http_post$`.

Neither half of that survives GitHub Pages, which serves static files over GET.
So the catalogue is a file here now -- `Website/api/examples.json`, the same
envelope and the same fields the endpoint served, byte-shape unchanged so the
applet's parsing did not have to move -- and the applet asks by GET.

Which trades one failure for another. A database at least could not list a file
that the web server did not have; two directories in one repository can drift
apart quietly, and this month has already spent a day on a site handing out
programs the repository had fixed. So the two are checked against each other.

    python tools/check-examples-catalog.py          check
    python tools/check-examples-catalog.py --fix    write the catalogue back

`--fix` adds a record for a file that has none and drops one whose file is gone.
It cannot write a description, so a new entry gets an empty one and this check
keeps failing until a person writes it: the catalogue is what a reader reads,
and a blank line in it is worse than an absent one.
"""
import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')
CATALOGUE = os.path.join(SITE, 'api', 'examples.json')
FOLDER = os.path.join(SITE, 'assets', 'examples')
BASE = 'https://plan9basic.com/assets/examples/'

#The browser is not one of the examples it browses.
NOT_AN_EXAMPLE = {'ExamplesBrowser.bas'}

#What the applet reads out of each record. Anything else is the site's own.
NEEDED = ('name', 'filename', 'description', 'download_path', 'category')


def on_disk():
    if not os.path.isdir(FOLDER):
        return set()
    return {f for f in os.listdir(FOLDER)
            if f.endswith('.bas') and f not in NOT_AN_EXAMPLE}


def load():
    with open(CATALOGUE, encoding='utf-8') as f:
        return json.load(f)


def save(cat):
    with open(CATALOGUE, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(cat, f, ensure_ascii=False, indent=2)
        f.write('\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--fix', action='store_true')
    opts = ap.parse_args()

    if not os.path.isfile(CATALOGUE):
        print(f'  the catalogue is missing: {CATALOGUE}')
        return 1

    try:
        cat = load()
    except ValueError as e:
        print(f'  the catalogue is not valid JSON: {e}')
        return 1

    problems = []
    if cat.get('status') != 'ok':
        problems.append("the envelope's status is not 'ok', and the applet "
                        'refuses anything else')
    records = cat.get('data')
    if not isinstance(records, list):
        print("  the envelope has no 'data' array")
        return 1

    disk = on_disk()
    listed = {}
    for i, r in enumerate(records):
        missing = [k for k in NEEDED if k not in r]
        if missing:
            problems.append(f'record {i} has no ' + ', '.join(missing))
            continue
        name = r['filename']
        if name in listed:
            problems.append(f'{name} is listed twice')
        listed[name] = r
        if not r['description'].strip():
            problems.append(f'{name} has no description, and the catalogue is '
                            f'what a reader reads')
        want = BASE + name
        if r['download_path'] != want:
            problems.append(f'{name} downloads from {r["download_path"]}, '
                            f'and the file is at {want}')

    gone = sorted(set(listed) - disk)
    new = sorted(disk - set(listed))

    if opts.fix and (gone or new):
        records = [r for r in records if r.get('filename') not in gone]
        top = max([r.get('id', 0) for r in records] or [0])
        order = max([r.get('sort_order', 0) for r in records] or [0])
        for k, name in enumerate(new, 1):
            records.append({
                'id': top + k,
                'name': os.path.splitext(name)[0].replace('_', ' ').title(),
                'filename': name,
                'description': '',
                'download_path': BASE + name,
                'category': 'Uncategorised',
                'level': 1,
                'tags': '',
                'featured': 0,
                'sort_order': order + 10 * k,
            })
        cat['data'] = records
        save(cat)
        print(f'  wrote the catalogue: {len(new)} added, {len(gone)} dropped')
        print('  a new record has no description; write one, then run this again')
        return 1

    for name in gone:
        problems.append(f'{name} is in the catalogue and not in '
                        f'Website/assets/examples/')
    for name in new:
        problems.append(f'{name} is in Website/assets/examples/ and not in the '
                        f'catalogue, so nobody browsing can reach it')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s). Run with --fix for the two this '
              f'can settle by itself.')
        return 1

    print(f'ok  {len(listed)} example(s) in the catalogue, every one a file, '
          f'and every file listed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
