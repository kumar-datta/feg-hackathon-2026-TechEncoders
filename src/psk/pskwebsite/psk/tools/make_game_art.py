"""
make_game_art.py — generates cover artwork for the casino tiles.

Every cover is drawn from scratch with PIL: a themed palette, a layered
background, a large geometric emblem and a bottom scrim. Nothing here is
traced from or derived from third-party game artwork.

    python tools/make_game_art.py

Output: client/public/art/<theme>.jpg
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

W, H = 420, 500
OUT_DIR = os.path.join('client', 'public', 'art')

GOLD = (255, 199, 64)
GOLD_DK = (196, 138, 18)
SILVER = (226, 232, 240)
CREAM = (255, 244, 214)


# ----------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------
def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vertical_gradient(img, top, bottom):
    d = ImageDraw.Draw(img)
    for y in range(H):
        d.line([(0, y), (W, y)], fill=lerp(top, bottom, y / H))


def radial_glow(img, centre, radius, colour, strength=0.55):
    glow = Image.new('RGB', (W, H), (0, 0, 0))
    gd = ImageDraw.Draw(glow)
    steps = 26
    for i in range(steps, 0, -1):
        r = radius * i / steps
        t = 1 - i / steps
        gd.ellipse([centre[0] - r, centre[1] - r, centre[0] + r, centre[1] + r],
                   fill=lerp((0, 0, 0), colour, t * t))
    glow = glow.filter(ImageFilter.GaussianBlur(26))
    return Image.blend(img, Image.blend(img, glow, 1.0), strength) if False else \
        Image.composite(Image.blend(img, glow, strength), img, Image.new('L', (W, H), 255))


def screen_layer(base, layer, amount=1.0):
    """Additive-ish blend so glows sit on top without washing the art out."""
    b = base.load()
    l = layer.load()
    for y in range(0, H, 1):
        for x in range(0, W, 1):
            br, bg, bb = b[x, y]
            lr, lg, lb = l[x, y]
            b[x, y] = (min(255, br + int(lr * amount)),
                       min(255, bg + int(lg * amount)),
                       min(255, bb + int(lb * amount)))
    return base


def rays(d, centre, count, inner, outer, colour, width=None):
    cx, cy = centre
    for i in range(count):
        a = 2 * math.pi * i / count
        x0, y0 = cx + inner * math.cos(a), cy + inner * math.sin(a)
        x1, y1 = cx + outer * math.cos(a), cy + outer * math.sin(a)
        if width:
            d.line([x0, y0, x1, y1], fill=colour, width=width)
        else:
            a2 = a + math.pi / count * 0.5
            d.polygon([(cx, cy), (x1, y1),
                       (cx + outer * math.cos(a2), cy + outer * math.sin(a2))], fill=colour)


def star(d, centre, points, r_out, r_in, colour, outline=None):
    cx, cy = centre
    pts = []
    for i in range(points * 2):
        r = r_out if i % 2 == 0 else r_in
        a = math.pi * i / points - math.pi / 2
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    d.polygon(pts, fill=colour, outline=outline)


def bevel_circle(d, centre, r, top, bottom, ring=None):
    cx, cy = centre
    steps = 30
    for i in range(steps):
        rr = r * (1 - i / steps * 0.16)
        d.ellipse([cx - rr, cy - rr + i * 0.5, cx + rr, cy + rr + i * 0.5],
                  fill=lerp(top, bottom, i / steps))
    if ring:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=ring, width=6)


# ----------------------------------------------------------------------
# emblems
# ----------------------------------------------------------------------
def em_sunburst(d, c, s, col, col2):
    rays(d, c, 16, s * 0.25, s * 1.05, col2)
    bevel_circle(d, c, s * 0.52, col, col2, ring=GOLD_DK)


def em_star(d, c, s, col, col2):
    rays(d, c, 12, s * 0.3, s * 1.0, col2)
    star(d, c, 5, s * 0.72, s * 0.3, col, outline=GOLD_DK)


def em_pyramid(d, c, s, col, col2):
    cx, cy = c
    for i, k in enumerate((1.0, 0.66, 0.34)):
        w = s * k
        y = cy + s * 0.55 - i * s * 0.42
        d.polygon([(cx, y - s * 0.5 * k * 1.4), (cx - w, y), (cx + w, y)],
                  fill=col if i % 2 == 0 else col2)
    d.polygon([(cx, cy - s * 1.0), (cx - s * 0.12, cy - s * 0.72), (cx + s * 0.12, cy - s * 0.72)], fill=CREAM)


def em_wheel(d, c, s, col, col2):
    cx, cy = c
    d.ellipse([cx - s, cy - s, cx + s, cy + s], fill=col2, outline=GOLD_DK, width=6)
    for i in range(12):
        a0 = math.radians(i * 30)
        a1 = math.radians(i * 30 + 30)
        if i % 2 == 0:
            d.pieslice([cx - s, cy - s, cx + s, cy + s], math.degrees(a0), math.degrees(a1), fill=col)
    d.ellipse([cx - s * 0.3, cy - s * 0.3, cx + s * 0.3, cy + s * 0.3], fill=CREAM, outline=GOLD_DK, width=4)


def em_waves(d, c, s, col, col2):
    cx, cy = c
    for row in range(4):
        y = cy - s * 0.5 + row * s * 0.38
        pts = []
        for i in range(0, int(s * 2.4) + 8, 8):
            x = cx - s * 1.2 + i
            pts.append((x, y + math.sin(i / s * 3 + row) * s * 0.16))
        d.line(pts, fill=col if row % 2 == 0 else col2, width=int(s * 0.16))


def em_gem(d, c, s, col, col2):
    cx, cy = c
    top = cy - s * 0.55
    d.polygon([(cx - s * 0.75, top), (cx + s * 0.75, top), (cx + s, cy - s * 0.15), (cx, cy + s * 0.9),
               (cx - s, cy - s * 0.15)], fill=col)
    d.polygon([(cx - s * 0.75, top), (cx, cy + s * 0.9), (cx - s, cy - s * 0.15)], fill=col2)
    d.polygon([(cx - s * 0.75, top), (cx + s * 0.75, top), (cx, cy - s * 0.15)], fill=CREAM)


def em_crown(d, c, s, col, col2):
    cx, cy = c
    base_y = cy + s * 0.55
    d.polygon([(cx - s, base_y), (cx + s, base_y), (cx + s * 0.8, cy - s * 0.15),
               (cx + s * 0.4, cy + s * 0.15), (cx, cy - s * 0.7),
               (cx - s * 0.4, cy + s * 0.15), (cx - s * 0.8, cy - s * 0.15)], fill=col)
    d.rectangle([cx - s, base_y, cx + s, base_y + s * 0.28], fill=col2)
    for dx in (-s * 0.8, 0, s * 0.8):
        d.ellipse([cx + dx - s * 0.11, cy - s * 0.85, cx + dx + s * 0.11, cy - s * 0.63], fill=CREAM)


def em_key(d, c, s, col, col2):
    cx, cy = c
    d.ellipse([cx - s * 0.55, cy - s * 0.95, cx + s * 0.55, cy + s * 0.15], fill=col, outline=col2, width=5)
    d.ellipse([cx - s * 0.22, cy - s * 0.62, cx + s * 0.22, cy - s * 0.18], fill=(0, 0, 0))
    d.rectangle([cx - s * 0.13, cy + s * 0.05, cx + s * 0.13, cy + s * 0.95], fill=col)
    d.rectangle([cx - s * 0.13, cy + s * 0.55, cx + s * 0.5, cy + s * 0.7], fill=col)
    d.rectangle([cx - s * 0.13, cy + s * 0.8, cx + s * 0.38, cy + s * 0.93], fill=col)


def em_anchor(d, c, s, col, col2):
    cx, cy = c
    d.ellipse([cx - s * 0.2, cy - s * 0.95, cx + s * 0.2, cy - s * 0.55], outline=col, width=int(s * 0.14))
    d.rectangle([cx - s * 0.1, cy - s * 0.6, cx + s * 0.1, cy + s * 0.8], fill=col)
    d.rectangle([cx - s * 0.55, cy - s * 0.42, cx + s * 0.55, cy - s * 0.28], fill=col2)
    d.arc([cx - s * 0.8, cy + s * 0.1, cx + s * 0.8, cy + s * 1.0], 0, 180, fill=col, width=int(s * 0.16))


def em_bell(d, c, s, col, col2):
    cx, cy = c
    d.pieslice([cx - s * 0.8, cy - s * 0.9, cx + s * 0.8, cy + s * 0.7], 180, 360, fill=col)
    d.rectangle([cx - s * 0.8, cy - s * 0.1, cx + s * 0.8, cy + s * 0.5], fill=col)
    d.rounded_rectangle([cx - s * 0.95, cy + s * 0.5, cx + s * 0.95, cy + s * 0.68], radius=6, fill=col2)
    d.ellipse([cx - s * 0.16, cy + s * 0.7, cx + s * 0.16, cy + s * 1.0], fill=col2)


def em_flame(d, c, s, col, col2):
    cx, cy = c
    d.polygon([(cx, cy - s), (cx + s * 0.62, cy - s * 0.1), (cx + s * 0.42, cy + s * 0.8),
               (cx - s * 0.42, cy + s * 0.8), (cx - s * 0.62, cy - s * 0.1)], fill=col)
    d.polygon([(cx, cy - s * 0.45), (cx + s * 0.34, cy + s * 0.16), (cx + s * 0.2, cy + s * 0.75),
               (cx - s * 0.2, cy + s * 0.75), (cx - s * 0.34, cy + s * 0.16)], fill=col2)


def em_coins(d, c, s, col, col2):
    cx, cy = c
    for i, (dx, dy, r) in enumerate(((-s * 0.42, s * 0.42, s * 0.5), (s * 0.42, s * 0.42, s * 0.5),
                                     (0, -s * 0.12, s * 0.62))):
        bevel_circle(d, (cx + dx, cy + dy), r, col, col2, ring=GOLD_DK)


def em_leaf(d, c, s, col, col2):
    cx, cy = c
    d.line([cx, cy - s, cx, cy + s], fill=col2, width=int(s * 0.12))
    for i in range(5):
        y = cy - s * 0.75 + i * s * 0.4
        d.ellipse([cx - s * 0.85, y - s * 0.16, cx - s * 0.08, y + s * 0.2], fill=col)
        d.ellipse([cx + s * 0.08, y + s * 0.04, cx + s * 0.85, y + s * 0.4], fill=col)


def em_horns(d, c, s, col, col2):
    cx, cy = c
    for sign in (-1, 1):
        d.arc([cx + sign * s * 0.1 - s * 0.9, cy - s * 0.9, cx + sign * s * 0.1 + s * 0.9, cy + s * 0.5],
              200 if sign < 0 else 300, 340 if sign < 0 else 80, fill=col, width=int(s * 0.16))
        for k in (0.35, 0.65):
            d.line([cx + sign * s * k, cy - s * 0.25, cx + sign * s * (k + 0.35), cy - s * 0.75],
                   fill=col2, width=int(s * 0.1))
    d.ellipse([cx - s * 0.22, cy + s * 0.25, cx + s * 0.22, cy + s * 0.75], fill=col2)


def em_seven(d, c, s, col, col2):
    cx, cy = c
    rays(d, c, 14, s * 0.35, s * 1.05, col2)
    d.polygon([(cx - s * 0.6, cy - s * 0.7), (cx + s * 0.62, cy - s * 0.7),
               (cx + s * 0.62, cy - s * 0.42), (cx + s * 0.1, cy + s * 0.85),
               (cx - s * 0.28, cy + s * 0.85), (cx + s * 0.24, cy - s * 0.4),
               (cx - s * 0.6, cy - s * 0.4)], fill=col, outline=GOLD_DK)


def em_lantern(d, c, s, col, col2):
    cx, cy = c
    d.rounded_rectangle([cx - s * 0.55, cy - s * 0.65, cx + s * 0.55, cy + s * 0.65], radius=int(s * 0.4), fill=col)
    d.rectangle([cx - s * 0.62, cy - s * 0.78, cx + s * 0.62, cy - s * 0.6], fill=col2)
    d.rectangle([cx - s * 0.62, cy + s * 0.6, cx + s * 0.62, cy + s * 0.78], fill=col2)
    for k in (-0.25, 0, 0.25):
        d.line([cx + s * k, cy - s * 0.55, cx + s * k, cy + s * 0.55], fill=col2, width=3)
    d.line([cx, cy - s * 1.0, cx, cy - s * 0.78], fill=col2, width=4)


def em_chest(d, c, s, col, col2):
    cx, cy = c
    d.pieslice([cx - s * 0.9, cy - s * 0.85, cx + s * 0.9, cy + s * 0.25], 180, 360, fill=col2)
    d.rectangle([cx - s * 0.9, cy - s * 0.3, cx + s * 0.9, cy + s * 0.6], fill=col)
    d.rectangle([cx - s * 0.9, cy - s * 0.34, cx + s * 0.9, cy - s * 0.16], fill=GOLD_DK)
    d.rectangle([cx - s * 0.14, cy - s * 0.4, cx + s * 0.14, cy + s * 0.12], fill=GOLD)
    d.ellipse([cx - s * 0.09, cy - s * 0.12, cx + s * 0.09, cy + s * 0.06], fill=(30, 20, 0))


def em_drum(d, c, s, col, col2):
    cx, cy = c
    d.ellipse([cx - s * 0.85, cy - s * 0.9, cx + s * 0.85, cy - s * 0.35], fill=col2)
    d.rectangle([cx - s * 0.85, cy - s * 0.62, cx + s * 0.85, cy + s * 0.35], fill=col)
    d.ellipse([cx - s * 0.85, cy + s * 0.08, cx + s * 0.85, cy + s * 0.62], fill=col2)
    for i in range(5):
        x = cx - s * 0.7 + i * s * 0.35
        d.line([x, cy - s * 0.45, x + s * 0.18, cy + s * 0.28], fill=GOLD, width=3)


def em_amphora(d, c, s, col, col2):
    cx, cy = c
    d.ellipse([cx - s * 0.6, cy - s * 0.5, cx + s * 0.6, cy + s * 0.85], fill=col)
    d.rectangle([cx - s * 0.22, cy - s * 0.95, cx + s * 0.22, cy - s * 0.35], fill=col)
    d.ellipse([cx - s * 0.32, cy - s * 1.02, cx + s * 0.32, cy - s * 0.82], fill=col2)
    for sign in (-1, 1):
        d.arc([cx + sign * s * 0.2 - s * 0.45, cy - s * 0.75, cx + sign * s * 0.2 + s * 0.45, cy - s * 0.1],
              270 if sign > 0 else 90, 90 if sign > 0 else 270, fill=col2, width=int(s * 0.12))
    d.line([cx - s * 0.5, cy + s * 0.1, cx + s * 0.5, cy + s * 0.1], fill=col2, width=int(s * 0.1))


def em_wings(d, c, s, col, col2):
    cx, cy = c
    for sign in (-1, 1):
        for i in range(4):
            k = 1 - i * 0.2
            d.polygon([(cx + sign * s * 0.12, cy - s * 0.25 + i * s * 0.26),
                       (cx + sign * s * 1.05 * k, cy - s * 0.05 + i * s * 0.24),
                       (cx + sign * s * 0.12, cy + s * 0.1 + i * s * 0.26)],
                      fill=col if i % 2 == 0 else col2)
    d.ellipse([cx - s * 0.16, cy - s * 0.62, cx + s * 0.16, cy - s * 0.22], fill=GOLD)


def em_shield(d, c, s, col, col2):
    cx, cy = c
    d.polygon([(cx - s * 0.8, cy - s * 0.8), (cx + s * 0.8, cy - s * 0.8),
               (cx + s * 0.7, cy + s * 0.35), (cx, cy + s * 0.95), (cx - s * 0.7, cy + s * 0.35)], fill=col)
    d.polygon([(cx - s * 0.5, cy - s * 0.5), (cx + s * 0.5, cy - s * 0.5),
               (cx + s * 0.44, cy + s * 0.2), (cx, cy + s * 0.62), (cx - s * 0.44, cy + s * 0.2)], fill=col2)
    star(d, (cx, cy - s * 0.02), 5, s * 0.32, s * 0.14, GOLD)


def em_bolt(d, c, s, col, col2):
    cx, cy = c
    rays(d, c, 10, s * 0.4, s * 1.05, col2)
    d.polygon([(cx + s * 0.18, cy - s * 0.95), (cx - s * 0.55, cy + s * 0.12),
               (cx - s * 0.08, cy + s * 0.12), (cx - s * 0.26, cy + s * 0.95),
               (cx + s * 0.55, cy - s * 0.16), (cx + s * 0.06, cy - s * 0.16)], fill=col, outline=GOLD_DK)


EMBLEMS = {
    'sunburst': em_sunburst, 'star': em_star, 'pyramid': em_pyramid, 'wheel': em_wheel,
    'waves': em_waves, 'gem': em_gem, 'crown': em_crown, 'key': em_key, 'anchor': em_anchor,
    'bell': em_bell, 'flame': em_flame, 'coins': em_coins, 'leaf': em_leaf, 'horns': em_horns,
    'seven': em_seven, 'lantern': em_lantern, 'chest': em_chest, 'drum': em_drum,
    'amphora': em_amphora, 'wings': em_wings, 'shield': em_shield, 'bolt': em_bolt,
}


# ----------------------------------------------------------------------
# themes — one per noun used by the title generator, plus the table games
# (theme, emblem, bg top, bg bottom, emblem main, emblem shade, glow)
# ----------------------------------------------------------------------
THEMES = [
    ('feniks',   'flame',    (86, 18, 10),  (18, 6, 10),   (255, 138, 40),  (214, 70, 22),  (255, 120, 30)),
    ('zmaj',     'horns',    (10, 48, 40),  (5, 14, 18),   (58, 214, 148),  (22, 140, 96),  (30, 200, 140)),
    ('hram',     'pyramid',  (78, 56, 12),  (20, 12, 6),   (255, 208, 92),  (198, 140, 30),  (255, 190, 60)),
    ('rudnik',   'gem',      (18, 32, 66),  (6, 10, 22),   (110, 200, 255), (40, 110, 190),  (60, 150, 255)),
    ('karavan',  'lantern',  (74, 44, 10),  (22, 12, 6),   (255, 186, 74),  (186, 118, 24),  (255, 170, 60)),
    ('sedam',    'seven',    (72, 12, 20),  (16, 6, 10),   (255, 214, 92),  (200, 40, 52),   (255, 90, 70)),
    ('kotac',    'wheel',    (46, 16, 66),  (12, 6, 22),   (255, 196, 72),  (128, 60, 190),  (170, 90, 255)),
    ('piramida', 'pyramid',  (70, 52, 14),  (16, 12, 6),   (255, 220, 120), (190, 138, 36),  (255, 200, 80)),
    ('vitez',    'shield',   (24, 30, 58),  (8, 10, 20),   (196, 208, 232), (108, 126, 168), (120, 150, 230)),
    ('grom',     'bolt',     (28, 24, 70),  (8, 8, 22),    (255, 226, 96),  (96, 90, 200),   (140, 130, 255)),
    ('delfin',   'waves',    (10, 46, 72),  (4, 12, 24),   (96, 206, 255),  (30, 120, 186),  (50, 160, 255)),
    ('vulkan',   'flame',    (72, 20, 8),   (14, 6, 6),    (255, 128, 46),  (196, 52, 20),   (255, 100, 30)),
    ('safir',    'gem',      (16, 26, 74),  (5, 8, 24),    (120, 160, 255), (48, 74, 190),   (70, 110, 255)),
    ('kompas',   'sunburst', (14, 40, 52),  (5, 12, 18),   (255, 210, 110), (40, 130, 140),  (60, 190, 200)),
    ('galeb',    'wings',    (26, 52, 78),  (8, 14, 26),   (226, 238, 252), (120, 156, 196), (110, 170, 240)),
    ('jelen',    'horns',    (58, 40, 14),  (14, 10, 6),   (236, 196, 120), (160, 112, 44),  (220, 160, 70)),
    ('maslina',  'leaf',     (22, 48, 22),  (6, 14, 8),    (150, 214, 110), (74, 140, 60),   (110, 200, 90)),
    ('sidro',    'anchor',   (12, 36, 60),  (4, 10, 20),   (206, 226, 246), (92, 134, 178),  (70, 140, 210)),
    ('lampion',  'lantern',  (66, 18, 30),  (16, 6, 12),   (255, 168, 92),  (190, 58, 62),   (255, 130, 80)),
    ('kovceg',   'chest',    (60, 38, 10),  (14, 10, 6),   (178, 118, 46),  (120, 74, 26),   (255, 180, 60)),
    ('bubanj',   'drum',     (64, 26, 14),  (16, 8, 6),    (214, 118, 62),  (150, 72, 34),   (240, 140, 70)),
    ('kraljica', 'crown',    (54, 14, 58),  (14, 5, 18),   (255, 206, 96),  (156, 52, 160),  (210, 90, 240)),
    ('amfora',   'amphora',  (58, 40, 18),  (14, 10, 8),   (216, 158, 88),  (146, 96, 44),   (230, 170, 80)),
    ('otok',     'waves',    (12, 54, 56),  (4, 14, 18),   (96, 220, 200),  (28, 132, 128),  (50, 200, 180)),
    ('zvono',    'bell',     (60, 46, 10),  (14, 12, 5),   (255, 206, 84),  (176, 130, 28),  (255, 190, 60)),
    ('kljuc',    'key',      (48, 20, 62),  (12, 6, 20),   (255, 202, 96),  (132, 62, 176),  (190, 100, 250)),
    ('krila',    'wings',    (18, 34, 70),  (6, 10, 22),   (232, 240, 255), (112, 140, 210), (110, 150, 255)),
    ('tigar',    'star',     (78, 42, 8),   (18, 10, 5),   (255, 168, 40),  (188, 96, 16),   (255, 150, 40)),
    ('orao',     'wings',    (58, 40, 14),  (14, 10, 6),   (244, 214, 150), (160, 118, 52),  (230, 170, 80)),
    ('val',      'waves',    (10, 40, 76),  (4, 10, 26),   (86, 178, 255),  (26, 96, 178),   (50, 140, 255)),

    # table / instant games
    ('roulette', 'wheel',    (56, 12, 14),  (14, 5, 8),    (255, 200, 80),  (150, 26, 30),   (230, 60, 60)),
    ('blackjack','shield',   (10, 44, 26),  (4, 14, 10),   (232, 238, 244), (28, 120, 74),   (40, 180, 110)),
    ('crash',    'bolt',     (58, 30, 6),   (14, 8, 5),    (255, 206, 72),  (196, 108, 20),  (255, 160, 40)),
    ('mines',    'gem',      (46, 12, 40),  (12, 5, 14),   (255, 120, 150), (150, 40, 96),   (220, 70, 130)),
    ('dice',     'star',     (14, 34, 62),  (5, 10, 20),   (226, 234, 246), (60, 104, 168),  (70, 130, 220)),
    ('wheel',    'wheel',    (46, 16, 66),  (12, 6, 22),   (255, 196, 72),  (128, 60, 190),  (170, 90, 255)),
    ('baccarat', 'crown',    (46, 10, 24),  (12, 4, 10),   (255, 214, 120), (146, 30, 60),   (220, 70, 100)),
    ('default',  'sunburst', (30, 34, 58),  (8, 10, 20),   (255, 206, 96),  (90, 100, 160),  (120, 140, 230)),
]


def build(theme, emblem, top, bottom, main, shade, glow):
    img = Image.new('RGB', (W, H), bottom)
    vertical_gradient(img, top, bottom)

    # soft coloured glow behind the emblem
    layer = Image.new('RGB', (W, H), (0, 0, 0))
    ld = ImageDraw.Draw(layer)
    cx, cy = W // 2, int(H * 0.42)
    for i in range(24, 0, -1):
        r = 190 * i / 24
        ld.ellipse([cx - r, cy - r, cx + r, cy + r], fill=lerp((0, 0, 0), glow, (1 - i / 24) ** 2))
    layer = layer.filter(ImageFilter.GaussianBlur(34))
    img = screen_layer(img, layer, 0.55)

    d = ImageDraw.Draw(img, 'RGBA')

    # faint diagonal texture
    for i in range(-H, W, 26):
        d.line([(i, 0), (i + H, H)], fill=(255, 255, 255, 8), width=9)

    EMBLEMS[emblem](d, (cx, cy), 96, main, shade)

    # vignette + bottom scrim so the title stays readable
    scrim = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(scrim)
    for i in range(150):
        y = H - 150 + i
        sd.line([(0, y), (W, y)], fill=(0, 0, 0, int(190 * (i / 150) ** 1.5)))
    img = Image.alpha_composite(img.convert('RGBA'), scrim).convert('RGB')

    d = ImageDraw.Draw(img, 'RGBA')
    d.rectangle([0, 0, W - 1, H - 1], outline=(255, 255, 255, 26), width=2)
    return img


def main():
    if not os.path.isdir('client'):
        sys.exit('Run this from the repository root (the folder containing client/).')

    os.makedirs(OUT_DIR, exist_ok=True)
    total = 0
    for spec in THEMES:
        img = build(*spec)
        path = os.path.join(OUT_DIR, spec[0] + '.jpg')
        img.save(path, quality=84, optimize=True)
        total += os.path.getsize(path)
        print(f'  {spec[0]:12s} {os.path.getsize(path) / 1024:6.1f} KB')

    print(f'{len(THEMES)} covers, {total / 1024:.0f} KB total -> {OUT_DIR}')


if __name__ == '__main__':
    main()
