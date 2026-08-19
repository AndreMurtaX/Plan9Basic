# Publishing the site

`plan9basic.com` is uploaded by hand, over FTP, to a hosting account. Nothing in
this repository performs that upload and nothing here holds a credential for it.

That gap is not a detail. On 2026-08-19, the published site was **111 files
behind** this tree: it still documented six HTTP functions that do not exist,
gave four string predicates their arguments the wrong way round, and opened its
dictionary section with a constructor that was never real. Every one of those
had been fixed a month earlier. Nothing said they had not shipped, because
nothing knew shipping was a step.

So this file is the step, written down.

## Before uploading anything

```powershell
.\tools\verify.ps1
```

Both applications build, both suites and the negative one run, the console host
runs, and nine documentation checks pass. If that is not green, the site is not
ready — publishing a page whose examples do not compile is worse than publishing
nothing, because a reader will type them in.

## Assemble the upload

```bash
python tools/package-site.py
```

This writes `dist/site/` and `dist/site.manifest.txt`. Pass `--zip` for a single
archive instead, if that suits the FTP client better.

What it collects:

- every file under `Website/` that git tracks — 284 of them, the ones review has
  seen
- every file the pages link to that git deliberately ignores, and that exists on
  this disk

The second category is currently two PDFs under `assets/ebooks/`, about 65 MB.
They are published, they are linked, and the repository has never contained
them. If a linked file of that kind is missing from this machine, the packager
**stops** rather than producing an upload with a broken link in it — that
condition is an error here instead of a discovery in somebody's browser.

## Upload

The contents of `dist/site/` become the server's document root — the directory
itself is not part of the path. `index.html` must land at the root, not inside a
`site/` folder.

`dist/` is gitignored, so nothing assembled here is ever committed.

## Afterwards

Check one page that changed, on the live site, not on disk. The failure this
whole file exists to prevent looked exactly like success from here.

## Where this is going

Publishing by hand is the reason the site could drift, and a written procedure
makes the drift less likely rather than impossible. The intended end state is
that the repository *is* the site: GitHub Pages serving `Website/` directly, so
publishing is a consequence of the push that already happens.

That waits on the repository being public, which is the last step of the project
(PLAN 3.5). It also needs a decision about the two ebooks: served from the
repository, they have to be *in* the repository. 65 MB is not a problem for git,
but it is a change from how they are handled now, so it is a choice rather than
an assumption.
