#!/usr/bin/env python3
"""Gera os sprites dos objectos do companheiro - lote 2 (boia, pedra, capacete, vela).

Dimensoes: 16x24 px, RGBA, pixel art estilo Stardew Valley / Graveyard Keeper.

Uso:
    python3 scripts/generate_companion_sprites_lote2.py [output_dir]

Por omissao, grava em game/object/.
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw

# ---------------------------------------------------------------------------
# Paleta partilhada
# ---------------------------------------------------------------------------
TRANSPARENT = (0, 0, 0, 0)
WHITE = (255, 255, 255, 255)
BLACK = (20, 20, 20, 255)

# Boia
BOIA_ORANGE = (220, 80, 30, 255)
BOIA_RED = (180, 30, 20, 255)
BOIA_DARK = (120, 20, 10, 255)

# Capacete
HELM_OD = (78, 93, 50, 255)        # verde oliva
HELM_DARK = (50, 60, 30, 255)
HELM_LIGHT = (110, 130, 70, 255)

# Pedra
STONE_MID = (130, 130, 130, 255)
STONE_LIGHT = (175, 175, 175, 255)
STONE_DARK = (85, 85, 85, 255)
STONE_EYE = (40, 40, 40, 255)
STONE_MOUTH = (60, 30, 30, 255)

# Vela
SAIL_WHITE = (245, 245, 240, 255)
SAIL_SHADOW = (200, 195, 185, 255)
SAIL_TEAR = (160, 155, 145, 255)
MAST_BROWN = (100, 70, 40, 255)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def new_canvas(w: int = 16, h: int = 24) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    return img, ImageDraw.Draw(img)


def px(draw: ImageDraw.ImageDraw, x: int, y: int, colour) -> None:
    draw.point((x, y), fill=colour)


def hline(draw: ImageDraw.ImageDraw, y: int, x0: int, x1: int, colour) -> None:
    for x in range(x0, x1 + 1):
        draw.point((x, y), fill=colour)


def vline(draw: ImageDraw.ImageDraw, x: int, y0: int, y1: int, colour) -> None:
    for y in range(y0, y1 + 1):
        draw.point((x, y), fill=colour)


def rect(draw: ImageDraw.ImageDraw, x0, y0, x1, y1, colour) -> None:
    draw.rectangle([x0, y0, x1, y1], fill=colour)


# ---------------------------------------------------------------------------
# Sprite: boia  (16x24)
# Aro laranja/vermelho com cruz branca - lembra uma boia de salvamento
# ---------------------------------------------------------------------------

def make_boia() -> Image.Image:
    img, draw = new_canvas()

    # Aro externo (circulo ~12px de diametro centrado em 8,12)
    cx, cy, r = 8, 12, 6

    # Pixels do aro: desenhamos "quarteis" alternando laranja e vermelho
    ring_pixels = []
    for y in range(2, 23):
        for x in range(1, 15):
            dx = x - cx
            dy = y - cy
            dist2 = dx * dx + dy * dy
            if 16 <= dist2 <= 36:            # anel entre r=4 e r=6
                ring_pixels.append((x, y, dx, dy))

    for x, y, dx, dy in ring_pixels:
        # Quatro quadrantes alternando cor
        if (dx >= 0 and dy >= 0) or (dx < 0 and dy < 0):
            colour = BOIA_ORANGE
        else:
            colour = BOIA_RED
        # Contorno escuro no bordo exterior
        if dx * dx + dy * dy >= 34:
            colour = BOIA_DARK
        draw.point((x, y), fill=colour)

    # Cruz branca dentro do aro (horizontal e vertical, espessura 2)
    # horizontal: y=11,12, x=3..13
    for y in (11, 12):
        for x in range(3, 14):
            dx = x - cx
            dy = y - cy
            if dx * dx + dy * dy <= 15:      # so dentro do buraco
                draw.point((x, y), fill=WHITE)
    # vertical: x=7,8, y=3..21
    for x in (7, 8):
        for y in range(3, 22):
            dx = x - cx
            dy = y - cy
            if dx * dx + dy * dy <= 15:
                draw.point((x, y), fill=WHITE)

    # Sombra subtil por baixo
    for x in range(5, 12):
        draw.point((x, 20), fill=BOIA_DARK)

    return img


# ---------------------------------------------------------------------------
# Sprite: capacete  (16x24)
# Capacete militar verde oliva - forma de domo com aba
# ---------------------------------------------------------------------------

def make_capacete() -> Image.Image:
    img, draw = new_canvas()

    # Domo principal (7 linhas de altura, centrado em x=7.5)
    dome_rows = [
        (5, 10),   # y=5
        (3, 12),   # y=6
        (2, 13),   # y=7
        (1, 14),   # y=8
        (1, 14),   # y=9
        (1, 14),   # y=10
        (1, 14),   # y=11
        (2, 13),   # y=12
    ]
    for i, (x0, x1) in enumerate(dome_rows):
        y = 5 + i
        for x in range(x0, x1 + 1):
            if x == x0 or x == x1:
                c = HELM_DARK
            elif y == 5 or (y == 6 and x in range(x0 + 1, x0 + 4)):
                c = HELM_LIGHT   # reflexo de luz em cima
            else:
                c = HELM_OD
            draw.point((x, y), fill=c)

    # Aba do capacete (mais larga, y=13)
    hline(draw, 13, 0, 15, HELM_DARK)
    hline(draw, 14, 1, 14, HELM_OD)
    # Linha de contorno abaixo da aba
    hline(draw, 15, 2, 13, HELM_DARK)

    # Faixa/banda ao meio do capacete
    hline(draw, 9, 3, 12, HELM_LIGHT)

    # Correia do queixo (dois pixels por lado, y=14-18)
    for y in range(15, 20):
        draw.point((3, y), fill=HELM_DARK)
        draw.point((12, y), fill=HELM_DARK)
    # Fivela no meio em baixo
    rect(draw, 6, 19, 9, 20, HELM_DARK)
    rect(draw, 7, 19, 8, 20, HELM_OD)

    return img


# ---------------------------------------------------------------------------
# Sprite: pedra_com_cara  (16x24)
# Circulo cinzento com olhos e boca - Wilson style
# ---------------------------------------------------------------------------

def make_pedra_com_cara() -> Image.Image:
    img, draw = new_canvas()

    # Corpo da pedra: elipse ligeiramente achatada
    # Preencher pixel a pixel para controlo total
    cx, cy = 8, 12
    rx, ry = 7, 8

    for y in range(2, 23):
        for x in range(0, 16):
            dx = (x - cx) / rx
            dy = (y - cy) / ry
            d = dx * dx + dy * dy
            if d <= 1.0:
                # Cor base: gradiente claro em cima/esq
                if d <= 0.25 and (x - cx) <= 0 and (y - cy) <= 0:
                    c = STONE_LIGHT
                elif d >= 0.85:
                    c = STONE_DARK
                else:
                    c = STONE_MID
                draw.point((x, y), fill=c)

    # Contorno escuro
    for y in range(2, 23):
        for x in range(0, 16):
            dx = (x - cx) / rx
            dy = (y - cy) / ry
            d = dx * dx + dy * dy
            if 0.92 <= d <= 1.08:
                draw.point((x, y), fill=STONE_DARK)

    # Olhos: dois pontinhos escuros  (y=10, x=5 e x=11)
    for ex, ey in [(5, 10), (6, 10), (10, 10), (11, 10)]:
        draw.point((ex, ey), fill=STONE_EYE)
    for ex, ey in [(5, 9), (10, 9)]:
        draw.point((ex, ey), fill=STONE_EYE)

    # Sobrancelhas: linha escura acima dos olhos
    hline(draw, 8, 4, 7, STONE_DARK)
    hline(draw, 8, 9, 12, STONE_DARK)

    # Boca: curva em U simples (sorriso triste)
    for x, y in [(4, 14), (5, 15), (6, 16), (7, 16), (8, 16), (9, 16), (10, 15), (11, 14)]:
        draw.point((x, y), fill=STONE_MOUTH)

    return img


# ---------------------------------------------------------------------------
# Sprite: vela_partida  (16x24)
# Triangulo branco rasgado a meio - mastro + vela com corte irregular
# ---------------------------------------------------------------------------

def make_vela_partida() -> Image.Image:
    img, draw = new_canvas()

    # Mastro: 2px de largura, do y=1 ao y=22
    for y in range(1, 23):
        draw.point((7, y), fill=MAST_BROWN)
        draw.point((8, y), fill=MAST_BROWN)

    # Metade superior da vela (intacta)
    # Triangulo: topo em (7,2), expande para a direita ate y=10
    for y in range(2, 11):
        width = (y - 2) * 1          # expande 1px por linha
        x_right = 8 + width
        for x in range(9, x_right + 1):
            if x == x_right:
                c = SAIL_SHADOW
            else:
                c = SAIL_WHITE
            draw.point((x, y), fill=c)

    # Bordo da vela superior (contorno)
    for y in range(2, 11):
        x_right = 8 + (y - 2)
        draw.point((x_right + 1, y), fill=SAIL_SHADOW)

    # Rasgao/corte: linha diagonal irregular y=11-13
    for x, y in [(9, 11), (10, 11), (11, 12), (10, 12), (9, 13)]:
        draw.point((x, y), fill=SAIL_TEAR)

    # Metade inferior da vela (rasgada - mais estreita e irregular)
    for y in range(13, 21):
        base_width = 10 - (y - 13)          # encolhe
        if base_width <= 0:
            break
        x_right = 8 + base_width
        for x in range(9, x_right + 1):
            c = SAIL_SHADOW if x == x_right else SAIL_WHITE
            draw.point((x, y), fill=c)
        # Bordo rasgado irregular
        if y % 2 == 0:
            draw.point((x_right + 1, y), fill=SAIL_TEAR)

    # Pequena base do mastro
    rect(draw, 5, 22, 10, 23, MAST_BROWN)

    return img


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

SPRITES = {
    "companion_boia.png": make_boia,
    "companion_capacete.png": make_capacete,
    "companion_pedra.png": make_pedra_com_cara,
    "companion_vela.png": make_vela_partida,
}


def main() -> None:
    out_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("game/object")
    out_dir.mkdir(parents=True, exist_ok=True)

    for filename, factory in SPRITES.items():
        img = factory()
        dest = out_dir / filename
        img.save(dest)
        print(f"Guardado: {dest}  ({img.size[0]}x{img.size[1]} {img.mode})")

    print(f"\nLote 2 concluido: {len(SPRITES)} sprites em {out_dir}/")


if __name__ == "__main__":
    main()
