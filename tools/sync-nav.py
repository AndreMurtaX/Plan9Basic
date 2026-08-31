#!/usr/bin/env python3
"""One definition of the top navigation, written into every page that has one.

There is no template engine here, so each of the 121 pages carrying
`<nav class="topbar-nav">` holds its own copy of the markup. That is how the
site arrived at the state this file was written to fix:

  * 118 pages offered exactly three links -- Docs, Language, Libraries. Not one
    of them led to the downloads, so the binaries published on 2026-08-31 were
    reachable only from the home page, behind a button captioned "Building,
    running and platform notes".
  * docs/gui/scrollboxlib.html had lost its Libraries link entirely, and
    nothing noticed, because nothing compares one page's navigation to another's.

Copied markup drifts. The answer is not to hand-edit 121 files again but to keep
the navigation in one place -- here -- and let this write it out, with
--check holding the pages to it afterwards.

    python tools/sync-nav.py            rewrite every page's top navigation
    python tools/sync-nav.py --check    report pages that disagree with it

Pages whose navigation is genuinely their own are left alone: index.html has a
site-level nav of section anchors, and language-reference.html and examples.html
carry in-page contents rather than a top bar. They are listed in EXEMPT so that
"not touched" is a decision on the record rather than an accident of matching.
"""
import os
import re
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')

#The navigation, as site-root-relative targets. Order is the order shown.
#Adding a line here adds it to every page on the next run.
NAV = [
    ('index.html', '#docs', 'Docs'),
    ('docs/language-reference.html', '', 'Language'),
    ('docs/library_guide.html', '', 'Libraries'),
    ('docs/examples.html', '', 'Examples'),
    ('downloads.html', '', 'Download'),
]

#Pages that own their navigation and must not be rewritten.
EXEMPT = {'index.html'}

#The site grew two top bars. Most pages carry a full <nav class="topbar-nav">.
#The language reference and the examples page carry a breadcrumb instead, with
#a compact <div class="topbar-right"> holding a link or two and the theme
#button -- and those two were the only pages left with no way to the downloads
#once the 121 were done. They take the same list minus what the breadcrumb
#already shows.
NAV_BLOCK = re.compile(r'(<nav class="topbar-nav">)(.*?)(</nav>)', re.S)
RIGHT_BLOCK = re.compile(r'(<div class="topbar-right">)(.*?)(</div>)', re.S)
#The theme button lives inside the bar and is kept exactly as each page has it.
THEME = re.compile(r'<button\b[^>]*id="themeBtn".*?</button>', re.S)
#Entries the breadcrumb already provides, so the compact bar does not repeat them.
IN_BREADCRUMB = {'Docs'}


#Below this width the bar cannot hold a logo, five links, a theme button and a
#hamburger. It never could -- with three links it already wrapped over the logo
#and pushed the theme button out of the bar -- so this is not a consequence of
#adding two, only the point at which it stopped being ignorable.
#
#119 of the 121 pages have the sidebar drawer the hamburger already opens, and
#that is where the links belong on a phone. The two without one (downloads.html
#and library_guide.html) keep them in the bar and are told to wrap instead.
CSS_MARK = '/* sync-nav: the top bar on a phone */'
CSS_END = '/* end sync-nav */'

CSS_WITH_SIDEBAR = f"""{CSS_MARK}
.sidebar-site {{ display: none; }}
@media (max-width: 768px) {{
  .topbar-nav a {{ display: none; }}
  .sidebar-site {{ display: block; }}
}}
{CSS_END}"""

CSS_NO_SIDEBAR = f"""{CSS_MARK}
@media (max-width: 768px) {{
  .topbar {{ flex-wrap: wrap; }}
  .topbar-nav {{ flex-wrap: wrap; justify-content: flex-start; gap: 0.4rem 0.9rem; }}
}}
{CSS_END}"""

CSS_BLOCK = re.compile(re.escape(CSS_MARK) + r'.*?' + re.escape(CSS_END), re.S)

SITE_MARK = '<!-- sync-nav: site links, shown in the drawer on a phone -->'
SITE_END = '<!-- end sync-nav -->'
SITE_BLOCK = re.compile(re.escape(SITE_MARK) + r'.*?' + re.escape(SITE_END), re.S)
SIDEBAR_OPEN = re.compile(r'(<nav class="sidebar"[^>]*>)')


