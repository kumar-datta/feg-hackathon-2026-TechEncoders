"""
make_slot_demos.py — one themed slot clip per game theme.

Slots are ~95% of the catalogue, so a single shared slot clip made almost every
game look identical on hover. This builds a distinct clip per theme, using the
same palette and emblem as that theme's cover art, so the demo matches the tile.

    python tools/make_slot_demos.py

Output: client/public/demos/slot-<theme>.mp4 | .webm
"""
import math
import os
import random
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_game_art import THEMES  # noqa: E402  (shared palette/emblem table)

W, H = 480, 360
FPS = 24
SECONDS = 4
FRAMES = FPS * SECONDS
OUT_DIR = os.path.join('client', 'public', 'demos')

LINE = (52, 62, 80)
GOLD = (255, 199, 64)
WIN = (33, 192, 122)
DIM = (150, 162, 182)
CREAM = (255, 246, 222)

# themes that are their own game type already have a bespoke clip
SKIP = {'roulette', 'blackjack', 'crash', 'mines', 'dice', 'wheel', 'baccarat', 'default'}


def font(size, bold=False):
    for path in ('C:/Windows/Fonts/segoeuib.ttf' if bold else 'C:/Windows/Fonts/segoeui.ttf',
                 'C:/Windows/Fonts/arialbd.ttf' if bold else 'C:/Windows/Fonts/arial.ttf',
                 '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'):
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                pass
    return ImageFont.load_default()


F_BIG, F_MED, F_SM = font(28, True), font(17, True), font(13)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def centered(d, xy, text, fnt, fill):
    x, y = xy
    box = d.textbbox((0, 0), text, font=fnt)
    d.text((x - (box[2] - box[0]) / 2, y - (box[3] - box[1]) / 2), text, font=fnt, fill=fill)


# ----------------------------------------------------------------------
# small reel emblems — simplified so they stay legible at ~22px
# ----------------------------------------------------------------------
def m_star(d, x, y, s, c, c2):
    pts = []
    for i in range(10):
        r = s if i % 2 == 0 else s * 0.42
        a = math.pi * i / 5 - math.pi / 2
        pts.append((x + r * math.cos(a), y + r * math.sin(a)))
    d.polygon(pts, fill=c)


def m_gem(d, x, y, s, c, c2):
    d.polygon([(x - s * .7, y - s * .35), (x + s * .7, y - s * .35), (x, y + s * .85)], fill=c)
    d.polygon([(x - s * .7, y - s * .35), (x, y - s * .8), (x + s * .7, y - s * .35)], fill=c2)


def m_crown(d, x, y, s, c, c2):
    d.polygon([(x - s, y + s * .5), (x + s, y + s * .5), (x + s * .8, y - s * .2),
               (x + s * .38, y + s * .12), (x, y - s * .75), (x - s * .38, y + s * .12),
               (x - s * .8, y - s * .2)], fill=c)
    d.rectangle([x - s, y + s * .5, x + s, y + s * .78], fill=c2)


def m_key(d, x, y, s, c, c2):
    d.ellipse([x - s * .5, y - s * .9, x + s * .5, y], outline=c, width=max(3, int(s * .28)))
    d.rectangle([x - s * .12, y - s * .1, x + s * .12, y + s * .9], fill=c)
    d.rectangle([x - s * .12, y + s * .38, x + s * .5, y + s * .52], fill=c)


def m_bell(d, x, y, s, c, c2):
    d.pieslice([x - s * .78, y - s * .85, x + s * .78, y + s * .55], 180, 360, fill=c)
    d.rectangle([x - s * .78, y - s * .15, x + s * .78, y + s * .42], fill=c)
    d.rectangle([x - s * .92, y + s * .42, x + s * .92, y + s * .6], fill=c2)


def m_flame(d, x, y, s, c, c2):
    d.polygon([(x, y - s), (x + s * .6, y), (x + s * .4, y + s * .8),
               (x - s * .4, y + s * .8), (x - s * .6, y)], fill=c)
    d.polygon([(x, y - s * .35), (x + s * .3, y + s * .2), (x - s * .3, y + s * .2)], fill=c2)


