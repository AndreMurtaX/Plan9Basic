r"""Synthesise the games' sound effects into Website/assets/sounds/<game>/.

Every effect here is a few oscillators and an envelope, built from nothing, and
running this again writes the same bytes, OGG files included (see
pin_ogg_serial). Demos/girder.bas says in its header that no
sound was sampled, and this file is what makes that checkable.

It began with Girder and took on the clips two older games had always asked
for and never had. Until 2026-10-17 snake.bas loaded die and start, and
space_invaders.bas loaded player_hit, game_over, wave_clear and march, from
URLs with nothing behind them: the games played on, silent at exactly the
moments a sound mattered most. The clips those games already had -- snake's
eat, the invaders' shoot and explode -- are not made here and are left alone.

Each effect is written twice, because a game asks for the format its platform
plays natively: WAV on Windows, OGG on Linux and Android.

Needs numpy and soundfile (whose bundled libsndfile encodes Vorbis):
    python -m pip install numpy soundfile
    python tools/make-game-sounds.py            # every game
    python tools/make-game-sounds.py snake      # one
"""
import os
import sys
import zlib

import numpy as np
import soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOUNDS = os.path.join(ROOT, 'Website', 'assets', 'sounds')
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


def lowpass(s, width):
    """A moving average: crude, but enough to turn hiss into a rumble."""
    return np.convolve(s, np.ones(width) / width, mode='same')


# --- Snake ---------------------------------------------------------------

def snake_start():
    # Short and bright: it plays on every restart, so it must not outstay it.
    return seq(*[note(hz(n), 0.07, vol=0.45) for n in ('G4', 'C5', 'E5')],
               note(hz('G5'), 0.22, vol=0.45) * decay(int(RATE * 0.22), 0.12))


def snake_die():
    secs = 0.7
    n = int(RATE * secs)
    buzz = square(sweep(420, 55, secs), secs, duty=0.3) * 0.45
    grit = lowpass(noise(secs, seed=11), 6) * 0.35
    return (buzz + grit) * env(n, release=0.12)


# --- Space Invaders ------------------------------------------------------

def inv_march():
    # One low knock per step of the formation. A single clip, re-triggered by
    # the game, so the tempo is the game's and speeds up with it.
    n = int(RATE * 0.11)
    body = np.sin(2 * np.pi * np.cumsum(sweep(95, 55, 0.11)) / RATE)
    click = square(190, 0.11) * decay(n, 0.006) * 0.3
    return (body + click) * decay(n, 0.035) * env(n, attack=0.001, release=0.02)


def inv_player_hit():
    secs = 0.6
    n = int(RATE * secs)
    boom = lowpass(noise(secs, seed=21), 10) * 1.6 * decay(n, 0.18)
    fall = square(sweep(300, 40, secs), secs, duty=0.5) * 0.3 * decay(n, 0.25)
    return (boom + fall) * env(n, attack=0.002, release=0.08)


def inv_game_over():
    # Four steps down by semitones, the last held and wavering.
    steps = [note(hz(p), 0.26, vol=0.45) for p in ('C4', 'B3', 'A#3')]
    secs = 0.9
    vib = 1.0 + 0.025 * np.sin(2 * np.pi * 6 * t_of(secs))
    last = square(hz('A3') * vib, secs) * env(int(RATE * secs), release=0.3) * 0.45
    out = []
    for s in steps:
        out += [s, rest(0.06)]
    return seq(*out, last)


def inv_wave_clear():
    run = [note(hz(p), 0.07, vol=0.4) for p in ('C5', 'E5', 'G5', 'C6', 'E6', 'G6')]
    secs = 0.8
    held = sum(note(hz(p), secs, wave=w, vol=0.3)
               for p, w in (('C5', triangle), ('E5', square), ('G5', triangle)))
    return seq(*run, rest(0.04), held * decay(int(RATE * secs), 0.5))


GAMES = {
    'girder': {
        'start': start, 'jump': jump, 'score': score, 'hammer': hammer,
        'smash': smash, 'throw': throw, 'die': die, 'clear': clear, 'over': over,
    },
    'snake': {
        'start': snake_start, 'die': snake_die,
    },
    'invaders': {
        'march': inv_march, 'player_hit': inv_player_hit,
        'game_over': inv_game_over, 'wave_clear': inv_wave_clear,
    },
}


def _ogg_crc_table():
    table = []
    for i in range(256):
        r = i << 24
        for _ in range(8):
            r = ((r << 1) ^ 0x04C11DB7) if r & 0x80000000 else (r << 1)
        table.append(r & 0xFFFFFFFF)
    return table


OGG_CRC = _ogg_crc_table()


def pin_ogg_serial(path, serial):
    """Give the file's one logical stream a fixed serial number.

    libvorbis picks the serial at random, so two encodes of identical samples
    differ in four bytes of every page header and in every page's checksum. On
    2026-10-17 a second run of this script changed all nine of Girder's OGG
    files while decoding to exactly the same audio. Pinned, a run that changes
    no sound changes no file.
    """
    data = bytearray(open(path, 'rb').read())
    pos = 0
    while pos < len(data):
        if data[pos:pos + 4] != b'OggS':
            raise ValueError(f'{path}: no Ogg page at byte {pos}')
        nseg = data[pos + 26]
        size = 27 + nseg + sum(data[pos + 27:pos + 27 + nseg])
        data[pos + 14:pos + 18] = serial.to_bytes(4, 'little')
        data[pos + 22:pos + 26] = b'\0\0\0\0'
        crc = 0
        for b in data[pos:pos + size]:
            crc = ((crc << 8) & 0xFFFFFFFF) ^ OGG_CRC[(crc >> 24) ^ b]
        data[pos + 22:pos + 26] = crc.to_bytes(4, 'little')
        pos += size
    open(path, 'wb').write(bytes(data))


def write_game(game):
    out_dir = os.path.join(SOUNDS, game)
    os.makedirs(out_dir, exist_ok=True)
    for name, make in GAMES[game].items():
        s = make()
        # Below full scale on purpose: Vorbis overshoots the peaks it is given,
        # and at a ceiling of 0.95 two of these came back from the encoder at
        # 1.01 and 1.03 -- clipped on every Linux and Android speaker.
        peak = np.max(np.abs(s))
        if peak > 0.85:
            s = s * (0.85 / peak)
        s = s.astype(np.float32)
        sf.write(os.path.join(out_dir, name + '.wav'), s, RATE, subtype='PCM_16')
        ogg = os.path.join(out_dir, name + '.ogg')
        sf.write(ogg, s, RATE, format='OGG', subtype='VORBIS')
        pin_ogg_serial(ogg, zlib.crc32(f'{game}/{name}'.encode()))
        print(f'{game:9s}{name:11s}{len(s) / RATE:5.2f} s')


def main():
    wanted = sys.argv[1:] or list(GAMES)
    for game in wanted:
        if game not in GAMES:
            sys.exit(f'no such game: {game} (known: {", ".join(GAMES)})')
        write_game(game)


if __name__ == '__main__':
    main()
