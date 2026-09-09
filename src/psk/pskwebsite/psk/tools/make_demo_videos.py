"""
make_demo_videos.py — generates the short looping gameplay clips used for the
hover preview on casino tiles.

Everything is drawn from scratch with PIL (no external artwork), then encoded
with ffmpeg. Run from the repo root:

    python tools/make_demo_videos.py

Output: client/public/demos/<slug>.mp4 and .webm
"""
import math
import os
import random
import shutil
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

W, H = 480, 360
FPS = 24
SECONDS = 4
FRAMES = FPS * SECONDS

OUT_DIR = os.path.join('client', 'public', 'demos')

BG = (13, 17, 23)
PANEL = (21, 27, 38)
LINE = (42, 52, 68)
ACCENT = (255, 204, 0)
WIN = (33, 192, 122)
LIVE = (255, 59, 48)
TXT = (232, 237, 245)
DIM = (147, 161, 184)


def font(size, bold=False):
    """Best-effort system font lookup, falling back to PIL's default."""
    candidates = [
        'C:/Windows/Fonts/segoeuib.ttf' if bold else 'C:/Windows/Fonts/segoeui.ttf',
        'C:/Windows/Fonts/arialbd.ttf' if bold else 'C:/Windows/Fonts/arial.ttf',
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold
        else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                pass
    return ImageFont.load_default()


F_HUGE = font(46, True)
F_BIG = font(30, True)
F_MED = font(18, True)
F_SM = font(14)
F_XS = font(12)


def centered(d, xy, text, fnt, fill):
    x, y = xy
    box = d.textbbox((0, 0), text, font=fnt)
    d.text((x - (box[2] - box[0]) / 2, y - (box[3] - box[1]) / 2), text, font=fnt, fill=fill)


def base_frame(title, subtitle=None):
    img = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, W, 40], fill=PANEL)
    d.line([0, 40, W, 40], fill=LINE)
    d.text((14, 12), title, font=F_MED, fill=ACCENT)
    if subtitle:
        box = d.textbbox((0, 0), subtitle, font=F_XS)
        d.text((W - 14 - (box[2] - box[0]), 15), subtitle, font=F_XS, fill=DIM)
    return img, d


# ----------------------------------------------------------------------
# 1) SLOT — five reels spin down and settle, winning line lights up
# ----------------------------------------------------------------------
def slot_frames():
    symbols = ['7', '$', '*', '#', '@', '&', '%', '+']
    colours = [ACCENT, WIN, (77, 132, 240), LIVE, (216, 122, 255), (0, 200, 200)]
    rng = random.Random(7)

    # final grid, engineered so the middle row has a 3-in-a-row win
    final = [[rng.randrange(len(symbols)) for _ in range(3)] for _ in range(5)]
    for c in range(3):
        final[c][1] = 0

    stop_at = [14, 20, 26, 32, 38]          # frame each reel settles on
    cell_w, cell_h = 78, 66
    grid_x, grid_y = (W - cell_w * 5) // 2, 80

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  ·  SLOT', 'preview')

        for c in range(5):
            spinning = f < stop_at[c]
            for r in range(3):
                x0 = grid_x + c * cell_w + 3
                y0 = grid_y + r * cell_h + 3
                x1, y1 = x0 + cell_w - 6, y0 + cell_h - 6

                won = (not spinning and f > stop_at[4] + 4 and r == 1 and c < 3)
                d.rounded_rectangle([x0, y0, x1, y1], radius=8,
                                    fill=(38, 30, 6) if won else PANEL,
                                    outline=ACCENT if won else LINE, width=2 if won else 1)

                if spinning:
                    idx = (f * 3 + r * 2 + c) % len(symbols)
                    # motion blur: draw the neighbouring symbols faintly
                    centered(d, ((x0 + x1) / 2, (y0 + y1) / 2 - 16),
                             symbols[(idx + 1) % len(symbols)], F_MED, (60, 70, 88))
                    centered(d, ((x0 + x1) / 2, (y0 + y1) / 2 + 16),
                             symbols[(idx + 2) % len(symbols)], F_MED, (60, 70, 88))
                else:
                    idx = final[c][r]
                centered(d, ((x0 + x1) / 2, (y0 + y1) / 2),
                         symbols[idx], F_BIG,
                         colours[idx % len(colours)] if not spinning else DIM)

        if f > stop_at[4] + 4:
            y = grid_y + cell_h + cell_h // 2
            d.line([grid_x + 6, y, grid_x + cell_w * 3 - 6, y], fill=ACCENT, width=3)
            centered(d, (W / 2, H - 34), 'WIN  x45', F_BIG, WIN)
        else:
            centered(d, (W / 2, H - 34), '5 LINES  ·  SPINNING', F_SM, DIM)

        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 2) ROULETTE — wheel decelerates, ball drops, number shows
