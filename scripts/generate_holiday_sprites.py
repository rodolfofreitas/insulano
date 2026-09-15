#!/usr/bin/env python3
"""Gerador de sprites de feriado para Insulano (pixel art 16x16).

Gera em Python/Pillow (sem ComfyUI), estilo pixel art indie consistente com
a paleta da ilha. Todos os sprites saem em game/object/.

Sprites criados:
  gorro_natal.png           16x16  gorro vermelho com pompom branco
  estrela_natal.png         16x16  estrela amarela de 5 pontas
  fogo_artificio.png        16x16  explosão colorida de pontos

Aliases de backlog (criteria T-609):
  holiday_xmas_tree.png     16x24  árvore de Natal verde com estrela
  holiday_xmas_star.png     16x16  cópia de estrela_natal.png
  holiday_newyear_firework.png 16x16 cópia de fogo_artificio.png
  holiday_newyear_bottle.png   8x16 garrafa de champanhe pixel art

Versões 4x upscaled:
  *_4x.png para cada sprite acima (geradas com nearest-neighbour)

Uso:
    python3 scripts/generate_holiday_sprites.py
    python3 scripts/generate_holiday_sprites.py --out-dir /tmp/sprites
"""

from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "game" / "object"


# ---------------------------------------------------------------------------
# Paleta
# ---------------------------------------------------------------------------
TRANSPARENT = (0, 0, 0, 0)
RED         = (200,  40,  40, 255)
RED_DARK    = (140,  20,  20, 255)
WHITE       = (255, 255, 255, 255)
WHITE_SOFT  = (240, 240, 230, 255)
YELLOW      = (255, 215,   0, 255)
GOLD        = (218, 165,  32, 255)
GREEN       = ( 34, 139,  34, 255)
GREEN_DARK  = ( 20,  80,  20, 255)
GREEN_LIGHT = ( 80, 200,  80, 255)
BLUE        = ( 70, 130, 180, 255)
MAGENTA     = (200,  50, 180, 255)
BROWN       = (101,  67,  33, 255)
ORANGE      = (255, 120,   0, 255)


# ---------------------------------------------------------------------------
# Utilitários
# ---------------------------------------------------------------------------

def new_img(w: int, h: int) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    return img, ImageDraw.Draw(img)


def upscale_4x(src: Path, dest: Path | None = None) -> Path:
    """Upscale nearest-neighbour 4x."""
    img = Image.open(src).convert("RGBA")
    w, h = img.size
    big = img.resize((w * 4, h * 4), Image.Resampling.NEAREST)
    if dest is None:
        dest = src.parent / f"{src.stem}_4x{src.suffix}"
    big.save(dest)
    return dest