def m_wheel(d, x, y, s, c, c2):
    d.ellipse([x - s, y - s, x + s, y + s], fill=c2)
    for i in range(8):
        a0 = i * 45
        if i % 2 == 0:
            d.pieslice([x - s, y - s, x + s, y + s], a0, a0 + 45, fill=c)
    d.ellipse([x - s * .28, y - s * .28, x + s * .28, y + s * .28], fill=CREAM)


def m_waves(d, x, y, s, c, c2):
    for row in range(3):
        yy = y - s * .5 + row * s * .5
        pts = [(x - s + i, yy + math.sin(i / 4.0) * s * .22) for i in range(0, int(s * 2) + 2, 3)]
        d.line(pts, fill=c if row % 2 == 0 else c2, width=max(3, int(s * .22)))


def m_seven(d, x, y, s, c, c2):
    d.polygon([(x - s * .58, y - s * .72), (x + s * .6, y - s * .72), (x + s * .6, y - s * .44),
               (x + s * .1, y + s * .85), (x - s * .26, y + s * .85), (x + s * .22, y - s * .42),
               (x - s * .58, y - s * .42)], fill=c)


def m_leaf(d, x, y, s, c, c2):
    d.line([x, y - s, x, y + s], fill=c2, width=max(2, int(s * .16)))
    for i in range(3):
        yy = y - s * .55 + i * s * .55
        d.ellipse([x - s * .85, yy - s * .2, x - s * .05, yy + s * .2], fill=c)
        d.ellipse([x + s * .05, yy + s * .1, x + s * .85, yy + s * .5], fill=c)


def m_shield(d, x, y, s, c, c2):
    d.polygon([(x - s * .8, y - s * .75), (x + s * .8, y - s * .75),
               (x + s * .68, y + s * .3), (x, y + s * .9), (x - s * .68, y + s * .3)], fill=c)
    m_star(d, x, y - s * .05, s * .38, c2, c2)


def m_bolt(d, x, y, s, c, c2):
    d.polygon([(x + s * .18, y - s * .95), (x - s * .55, y + s * .1), (x - s * .06, y + s * .1),
               (x - s * .24, y + s * .95), (x + s * .55, y - s * .14), (x + s * .06, y - s * .14)], fill=c)


def m_anchor(d, x, y, s, c, c2):
    d.ellipse([x - s * .22, y - s * .95, x + s * .22, y - s * .5], outline=c, width=max(3, int(s * .2)))
    d.rectangle([x - s * .1, y - s * .6, x + s * .1, y + s * .75], fill=c)
    d.rectangle([x - s * .55, y - s * .42, x + s * .55, y - s * .26], fill=c2)
    d.arc([x - s * .8, y + s * .05, x + s * .8, y + s * .95], 0, 180, fill=c, width=max(3, int(s * .2)))


def m_coins(d, x, y, s, c, c2):
    for dx, dy, r in ((-s * .38, s * .3, s * .5), (s * .38, s * .3, s * .5), (0, -s * .3, s * .58)):
        d.ellipse([x + dx - r, y + dy - r, x + dx + r, y + dy + r], fill=c, outline=c2, width=2)


def m_pyramid(d, x, y, s, c, c2):
    d.polygon([(x, y - s * .85), (x - s * .95, y + s * .7), (x + s * .95, y + s * .7)], fill=c)
    d.polygon([(x, y - s * .85), (x, y + s * .7), (x + s * .95, y + s * .7)], fill=c2)


def m_lantern(d, x, y, s, c, c2):
    d.rounded_rectangle([x - s * .5, y - s * .6, x + s * .5, y + s * .6], radius=int(s * .35), fill=c)
    d.rectangle([x - s * .6, y - s * .74, x + s * .6, y - s * .56], fill=c2)
    d.rectangle([x - s * .6, y + s * .56, x + s * .6, y + s * .74], fill=c2)


