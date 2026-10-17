r"""Synthesise Girder's sound effects into Website/assets/sounds/girder/.

Demos/girder.bas says in its header that no sound was sampled, and this file is
what makes that checkable: every effect is a few oscillators and an envelope,
built here from nothing, and running it again writes the same bytes for the WAV
files. The OGG files are lossy encodes of the same samples.

Each effect is written twice, because the game asks for the format its
platform plays natively -- WAV on Windows, OGG on Linux and Android -- the same
split the other games with sound use.

Needs numpy and soundfile (whose bundled libsndfile encodes Vorbis):
    python -m pip install numpy soundfile
    python tools/make-girder-sounds.py
"""
import os

import numpy as np
import soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'Website', 'assets', 'sounds', 'girder')
RATE = 22050


def t_of(seconds):
    return np.arange(int(RATE * seconds)) / RATE


def square(freq, seconds, duty=0.5):
    """A square wave whose frequency may be a constant or a per-sample array."""
    n = int(RATE * seconds)
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,))
    phase = np.cumsum(f) / RATE
    return np.where(phase % 1.0 < duty, 1.0, -1.0)


def triangle(freq, seconds):
    n = int(RATE * seconds)
    f = np.broadcast_to(np.asarray(freq, dtype=float), (n,))
    phase = np.cumsum(f) / RATE
    return 4.0 * np.abs(phase % 1.0 - 0.5) - 1.0


def noise(seconds, seed):
    return np.random.default_rng(seed).uniform(-1.0, 1.0, int(RATE * seconds))


def env(n, attack=0.005, release=0.04):
    """Linear attack and release, so no note starts or stops with a click."""
    e = np.ones(n)
    a = min(n, int(RATE * attack))
    r = min(n - a, int(RATE * release))
    if a:
        e[:a] = np.linspace(0.0, 1.0, a)
    if r:
        e[n - r:] = np.linspace(1.0, 0.0, r)
    return e


def decay(n, seconds):
    return np.exp(-np.arange(n) / (RATE * seconds))


def note(freq, seconds, wave=square, vol=1.0):
    s = wave(freq, seconds)
    return s * env(len(s)) * vol


def seq(*parts):
    return np.concatenate(parts)


def rest(seconds):
    return np.zeros(int(RATE * seconds))


def sweep(f0, f1, seconds):
    return np.geomspace(f0, f1, int(RATE * seconds))


# Note frequencies, equal temperament from A4 = 440.
def hz(name):
    names = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2}
    semis = names[name[0]] + (1 if '#' in name else 0) + (int(name[-1]) - 4) * 12
    return 440.0 * 2 ** (semis / 12)


def start():
    # A rising four-note call, the curtain going up.
    return seq(*[note(hz(n), 0.11, vol=0.5) for n in ('C5', 'E5', 'G5')],
               note(hz('C6'), 0.28, vol=0.5) * decay(int(RATE * 0.28), 0.18))


def jump():
    s = square(sweep(320, 760, 0.16), 0.16, duty=0.25)
    return s * env(len(s), release=0.06) * 0.35


def score():
    return seq(note(hz('A5'), 0.05, vol=0.4), note(hz('E6'), 0.09, vol=0.4))


def hammer():
    # Quick climbing triangle arpeggio: picking something up that matters.
    return seq(*[note(hz(n), 0.055, wave=triangle, vol=0.8)
                 for n in ('C5', 'G5', 'C6', 'E6', 'G6', 'C7')])


def smash():
    n = int(RATE * 0.26)
    crack = noise(0.26, seed=7) * decay(n, 0.05)
    thump = np.sin(2 * np.pi * np.cumsum(sweep(180, 50, 0.26)) / RATE) * decay(n, 0.09)
    s = 0.55 * crack + 0.7 * thump
    return s * env(n, release=0.03)


def throw():
    n = int(RATE * 0.22)
    rumble = np.sin(2 * np.pi * np.cumsum(sweep(110, 60, 0.22)) / RATE)
    hiss = noise(0.22, seed=3) * 0.25
    return (rumble + hiss) * decay(n, 0.08) * env(n) * 0.6


def die():
    # A falling tone with a wobble on it, then two low knocks.
    secs = 0.85
    n = int(RATE * secs)
    wob = 1.0 + 0.06 * np.sin(2 * np.pi * 9 * t_of(secs))
    s = square(sweep(640, 90, secs) * wob, secs, duty=0.4) * env(n, release=0.1) * 0.4
    knock = note(70, 0.09, vol=0.6) * decay(int(RATE * 0.09), 0.03)
    return seq(s, rest(0.06), knock, rest(0.08), knock)


def clear():
    lead = seq(note(hz('G5'), 0.12, vol=0.45), note(hz('C6'), 0.12, vol=0.45),
               note(hz('E6'), 0.12, vol=0.45), note(hz('G6'), 0.24, vol=0.45),
               rest(0.04),
               note(hz('E6'), 0.12, vol=0.45), note(hz('G6'), 0.5, vol=0.45))
    bass = seq(note(hz('C4'), 0.48, wave=triangle, vol=0.5),
               note(hz('G3'), 0.28, wave=triangle, vol=0.5),
               note(hz('C4'), 0.5, wave=triangle, vol=0.5))
    n = max(len(lead), len(bass))
    return np.pad(lead, (0, n - len(lead))) + np.pad(bass, (0, n - len(bass)))


def over():
    return seq(note(hz('G4'), 0.3, vol=0.45), rest(0.05),
               note(hz('D#4'), 0.3, vol=0.45), rest(0.05),
               note(hz('C4'), 0.75, vol=0.45) * decay(int(RATE * 0.75), 0.45))


EFFECTS = {
    'start': start, 'jump': jump, 'score': score, 'hammer': hammer,
    'smash': smash, 'throw': throw, 'die': die, 'clear': clear, 'over': over,
}


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, make in EFFECTS.items():
        s = make()
        # Below full scale on purpose: Vorbis overshoots the peaks it is given,
        # and at a ceiling of 0.95 two of these came back from the encoder at
        # 1.01 and 1.03 -- clipped on every Linux and Android speaker.
        peak = np.max(np.abs(s))
        if peak > 0.85:
            s = s * (0.85 / peak)
        s = s.astype(np.float32)
        sf.write(os.path.join(OUT, name + '.wav'), s, RATE, subtype='PCM_16')
        sf.write(os.path.join(OUT, name + '.ogg'), s, RATE, format='OGG', subtype='VORBIS')
        print(f'{name:7s} {len(s) / RATE:5.2f} s')


if __name__ == '__main__':
    main()