# ----------------------------------------------------------------------
def roulette_frames():
    order = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23,
             10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
    reds = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36}
    n = len(order)
    seg = 360.0 / n
    cx, cy, rad = W // 2, 205, 108
    target_idx = 12                     # lands on 13

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  ·  ROULETTE', 'preview')
        p = min(1.0, f / (FRAMES * 0.78))
        eased = 1 - pow(1 - p, 3)       # ease-out cubic
        spin = eased * (360 * 4 + (360 - target_idx * seg - seg / 2))

        for i, num in enumerate(order):
            a0 = math.radians(i * seg + spin - 90)
            a1 = math.radians((i + 1) * seg + spin - 90)
            colour = (18, 100, 58) if num == 0 else ((139, 23, 23) if num in reds else (23, 27, 34))
            d.pieslice([cx - rad, cy - rad, cx + rad, cy + rad],
                       math.degrees(a0), math.degrees(a1), fill=colour)

        d.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline=(107, 74, 18), width=5)
        d.ellipse([cx - 42, cy - 42, cx + 42, cy + 42], fill=PANEL, outline=LINE, width=2)

        settled = p >= 1.0
        centered(d, (cx, cy), '13' if settled else '—', F_BIG, LIVE if settled else DIM)

        # ball orbits faster, then parks at the pointer
        ball_a = math.radians(-90 + (spin * 2.4 if not settled else 0))
        br = rad - 16
        bx, by = cx + br * math.cos(ball_a), cy + br * math.sin(ball_a)
        d.ellipse([bx - 6, by - 6, bx + 6, by + 6], fill=(250, 250, 252))

        d.polygon([(cx, cy - rad - 14), (cx - 9, cy - rad - 30), (cx + 9, cy - rad - 30)], fill=ACCENT)
        centered(d, (W / 2, H - 26), 'RED 13  ·  PAYS 36x' if settled else 'NO MORE BETS',
                 F_SM, WIN if settled else DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 3) CRASH — multiplier curve climbs, then busts
# ----------------------------------------------------------------------
def crash_frames():
    bust_at = int(FRAMES * 0.80)
    plot = (40, 70, W - 30, H - 60)

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  ·  CRASH', 'preview')
        d.rectangle(plot, fill=(8, 13, 22), outline=LINE)

        for i in range(1, 4):
            y = plot[1] + (plot[3] - plot[1]) * i / 4
            d.line([plot[0], y, plot[2], y], fill=(26, 33, 46))

        busted = f >= bust_at
        prog = min(1.0, f / bust_at)
        mult = 1.0 + 5.2 * pow(prog, 1.9)

        pts = []
        steps = 60
        for s in range(steps + 1):
            t = (s / steps) * prog
            x = plot[0] + (plot[2] - plot[0]) * t
            y = plot[3] - (plot[3] - plot[1]) * pow(t, 1.75)
            pts.append((x, y))

        if len(pts) > 1:
            d.polygon(pts + [(pts[-1][0], plot[3]), (plot[0], plot[3])], fill=(46, 38, 6))
            d.line(pts, fill=LIVE if busted else ACCENT, width=4)
            hx, hy = pts[-1]
            d.ellipse([hx - 7, hy - 7, hx + 7, hy + 7], fill=LIVE if busted else ACCENT)

        centered(d, (W / 2, 150),
                 f'{mult:.2f}x' + ('  BUST' if busted else ''),
                 F_HUGE, LIVE if busted else TXT)
        centered(d, (W / 2, H - 26),
                 'ROUND OVER' if busted else 'CASH OUT ANY TIME',
                 F_SM, LIVE if busted else DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 4) BLACKJACK — cards deal in, dealer reveals, result