def m_chest(d, x, y, s, c, c2):
    d.pieslice([x - s * .85, y - s * .8, x + s * .85, y + s * .2], 180, 360, fill=c2)
    d.rectangle([x - s * .85, y - s * .28, x + s * .85, y + s * .55], fill=c)
    d.rectangle([x - s * .12, y - s * .35, x + s * .12, y + s * .12], fill=GOLD)


def m_drum(d, x, y, s, c, c2):
    d.ellipse([x - s * .8, y - s * .85, x + s * .8, y - s * .35], fill=c2)
    d.rectangle([x - s * .8, y - s * .6, x + s * .8, y + s * .3], fill=c)
    d.ellipse([x - s * .8, y + s * .05, x + s * .8, y + s * .55], fill=c2)


def m_amphora(d, x, y, s, c, c2):
    d.ellipse([x - s * .55, y - s * .4, x + s * .55, y + s * .85], fill=c)
    d.rectangle([x - s * .2, y - s * .9, x + s * .2, y - s * .3], fill=c)
    d.ellipse([x - s * .3, y - s * .98, x + s * .3, y - s * .78], fill=c2)


def m_wings(d, x, y, s, c, c2):
    for sign in (-1, 1):
        for i in range(3):
            k = 1 - i * .24
            d.polygon([(x + sign * s * .1, y - s * .3 + i * s * .3),
                       (x + sign * s * 1.0 * k, y - s * .1 + i * s * .3),
                       (x + sign * s * .1, y + s * .05 + i * s * .3)],
                      fill=c if i % 2 == 0 else c2)


def m_horns(d, x, y, s, c, c2):
    for sign in (-1, 1):
        d.arc([x + sign * s * .1 - s * .85, y - s * .85, x + sign * s * .1 + s * .85, y + s * .45],
              200 if sign < 0 else 300, 340 if sign < 0 else 80, fill=c, width=max(3, int(s * .2)))
    d.ellipse([x - s * .2, y + s * .2, x + s * .2, y + s * .7], fill=c2)


def m_sunburst(d, x, y, s, c, c2):
    for i in range(12):
        a = math.pi * i / 6
        d.line([x + s * .35 * math.cos(a), y + s * .35 * math.sin(a),
                x + s * math.cos(a), y + s * math.sin(a)], fill=c2, width=max(2, int(s * .16)))
    d.ellipse([x - s * .45, y - s * .45, x + s * .45, y + s * .45], fill=c)


MINI = {
    'star': m_star, 'gem': m_gem, 'crown': m_crown, 'key': m_key, 'bell': m_bell,
    'flame': m_flame, 'wheel': m_wheel, 'waves': m_waves, 'seven': m_seven, 'leaf': m_leaf,
    'shield': m_shield, 'bolt': m_bolt, 'anchor': m_anchor, 'coins': m_coins,
    'pyramid': m_pyramid, 'lantern': m_lantern, 'chest': m_chest, 'drum': m_drum,
    'amphora': m_amphora, 'wings': m_wings, 'horns': m_horns, 'sunburst': m_sunburst,
}

# text glyphs used for the low-value reel symbols
GLYPHS = ['A', 'K', 'Q', 'J', '10', '9']


