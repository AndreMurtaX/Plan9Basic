r"""Synthesise the games' sound effects into Website/assets/sounds/<game>/.

Every effect here is a few oscillators and an envelope, built from nothing, and
running this again writes the same bytes, OGG files included (see
pin_ogg_serial). Demos/girder.bas says in its header that no
sound was sampled, and this file is what makes that checkable.

It began with Girder and took on the clips two older games had always asked
for and never had. Until 2026-10-17 snake.bas loaded die and start, and
space_invaders.bas loaded player_hit, game_over, wave_clear and march, from
URLs with nothing behind them: the games played on, silent at exactly the
moments a sound mattered most. The invaders' shoot and explode, which were
there, were remade here too: they had been mastered to full scale, and the
Vorbis encode of each came back peaking at 1.17 and 1.23, clipped on Linux and
Android. Lunar Lander's thrust and crash were remade for the same reason (1.13
and 1.15), and thrust for a second one: it was 143 s, 12.6 MB of WAV that every
Windows player downloaded on each start, for a clip the game never needs past
20 s. Snake's eat and Lunar's land, lowfuel and start are the clips on the site
this does not make (though it writes eat's MP3, see TRANSCODE), and so are
all of Missile Command's (MP3s likewise).

Each effect is written three times, because a game asks for the format its
platform plays natively: WAV on Windows, OGG on Linux and Android, MP3 anywhere
else (macOS and iOS). Until 2026-10-17 only Lunar Lander's directory had MP3s;
Snake and Space Invaders asked for them and found none.

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

def inv_shoot():
    # A falling zap: thin pulse wave swept down, gone in a third of a second.
    secs = 0.3
    n = int(RATE * secs)
    zap = square(sweep(1500, 260, secs), secs, duty=0.2)
    return zap * decay(n, 0.11) * env(n, attack=0.002, release=0.05) * 0.5


def inv_explode():
    # A crunch rather than a boom: plays for every alien hit, so it stays
    # bright and short, and two of them overlap through the game's pool of three.
    secs = 0.3
    n = int(RATE * secs)
    crunch = lowpass(noise(secs, seed=31), 2) * decay(n, 0.07)
    body = square(sweep(240, 70, secs), secs, duty=0.5) * 0.35 * decay(n, 0.1)
    return (crunch + body) * env(n, attack=0.001, release=0.04)


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


# --- Lunar Lander --------------------------------------------------------

def loop_seam(s, fade):
    """Fold the last `fade` samples over the first, so the clip loops without a seam."""
    head, body, tail = s[:fade], s[fade:-fade], s[-fade:]
    ramp = np.linspace(0.0, 1.0, fade)
    return np.concatenate([head * ramp + tail * (1 - ramp), body])


def lunar_thrust():
    # 24 seconds because the longest burn the game allows is about 20: a full
    # tank at level 1 is 145 units at 0.2 a frame, 725 frames, and the loop runs
    # nearer 37 frames a second than the 62 its timer asks for. So a burn never
    # reaches the end, and never meets the gap of up to 100 ms that a restart
    # from OnThrustEnd costs (the media player polls for the end every 100 ms).
    # The file it replaces did the same job by being 143 s and 12.6 MB.
    secs = 24.0
    fade = int(RATE * 0.5)
    total = secs + 0.5
    n = int(RATE * total)
    roar = lowpass(noise(total, seed=41), 14) * 2.2
    hiss = lowpass(noise(total, seed=42), 2) * 0.12
    flutter = 1.0 + 0.12 * np.sin(2 * np.pi * 7.5 * t_of(total)) \
                  + 0.06 * np.sin(2 * np.pi * 2.3 * t_of(total))
    s = loop_seam((roar + hiss) * flutter, fade)
    # A few milliseconds at each end so a stop or a restart does not click.
    return s * env(len(s), attack=0.004, release=0.004)


def lunar_crash():
    secs = 2.0
    n = int(RATE * secs)
    blast = lowpass(noise(secs, seed=51), 3) * decay(n, 0.12)
    rumble = lowpass(noise(secs, seed=52), 24) * 3.0 * decay(n, 0.6)
    thud = np.sin(2 * np.pi * np.cumsum(sweep(120, 35, secs)) / RATE) * 0.8 * decay(n, 0.25)
    # Debris: a few late crackles, at fixed places so the file is reproducible.
    debris = np.zeros(n)
    for at, seed in ((0.35, 61), (0.55, 62), (0.8, 63), (1.1, 64)):
        i = int(RATE * at)
        k = int(RATE * 0.05)
        debris[i:i + k] += noise(0.05, seed=seed)[:len(debris[i:i + k])] * decay(k, 0.012) * 0.5
    return (blast + rumble + thud + debris) * env(n, attack=0.002, release=0.3)


GAMES = {
    'girder': {
        'start': start, 'jump': jump, 'score': score, 'hammer': hammer,
        'smash': smash, 'throw': throw, 'die': die, 'clear': clear, 'over': over,
    },
    'snake': {
        'start': snake_start, 'die': snake_die,
    },
    'invaders': {
        'shoot': inv_shoot, 'explode': inv_explode,
        'march': inv_march, 'player_hit': inv_player_hit,
        'game_over': inv_game_over, 'wave_clear': inv_wave_clear,
    },
    'lunar': {
        'thrust': lunar_thrust, 'crash': lunar_crash,
    },
}

# Clips on the site that this script does not synthesise, but whose MP3 it
# writes from the WAV already there, so that every clip a game asks for exists
# in every format it asks for. Snake's eat is older than this script and keeps
# its sound; it had a WAV and an OGG and no MP3. Missile Command's six are the
# same story, and two of them are stereo at 44.1 kHz, which encode() keeps.
TRANSCODE = {
    'snake': ('eat',),
    'missile': ('city_hit', 'explode', 'game_over', 'launch', 'wave_clear', 'wave_start'),
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
    for name, make in GAMES.get(game, {}).items():
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
        encode(ogg, s, 'OGG', 'VORBIS')
        pin_ogg_serial(ogg, zlib.crc32(f'{game}/{name}'.encode()))
        encode(os.path.join(out_dir, name + '.mp3'), s, 'MP3', 'MPEG_LAYER_III')
        print(f'{game:9s}{name:11s}{len(s) / RATE:5.2f} s')
    for name in TRANSCODE.get(game, ()):
        s, rate = sf.read(os.path.join(out_dir, name + '.wav'), dtype='float32')
        encode(os.path.join(out_dir, name + '.mp3'), s, 'MP3', 'MPEG_LAYER_III', rate)
        print(f'{game:9s}{name:11s}{len(s) / rate:5.2f} s  (MP3 from the WAV)')


LONG_SECONDS = 4


def encode(path, s, fmt, subtype, rate=RATE):
    """Write a lossy file, a long clip in blocks.

    Handed the 24 s thrust in one call, libsndfile's Vorbis encoder overflowed
    the stack and took the process down with exit code 127, leaving an OGG of
    headers alone. Blocks avoid that -- but they also change the encode, by up
    to 0.01 against one call for the same samples, so the short clips keep the
    single call and the bytes they were first published with.
    """
    if len(s) <= rate * LONG_SECONDS:
        sf.write(path, s, rate, format=fmt, subtype=subtype)
        return
    channels = 1 if s.ndim == 1 else s.shape[1]
    with sf.SoundFile(path, 'w', rate, channels, format=fmt, subtype=subtype) as f:
        for i in range(0, len(s), 4096):
            f.write(s[i:i + 4096])


def main():
    known = list(GAMES) + [g for g in TRANSCODE if g not in GAMES]
    wanted = sys.argv[1:] or known
    for game in wanted:
        if game not in known:
            sys.exit(f'no such game: {game} (known: {", ".join(known)})')
        write_game(game)


if __name__ == '__main__':
    main()