# ----------------------------------------------------------------------
def blackjack_frames():
    def card(d, x, y, rank, suit, red, w=58, h=84):
        d.rounded_rectangle([x, y, x + w, y + h], radius=7, fill=(250, 250, 252))
        col = (200, 40, 40) if red else (24, 28, 36)
        d.text((x + 7, y + 5), rank, font=F_MED, fill=col)
        centered(d, (x + w / 2, y + h / 2 + 6), suit, F_BIG, col)

    def back(d, x, y, w=58, h=84):
        d.rounded_rectangle([x, y, x + w, y + h], radius=7, fill=(20, 70, 190))
        d.rounded_rectangle([x + 6, y + 6, x + w - 6, y + h - 6], radius=5,
                            outline=(90, 140, 240), width=2)

    player = [('A', '\u2660', False), ('10', '\u2666', True)]
    dealer = [('9', '\u2663', False), ('7', '\u2665', True)]

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  \u00b7  BLACKJACK', 'preview')

        d.text((30, 56), 'DEALER', font=F_SM, fill=DIM)
        reveal = f > 44
        for i in range(len(dealer)):
            if f < 10 + i * 8:
                continue
            x = 30 + i * 68
            if i == 1 and not reveal:
                back(d, x, 76)
            else:
                card(d, x, 76, *dealer[i])
        if reveal:
            centered(d, (250, 118), '16', F_MED, TXT)

        d.text((30, 186), 'PLAYER', font=F_SM, fill=DIM)
        for i in range(len(player)):
            if f < 22 + i * 8:
                continue
            card(d, 30 + i * 68, 206, *player[i])
        if f > 38:
            centered(d, (250, 248), '21', F_MED, WIN)

        if f > 60:
            centered(d, (W / 2, H - 30), 'BLACKJACK  \u00b7  PAYS 3:2', F_MED, WIN)
        elif reveal:
            centered(d, (W / 2, H - 30), 'DEALER STANDS ON 16', F_SM, DIM)
        else:
            centered(d, (W / 2, H - 30), 'DEALING\u2026', F_SM, DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 5) MINES — tiles flip to gems, then one hits a mine
# ----------------------------------------------------------------------
def mines_frames():
    order = [12, 7, 18, 6, 13, 21, 8]
    mine_at = 21
    cols, size, gap = 5, 52, 8
    gx = (W - (size * cols + gap * (cols - 1))) // 2
    gy = 74

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  \u00b7  MINES', 'preview')
        revealed = [c for k, c in enumerate(order) if f > 10 + k * 9]
        boom = mine_at in revealed

        for i in range(25):
            r, c = divmod(i, cols)
            x = gx + c * (size + gap)
            y = gy + r * (size + gap)
            if i in revealed:
                hit = (i == mine_at)
                d.rounded_rectangle([x, y, x + size, y + size], radius=8,
                                    fill=(70, 14, 14) if hit else (10, 52, 34),
                                    outline=LIVE if hit else WIN, width=2)
                centered(d, (x + size / 2, y + size / 2), 'X' if hit else '\u25c6',
                         F_MED, LIVE if hit else WIN)
            else:
                d.rounded_rectangle([x, y, x + size, y + size], radius=8, fill=PANEL, outline=LINE)

        safe = len([c for c in revealed if c != mine_at])
        if boom:
            centered(d, (W / 2, H - 28), 'MINE HIT  \u00b7  ROUND OVER', F_MED, LIVE)
        else:
            centered(d, (W / 2, H - 28), f'{safe} SAFE  \u00b7  x{1 + safe * 0.28:.2f}', F_MED, ACCENT)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 6) DICE — two dice tumble and settle