def build_frames(theme, emblem, top, bottom, main, shade, glow):
    """One 4-second reel spin, styled with this theme's palette and emblem."""
    rng = random.Random(sum(ord(c) for c in theme))
    label = theme.upper()

    # symbol table: 0 = the theme emblem (high value), then two tinted emblems,
    # then plain letters. index -> ('emblem'|'text', payload, colour)
    symbols = [
        ('emblem', emblem, main),
        ('emblem', 'gem', glow),
        ('emblem', 'coins', GOLD),
        ('text', GLYPHS[0], CREAM),
        ('text', GLYPHS[1], DIM),
        ('text', GLYPHS[2], DIM),
        ('text', GLYPHS[3], DIM),
        ('text', GLYPHS[4], DIM),
    ]

    final = [[rng.randrange(len(symbols)) for _ in range(3)] for _ in range(5)]
    for c in range(3):
        final[c][1] = 0                      # guarantee a middle-row win

    stop_at = [14, 20, 26, 32, 38]
    cw, ch = 78, 66
    gx, gy = (W - cw * 5) // 2, 84

    def draw_symbol(d, kind, payload, colour, cx, cy, ghost=False):
        col = (72, 82, 100) if ghost else colour
        if kind == 'emblem':
            MINI.get(payload, m_star)(d, cx, cy, 22, col, shade if not ghost else (56, 64, 80))
        else:
            centered(d, (cx, cy), payload, F_BIG, col)

    frames = []
    for f in range(FRAMES):
        img = Image.new('RGB', (W, H))
        d = ImageDraw.Draw(img)
        for y in range(H):
            d.line([(0, y), (W, y)], fill=lerp(top, bottom, y / H))

        # header
        d.rectangle([0, 0, W, 42], fill=(0, 0, 0))
        d.line([0, 42, W, 42], fill=LINE)
        d.text((14, 13), f'DEMO  ·  {label}', font=F_MED, fill=main)
        box = d.textbbox((0, 0), 'preview', font=F_SM)
        d.text((W - 14 - (box[2] - box[0]), 16), 'preview', font=F_SM, fill=DIM)

        for c in range(5):
            spinning = f < stop_at[c]
            for r in range(3):
                x0, y0 = gx + c * cw + 3, gy + r * ch + 3
                x1, y1 = x0 + cw - 6, y0 + ch - 6
                won = (not spinning and f > stop_at[4] + 4 and r == 1 and c < 3)

                d.rounded_rectangle([x0, y0, x1, y1], radius=8,
                                    fill=(38, 30, 6) if won else (0, 0, 0),
                                    outline=main if won else LINE, width=2 if won else 1)

                cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
                if spinning:
                    idx = (f * 3 + r * 2 + c) % len(symbols)
                    kind, payload, _ = symbols[idx]
                    draw_symbol(d, kind, payload, None, cx, cy, ghost=True)
                else:
                    kind, payload, colour = symbols[final[c][r]]
                    draw_symbol(d, kind, payload, colour, cx, cy)

        if f > stop_at[4] + 4:
            y = gy + ch + ch // 2
            d.line([gx + 6, y, gx + cw * 3 - 6, y], fill=main, width=3)
            centered(d, (W / 2, H - 32), 'WIN  x45', F_BIG, WIN)
        else:
            centered(d, (W / 2, H - 32), '5 LINES  ·  SPINNING', F_SM, DIM)

        frames.append(img)
    return frames


def encode(frames, slug):
    tmp = tempfile.mkdtemp(prefix='psk_' + slug + '_')
    try:
        for i, im in enumerate(frames):
            im.save(os.path.join(tmp, f'{i:04d}.png'))
        os.makedirs(OUT_DIR, exist_ok=True)
        pattern = os.path.join(tmp, '%04d.png')

        mp4 = os.path.join(OUT_DIR, slug + '.mp4')
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', pattern,
                        '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '30',
                        '-movflags', '+faststart', mp4], check=True)

        webm = os.path.join(OUT_DIR, slug + '.webm')
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', pattern,
                        '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '46', '-an',
                        '-cpu-used', '5', webm], check=True)

        frames[len(frames) // 2].save(os.path.join(OUT_DIR, slug + '.jpg'), quality=80)
        return os.path.getsize(mp4) + os.path.getsize(webm)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    if not os.path.isdir('client'):
        sys.exit('Run this from the repository root (the folder containing client/).')

    themes = [t for t in THEMES if t[0] not in SKIP]
    total = 0
    for i, spec in enumerate(themes, 1):
        slug = 'slot-' + spec[0]
        size = encode(build_frames(*spec), slug)
        total += size
        print(f'  [{i:2d}/{len(themes)}] {slug:22s} {size / 1024:7.1f} KB')

    print(f'{len(themes)} themed slot clips, {total / 1024 / 1024:.1f} MB total -> {OUT_DIR}')


if __name__ == '__main__':
    main()
