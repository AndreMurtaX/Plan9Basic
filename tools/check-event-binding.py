#!/usr/bin/env python3
r"""Every event setter, against the wiring its own name implies.

A control library turns a BASIC callback name into an FMX event:

    procedure TBasRectangle.SetOnClickFunc(const Value: String);
    begin
      ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
    end;

Four identifiers have to agree -- the procedure's event, the helper, the field
and the handler -- and nothing in Delphi makes them. `BindClick` with
`FOnDblClickFunc` compiles perfectly, and the result is a click that stores its
name in the wrong place and never fires. That is section 28's defect exactly,
one layer down: a callback the engine will never find, with no error anywhere.

Before 2026-08-19 these were 365 hand-written copies of the same five lines,
which is a different way of being wrong and was not wrong. The collapse is worth
having; the price is that a mis-wired call now looks like every other call, so
something has to read them.

The setters that are NOT a Bind call are listed below with the reason. Each is a
real one: an event that belongs to the concrete FMX class rather than TControl,
or a control that composes its FMX object instead of inheriting from it.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = ('.git', '__history', 'dist', 'Android64', 'Win64', 'Linux64', 'Win32',
        'OSX64', 'bin')

#The events TControl publishes, and so the ones ControlCommon can bind.
BINDABLE = {'Click', 'DblClick', 'MouseEnter', 'MouseLeave', 'Resize', 'Resized',
            'Enter', 'Exit', 'DragLeave', 'MouseDown', 'MouseUp', 'MouseMove',
            'MouseWheel', 'KeyDown', 'KeyUp', 'Paint', 'DragEnter', 'DragOver',
            'DragDrop'}

#onpaint is bound to two different FMX events, and this is a real difference
#rather than a formatting one.
#
#  TControl.OnPainting  fires before the control paints itself, and it still does
#  TShape.OnPaint       is where the shape's own drawing happens
#
#Seven libraries take the first and five take the second, and every one of the
#twelve is a TShape descendant that could take either. Which one a unit got was
#decided by which unit its author copied from -- the same accident that gave
#rectangle_align# and button_align# different meanings for the number 5.
#
#So `rectangle_onpaint#` hands a program the drawing and `arc_onpaint#` fires
#alongside the arc's own. Unifying them changes what existing applets see, so it
#is the author's call and not a repair. Listed here so it cannot spread while it
#waits: a new library binding onpaint has to join one of these two lists on
#purpose.
PAINTS_ITSELF = {
    'TBasCircle', 'TBasEllipse', 'TBasLayout', 'TBasRectangle', 'TBasForm',
}

#Classes that do not descend from TControl, so no helper applies.
NOT_A_CONTROL = {
    'TBasForm': 'a form is a TCommonCustomForm, not a TControl',
    'TBasTimer': 'a timer is a TComponent with no visual identity at all',
    'TBasMediaPlayer': 'the player is a TComponent; its control is separate',
    'TBasBitmapListAnimation': 'an animation is a TAnimation',
    'TBasColorAnimation': 'an animation is a TAnimation',
    'TBasFloatAnimation': 'an animation is a TAnimation',
    'TBasIntAnimation': 'an animation is a TAnimation',
    'TBasPathAnimation': 'an animation is a TAnimation',
    'TBasRectAnimation': 'composes its animation rather than inheriting, and '
                         'wires the FMX event once in the constructor',
}

PROC = re.compile(r'procedure\s+(T\w+)\.SetOn(\w+)Func\(const Value:\s*String\);\s*'
                  r'begin\s*(.*?)\s*end;', re.S)
BIND = re.compile(r'ControlCommon\.Bind(\w+)\(\s*Self\s*,\s*Value\s*,\s*'
                  r'FOn(\w+)Func\s*,\s*InternalOn(\w+)\s*\)\s*;')


def units():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if f.endswith('.pas'):
                yield os.path.join(base, f)


def main():
    bound = 0
    byhand = 0
    problems = []
    for path in units():
        rel = os.path.relpath(path, ROOT).replace(os.sep, '/')
        text = open(path, encoding='utf-8-sig', errors='replace').read()
        for cls, event, body in PROC.findall(text):
            m = BIND.search(body)
            if m:
                bound += 1
                helper, field, handler = m.groups()
                wrong = [(what, got) for what, got in
                         (('helper Bind', helper), ('field FOn', field),
                          ('handler InternalOn', handler))
                         if got != event]
                if wrong:
                    problems.append(
                        f'{rel}: {cls}.SetOn{event}Func binds with '
                        + ', '.join(f'{what}{got}' for what, got in wrong)
                        + f' - all four names have to say {event}')
                continue

            byhand += 1
            if cls in NOT_A_CONTROL:
                continue
            if event == 'Paint' and cls in PAINTS_ITSELF:
                continue          # binds TShape.OnPaint on purpose; see above
            if event not in BINDABLE:
                continue          # the event belongs to the concrete FMX class
            problems.append(f'{rel}: {cls}.SetOn{event}Func is written out by '
                            f'hand and On{event} is bindable; use '
                            f'ControlCommon.Bind{event}')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} event setter(s) that do not say what they mean.')
        print('A mis-wired binding compiles, and the event simply never fires.')
        return 1

    print(f'ok  {bound} setter(s) bound through ControlCommon, all four names '
          f'agreeing, and {byhand} written out for a stated reason '
          f'({len(PAINTS_ITSELF)} of them binding OnPaint rather than OnPainting)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
