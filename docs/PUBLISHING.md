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

## The site is part of the product, not a brochure

Before anything else about uploading: **the running software fetches from this
host.** Not only documentation lives here.

| Path | Fetched by |
|---|---|
| `assets/devenv/Translations.ini` | the IDE, on the first run of every install |
| `assets/examples/ExamplesBrowser.bas` | the IDE, on first run |
| `api/examples.php` | the Examples Browser applet |
| `assets/sounds/{lunar,missile,snake,invaders}/` | four of the demo games |

Those URLs are written in Pascal and BASIC source, not in an `href`, so
`check-links.py` cannot see them — it reads pages. `tools/check-site-deps.py`
asks the question it cannot, and `check-all.py` runs it.

**`api/examples.php` is not in this repository.** It is PHP on the host and its
source has never been here, so **an upload must merge rather than replace.**
Wiping the document root and copying `Website/` over it removes that endpoint
and breaks the Examples Browser for everyone.

## Upload

**`Website/` is the site.** Its contents are the server's document root — the
directory itself is not part of the path, so `index.html` lands at the root and
not inside a `Website/` folder.

There is nothing to assemble and nothing to leave out. Everything under it is
published: 287 files, of which 124 are pages.

`assets/devenv/` used to hold 63 MB of compiled binaries the download buttons
pointed at. Nothing has linked them since 4.4, so they moved to `dist/devenv/`,
outside the upload — **except `Translations.ini`, which stayed.** It is not
linked by any page either, which is exactly why moving the directory wholesale
looked safe and was not: the IDE fetches it on first run, and publishing without
it would have 404ed every fresh installation, silently. The `.gitignore` rule
now excludes that directory's *contents* with one exception, so the file is
tracked and a clone can publish a working site.

Two of the 286 are not in git: the PDFs under `assets/ebooks/`, about 65 MB.
They are linked from the story on the front page, they are published, and the
repository has never contained them. A fresh clone therefore cannot produce a
complete upload — which is one of the things 4.6 has to settle.

## Assemble a copy, if you want one

```bash
python tools/package-site.py
```

Not required, since `Website/` is already the tree. What it adds is a copy with
a manifest of sizes and checksums — useful for confirming an upload arrived
intact — and a check that every linked file which git ignores is actually on
this disk. If one is missing it **stops**, rather than producing an upload with
a broken link in it. `--zip` makes an archive instead, for clients that prefer
one transfer.

It writes into `dist/`, which is gitignored.

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