def save(img: Image.Image, path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    up = upscale_4x(path)
    print(f"  {path.name} ({img.width}x{img.height})  →  {up.name} (upscale 4x)")
    return path


# ---------------------------------------------------------------------------
# Sprite: gorro de Natal (16x16) - triângulo vermelho com pompom branco
# ---------------------------------------------------------------------------

def make_gorro_natal(w: int = 16, h: int = 16) -> Image.Image:
    img, d = new_img(w, h)

    # aba branca em baixo (2px de altura, largura quase total)
    d.rectangle([2, 13, 13, 15], fill=WHITE_SOFT)
    d.rectangle([3, 14, 12, 15], fill=WHITE)

    # corpo do gorro - triângulo de baixo para cima
    # row 12: 3..12  (10px)
    # row 11: 4..11  (8px)
    # row 10: 5..11  (7px)
    # row  9: 5..10  (6px)
    # row  8: 6..10  (5px)
    # row  7: 6.. 9  (4px)
    # row  6: 7.. 9  (3px)
    # row  5: 7.. 8  (2px)
    # row  4: 8.. 8  (1px - ponta)
    layers = [
        (12,  3, 12),
        (11,  4, 11),
        (10,  5, 11),
        ( 9,  5, 10),
        ( 8,  6, 10),
        ( 7,  6,  9),
        ( 6,  7,  9),
        ( 5,  7,  8),
        ( 4,  8,  8),
    ]
    for row, x0, x1 in layers:
        d.line([(x0, row), (x1, row)], fill=RED)

    # sombra no lado esquerdo (escurece 1 pixel)
    shadow_rows = [(12, 3), (11, 4), (10, 5), (9, 5), (8, 6), (7, 6)]
    for row, x0 in shadow_rows:
        d.point((x0, row), fill=RED_DARK)

    # pompom branco no topo
    d.point((8, 2), fill=WHITE)
    d.point((7, 2), fill=WHITE_SOFT)
    d.point((9, 2), fill=WHITE_SOFT)
    d.point((8, 3), fill=WHITE_SOFT)

    return img


# ---------------------------------------------------------------------------
# Sprite: estrela de 5 pontas (16x16) - amarela/dourada
# ---------------------------------------------------------------------------

def make_estrela_natal(w: int = 16, h: int = 16) -> Image.Image:
    img, d = new_img(w, h)

    cx, cy = 7.5, 7.5
    outer_r = 7.0
    inner_r = 3.0
    points: list[tuple[int, int]] = []
    for i in range(10):
        angle = math.radians(-90 + i * 36)
        r = outer_r if i % 2 == 0 else inner_r
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        points.append((int(round(x)), int(round(y))))

    d.polygon(points, fill=YELLOW, outline=GOLD)

    # brilho interno (ponto central)
    d.point((7, 7), fill=WHITE_SOFT)
    d.point((8, 7), fill=WHITE_SOFT)

    return img


# ---------------------------------------------------------------------------
# Sprite: fogo de artifício (16x16) - explosão colorida
# ---------------------------------------------------------------------------

def make_fogo_artificio(w: int = 16, h: int = 16) -> Image.Image:
    img, d = new_img(w, h)

    cx, cy = 7, 7

    # raios em 8 direcções com 3 cores alternadas
    colours = [
        (255,  60,  60, 255),   # vermelho
        ( 60, 200,  60, 255),   # verde
        (218, 165,  32, 255),   # dourado
        (255, 200,  60, 255),   # amarelo
        (100, 200, 255, 255),   # azul claro
        (255, 100, 200, 255),   # rosa
        (255, 165,   0, 255),   # laranja
        (180, 100, 255, 255),   # violeta
    ]

    angles = [i * 45 for i in range(8)]
    lengths = [5, 4, 5, 4, 5, 4, 5, 4]

    for angle, length, colour in zip(angles, lengths, colours):
        rad = math.radians(angle)
        for step in range(1, length + 1):
            px = cx + int(round(step * math.cos(rad)))
            py = cy + int(round(step * math.sin(rad)))
            if 0 <= px < w and 0 <= py < h:
                d.point((px, py), fill=colour)
        # ponta brilhante
        px = cx + int(round(length * math.cos(rad)))
        py = cy + int(round(length * math.sin(rad)))
        if 0 <= px < w and 0 <= py < h:
            d.point((px, py), fill=WHITE)

    # centro brilhante
    d.point((cx,     cy),     fill=WHITE)
    d.point((cx + 1, cy),     fill=YELLOW)
    d.point((cx,     cy + 1), fill=YELLOW)
    d.point((cx - 1, cy),     fill=GOLD)
    d.point((cx,     cy - 1), fill=GOLD)

    return img


# ---------------------------------------------------------------------------
# Sprite: árvore de Natal (16x24) - verde com tronco e estrela no topo
# ---------------------------------------------------------------------------

def make_xmas_tree(w: int = 16, h: int = 24) -> Image.Image:
    img, d = new_img(w, h)

    # tronco
    d.rectangle([6, 20, 9, 23], fill=BROWN)

    # três camadas da árvore (triângulos sobrepostos)
    # camada inferior (mais larga)
    for row, x0, x1 in [
        (18,  2, 13), (17,  3, 12), (16,  4, 11), (15,  5, 10),
        (14,  6,  9),
    ]:
        d.line([(x0, row), (x1, row)], fill=GREEN)
        d.point((x0, row), fill=GREEN_DARK)

    # camada média
    for row, x0, x1 in [
        (14,  3, 12), (13,  4, 11), (12,  5, 10),
        (11,  6,  9),
    ]:
        d.line([(x0, row), (x1, row)], fill=GREEN)
        d.point((x0, row), fill=GREEN_DARK)

    # camada superior
    for row, x0, x1 in [
        (11,  4, 11), (10,  5, 10), ( 9,  6,  9),
        ( 8,  7,  8),
    ]:
        d.line([(x0, row), (x1, row)], fill=GREEN)
        d.point((x0, row), fill=GREEN_DARK)

    # decorações (pontos coloridos)
    decorations = [
        (16, 6, (255, 0, 0, 255)),
        (15, 9, (255, 215, 0, 255)),
        (14, 5, (0, 150, 255, 255)),
        (13, 8, (255, 100, 200, 255)),
        (12, 6, (255, 165, 0, 255)),
        (11, 9, (255, 0, 0, 255)),
        (10, 7, (0, 200, 0, 255)),
    ]
    for row, col, colour in decorations:
        if 0 <= col < w and 0 <= row < h:
            d.point((col, row), fill=colour)

    # estrela no topo (pequena, amarela)
    d.point((7, 6), fill=YELLOW)
    d.point((8, 6), fill=YELLOW)
    d.point((7, 5), fill=GOLD)
    d.point((8, 5), fill=GOLD)
    d.point((6, 6), fill=GOLD)
    d.point((9, 6), fill=GOLD)

    return img


# ---------------------------------------------------------------------------
# Sprite: garrafa de champanhe (8x16) - verde com rolha
# ---------------------------------------------------------------------------

def make_garrafa_champanhe(w: int = 8, h: int = 16) -> Image.Image:
    img, d = new_img(w, h)

    # rolha
    d.rectangle([3, 0, 4, 2], fill=WHITE_SOFT)

    # gargalo
    d.rectangle([2, 2, 5, 5], fill=GREEN_DARK)

    # corpo da garrafa
    d.rectangle([1, 5, 6, 14], fill=GREEN)

    # destaque (reflexo de luz)
    d.line([(2, 6), (2, 12)], fill=GREEN_LIGHT)

    # base
    d.rectangle([1, 14, 6, 15], fill=GREEN_DARK)

    # tampa de metal (capsule) sobre o gargalo
    d.rectangle([2, 2, 5, 3], fill=GOLD)

    # borbulhas
    d.point((4,  8), fill=WHITE_SOFT)
    d.point((3, 11), fill=WHITE_SOFT)
    d.point((5,  9), fill=WHITE_SOFT)

    return img


# ---------------------------------------------------------------------------
# Composição da prova (proof screenshot)
# ---------------------------------------------------------------------------

def make_proof_image(sprites: list[tuple[str, Image.Image]], out_path: Path) -> None:
    """Combina todos os sprites numa imagem de prova lado a lado (upscaled 4x)."""
    scale = 4
    padding = 8
    label_h = 12
    max_h = max(s.height for _, s in sprites)

    cell_w = 16 * scale + padding * 2
    total_w = cell_w * len(sprites) + padding
    total_h = max_h * scale + padding * 2 + label_h

    bg = Image.new("RGBA", (total_w, total_h), (30, 30, 40, 255))
    d = ImageDraw.Draw(bg)

    for i, (name, spr) in enumerate(sprites):
        up = spr.resize((spr.width * scale, spr.height * scale), Image.Resampling.NEAREST)
        x = padding + i * cell_w
        # centrar verticalmente
        y_offset = (max_h - spr.height) * scale // 2 + padding
        bg.paste(up, (x, y_offset), up)
        # label
        short = name.replace("_4x", "").replace(".png", "")[:14]
        d.text((x, total_h - label_h - 1), short, fill=(200, 200, 200, 255))

    out_path.parent.mkdir(parents=True, exist_ok=True)
    bg.save(out_path)
    print(f"  prova → {out_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out-dir", default=str(OUT_DIR),
                        help="directório de destino (default: game/object)")
    args = parser.parse_args(argv)

    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)

    print("Gerando sprites de feriado…")

    # Sprites pedidos pela tarefa
    sprites_task = [
        ("gorro_natal.png",    make_gorro_natal()),
        ("estrela_natal.png",  make_estrela_natal()),
        ("fogo_artificio.png", make_fogo_artificio()),
    ]

    # Sprites adicionais para os critérios de backlog T-609
    xmas_tree  = make_xmas_tree()
    champanhe  = make_garrafa_champanhe()

    sprites_backlog = [
        ("holiday_xmas_tree.png",            xmas_tree),
        ("holiday_xmas_star.png",            make_estrela_natal()),   # alias
        ("holiday_newyear_firework.png",     make_fogo_artificio()),  # alias
        ("holiday_newyear_bottle.png",       champanhe),
    ]

    all_sprites = sprites_task + sprites_backlog

    for name, img in all_sprites:
        save(img, out / name)

    # Prova visual
    proof_out = ROOT / "docs" / "proof" / "T-609-sprites-feriados.png"
    make_proof_image(all_sprites, proof_out)

    print("\nSprings gerados com sucesso.")
    print(f"Directório: {out}")
    print(f"Prova:      {proof_out}")


if __name__ == "__main__":
    main()