def pages():
    for base, dirs, files in os.walk(SITE):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in sorted(files):
            if f.endswith('.html'):
                full = os.path.join(base, f)
                yield os.path.relpath(full, SITE).replace(os.sep, '/')


def href_from(page_rel, target_rel):
    """Path from one page to another, as the browser will read it."""
    here = os.path.dirname(page_rel)
    rel = os.path.relpath(target_rel, here) if here else target_rel
    return rel.replace(os.sep, '/')


def build(page_rel, theme_button):
    lines = []
    for target, frag, label in NAV:
        if target == page_rel:
            #The page you are on: linked to itself and marked, which is what
            #downloads.html already did before this file existed.
            lines.append(f'    <a href="{os.path.basename(target)}{frag}" '
                         f'class="active">{label}</a>')
        else:
            lines.append(f'    <a href="{href_from(page_rel, target)}{frag}">'
                         f'{label}</a>')
    if theme_button:
        lines.append(f'    {theme_button}')
    return '\n' + '\n'.join(lines) + '\n  '


def build_compact(page_rel, theme_button):
    """The breadcrumb pages' right-hand bar: no self-link, no Docs."""
    lines = []
    for target, frag, label in NAV:
        if target == page_rel or label in IN_BREADCRUMB:
            continue
        lines.append(f'    <a href="{href_from(page_rel, target)}{frag}">'
                     f'{label}</a>')
    if theme_button:
        lines.append(f'    {theme_button}')
    return '\n' + '\n'.join(lines) + '\n  '


def build_drawer(page_rel):
    """The same links again, for the sidebar the hamburger opens on a phone."""
    lines = [SITE_MARK,
             '  <div class="sidebar-section sidebar-site">',
             '    <div class="sidebar-section-title">Plan9Basic</div>']
    for target, frag, label in NAV:
        if target == page_rel:
            continue
        lines.append(f'    <a href="{href_from(page_rel, target)}{frag}" '
                     f'class="sidebar-link">{label}</a>')
    lines.append('  </div>')
    lines.append('  ' + SITE_END)
    return '\n' + '\n'.join(lines)


def apply_extras(s, page_rel):
    """The mobile CSS, and the drawer copy of the links where there is a drawer."""
    has_sidebar = SIDEBAR_OPEN.search(s) is not None
    css = CSS_WITH_SIDEBAR if has_sidebar else CSS_NO_SIDEBAR

    if CSS_BLOCK.search(s):
        s = CSS_BLOCK.sub(lambda _: css, s, count=1)
    else:
        #Into the first style block, which every page on this site has.
        i = s.find('</style>')
        if i < 0:
            return s, False
        s = s[:i] + css + '\n' + s[i:]

    if has_sidebar:
        drawer = build_drawer(page_rel)
        if SITE_BLOCK.search(s):
            s = SITE_BLOCK.sub(lambda _: drawer.strip(), s, count=1)
        else:
            m = SIDEBAR_OPEN.search(s)
            s = s[:m.end()] + drawer + s[m.end():]
    return s, True


def main():
    check = '--check' in sys.argv
    changed, missing_nav, ok = [], [], 0

    for rel in pages():
        if rel in EXEMPT:
            continue
        p = os.path.join(SITE, rel.replace('/', os.sep))
        s = open(p, encoding='utf-8', errors='replace').read()
        m = NAV_BLOCK.search(s)
        shape = build
        if not m:
            m = RIGHT_BLOCK.search(s)
            shape = build_compact
        if not m:
            missing_nav.append(rel)
            continue

        theme = THEME.search(m.group(2))
        want = shape(rel, theme.group(0) if theme else '')
        after = s[:m.start(2)] + want + s[m.end(2):]
        after, _ = apply_extras(after, rel)

        if after == s:
            ok += 1
            continue

        changed.append(rel)
        if not check:
            with open(p, 'w', encoding='utf-8', newline='\n') as f:
                f.write(after)

    if check:
        for rel in changed:
            print(f'  {rel} does not carry the navigation in tools/sync-nav.py')
        if changed:
            print(f'\n{len(changed)} page(s) disagree with the one definition; '
                  f'run tools/sync-nav.py to write it out')
            return 1
        print(f'ok  {ok} page(s) carry the navigation defined here, '
              f'{len(EXEMPT)} own theirs, and {len(missing_nav)} have no top bar')
        return 0

    print(f'{len(changed)} page(s) rewritten, {ok} already right, '
          f'{len(missing_nav)} without a topbar nav')
    for rel in missing_nav:
        print(f'  own navigation: {rel}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