# ----------------------------------------------------------------------
def dice_frames():
    PIPS = {
        1: [(0, 0)], 2: [(-1, -1), (1, 1)], 3: [(-1, -1), (0, 0), (1, 1)],
        4: [(-1, -1), (1, -1), (-1, 1), (1, 1)],
        5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
        6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)],
    }

    def die(d, cx, cy, v, s=52):
        d.rounded_rectangle([cx - s, cy - s, cx + s, cy + s], radius=14,
                            fill=(250, 250, 252), outline=(210, 214, 222), width=2)
        for px, py in PIPS[v]:
            r = 8
            x, y = cx + px * s * 0.48, cy + py * s * 0.48
            d.ellipse([x - r, y - r, x + r, y + r], fill=(26, 30, 38))

    rng = random.Random(3)
    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  \u00b7  DICE', 'preview')
        settled = f > int(FRAMES * 0.62)
        a, b = (5, 2) if settled else (rng.randrange(1, 7), rng.randrange(1, 7))

        wob = 0 if settled else math.sin(f * 0.9) * 10
        die(d, W // 2 - 78, 176 + wob, a)
        die(d, W // 2 + 78, 176 - wob, b)

        centered(d, (W / 2, 268), f'TOTAL {a + b}', F_MED, TXT if settled else DIM)
        centered(d, (W / 2, H - 28),
                 'UNDER 7  \u00b7  PAYS 2x' if settled else 'ROLLING\u2026',
                 F_SM, WIN if settled else DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 7) MONEY WHEEL — segmented wheel decelerates onto a multiplier
# ----------------------------------------------------------------------
def wheel_frames():
    segs = [1, 2, 5, 1, 10, 1, 2, 20, 1, 5, 2, 40, 1, 2, 5, 1, 10, 2, 1, 5]
    cols = {1: (29, 78, 216), 2: (15, 118, 110), 5: (161, 98, 7),
            10: (124, 45, 18), 20: (112, 26, 117), 40: (153, 27, 27)}
    n = len(segs)
    seg = 360.0 / n
    cx, cy, rad = W // 2, 200, 106
    target = 11                       # lands on 40x

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  \u00b7  MONEY WHEEL', 'preview')
        p = min(1.0, f / (FRAMES * 0.8))
        eased = 1 - pow(1 - p, 3)
        spin = eased * (360 * 3 + (360 - target * seg - seg / 2))

        for i, v in enumerate(segs):
            a0 = i * seg + spin - 90
            d.pieslice([cx - rad, cy - rad, cx + rad, cy + rad], a0, a0 + seg, fill=cols[v])

        d.ellipse([cx - rad, cy - rad, cx + rad, cy + rad], outline=(107, 74, 18), width=5)
        d.ellipse([cx - 40, cy - 40, cx + 40, cy + 40], fill=PANEL, outline=LINE, width=2)

        settled = p >= 1.0
        centered(d, (cx, cy), '40x' if settled else '\u2014', F_BIG, ACCENT if settled else DIM)
        d.polygon([(cx, cy - rad - 12), (cx - 9, cy - rad - 28), (cx + 9, cy - rad - 28)], fill=ACCENT)
        centered(d, (W / 2, H - 26), 'TOP SEGMENT  \u00b7  40x' if settled else 'SPINNING\u2026',
                 F_SM, WIN if settled else DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
# 8) BACCARAT — player and banker hands revealed
# ----------------------------------------------------------------------
def baccarat_frames():
    def card(d, x, y, rank, suit, red, w=54, h=78):
        d.rounded_rectangle([x, y, x + w, y + h], radius=7, fill=(250, 250, 252))
        col = (200, 40, 40) if red else (24, 28, 36)
        d.text((x + 6, y + 4), rank, font=F_SM, fill=col)
        centered(d, (x + w / 2, y + h / 2 + 5), suit, F_MED, col)

    p_hand = [('4', '\u2660', False), ('5', '\u2665', True)]
    b_hand = [('K', '\u2663', False), ('6', '\u2666', True)]

    frames = []
    for f in range(FRAMES):
        img, d = base_frame('DEMO  \u00b7  BACCARAT', 'preview')

        d.text((44, 62), 'PLAYER', font=F_SM, fill=DIM)
        d.text((W - 130, 62), 'BANKER', font=F_SM, fill=DIM)

        for i in range(2):
            if f > 10 + i * 10:
                card(d, 44 + i * 62, 84, *p_hand[i])
            if f > 16 + i * 10:
                card(d, W - 168 + i * 62, 84, *b_hand[i])

        if f > 48:
            centered(d, (106, 196), '9', F_BIG, WIN)
            centered(d, (W - 106, 196), '6', F_BIG, TXT)
        if f > 62:
            centered(d, (W / 2, H - 52), 'PLAYER WINS', F_BIG, WIN)
            centered(d, (W / 2, H - 22), 'NATURAL 9  \u00b7  PAYS 2x', F_SM, DIM)
        else:
            centered(d, (W / 2, H - 26), 'DEALING\u2026', F_SM, DIM)
        frames.append(img)
    return frames


# ----------------------------------------------------------------------
def encode(frames, slug):
    tmp = tempfile.mkdtemp(prefix='psk_' + slug + '_')
    try:
        for i, im in enumerate(frames):
            im.save(os.path.join(tmp, f'{i:04d}.png'))

        os.makedirs(OUT_DIR, exist_ok=True)
        pattern = os.path.join(tmp, '%04d.png')

        mp4 = os.path.join(OUT_DIR, slug + '.mp4')
        subprocess.run([
            'ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', pattern,
            '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '28',
            '-movflags', '+faststart', mp4
        ], check=True)

        webm = os.path.join(OUT_DIR, slug + '.webm')
        subprocess.run([
            'ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(FPS), '-i', pattern,
            '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '40', '-an', webm
        ], check=True)

        # a poster frame for the tile before the video starts
        frames[len(frames) // 2].save(os.path.join(OUT_DIR, slug + '.jpg'), quality=82)

        for path in (mp4, webm):
            print(f'  {os.path.basename(path):24s} {os.path.getsize(path) / 1024:7.1f} KB')
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    if not os.path.isdir('client'):
        sys.exit('Run this from the repository root (the folder containing client/).')

    for slug, builder in (
        ('slot', slot_frames),
        ('roulette', roulette_frames),
        ('crash', crash_frames),
        ('blackjack', blackjack_frames),
        ('mines', mines_frames),
        ('dice', dice_frames),
        ('wheel', wheel_frames),
        ('baccarat', baccarat_frames),
    ):
        print(f'building {slug}...')
        encode(builder(), slug)

    print('done ->', OUT_DIR)


if __name__ == '__main__':
    main()
