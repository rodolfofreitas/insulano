#!/usr/bin/env python3
"""Gera sprites de animais visitantes e efeitos de particulas (16x16px, pixel art).

Usa: python3 scripts/generate_animal_sprites.py
Saida:
  game/character/seagull.png  (gaivota)
  game/character/dolphin.png  (golfinho)
  game/character/turtle.png   (tartaruga)
  game/character/crab.png     (caranguejo)
  game/effect/rain_particle.png
  game/effect/shooting_star.png
  game/effect/bioluminescence.png
  docs/proof/T-607-animais-visitantes.png  (prova visual 4x upscale)
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]

# ---------------------------------------------------------------------------
# Paleta de cores
# ---------------------------------------------------------------------------
TRANSPARENT = (0, 0, 0, 0)
WHITE = (255, 255, 255, 255)
LIGHT_GRAY = (200, 200, 200, 255)
GRAY = (140, 140, 150, 255)
DARK_GRAY = (80, 80, 90, 255)
BLACK = (20, 20, 20, 255)
ORANGE = (220, 110, 30, 255)
ORANGE_DARK = (160, 70, 20, 255)
ORANGE_LIGHT = (255, 160, 60, 255)
TEAL = (90, 140, 170, 255)
TEAL_LIGHT = (130, 180, 200, 255)
TEAL_DARK = (50, 90, 120, 255)
GREEN = (80, 140, 60, 255)
GREEN_DARK = (50, 90, 40, 255)
YELLOW = (230, 210, 50, 255)


def new_canvas(w: int = 16, h: int = 16) -> Image.Image:
    return Image.new("RGBA", (w, h), TRANSPARENT)


def put(img: Image.Image, pixels: list[tuple[int, int, int, int, int, int]]) -> None:
    """pixels: list of (x, y, r, g, b, a)."""
    data = img.load()
    for x, y, r, g, b, a in pixels:
        if 0 <= x < img.width and 0 <= y < img.height:
            data[x, y] = (r, g, b, a)


def fill_rect(
    img: Image.Image,
    x0: int,
    y0: int,
    x1: int,
    y1: int,
    color: tuple[int, int, int, int],
) -> None:
    data = img.load()
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < img.width and 0 <= y < img.height:
                data[x, y] = color


def set_pixel(img: Image.Image, x: int, y: int, color: tuple[int, int, int, int]) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        data = img.load()
        data[x, y] = color


# ---------------------------------------------------------------------------
# Gaivota (16x16) - corpo branco oval, cabeca pequena, asas cinzentas
# ---------------------------------------------------------------------------
def make_seagull() -> Image.Image:
    img = new_canvas(16, 16)

    # corpo oval branco (linhas 6-12, cols 3-13)
    body_rows = {
        6: (6, 10),
        7: (4, 12),
        8: (3, 13),
        9: (3, 13),
        10: (4, 12),
        11: (5, 11),
        12: (6, 10),
    }
    for row, (c0, c1) in body_rows.items():
        fill_rect(img, c0, row, c1, row, WHITE)

    # cabeca pequena (linhas 3-6, cols 7-10)
    head_rows = {
        3: (8, 9),
        4: (7, 10),
        5: (7, 10),
        6: (8, 9),
    }
    for row, (c0, c1) in head_rows.items():
        fill_rect(img, c0, row, c1, row, WHITE)

    # olho preto
    set_pixel(img, 10, 4, BLACK)

    # bico laranja (apontado para a direita)
    set_pixel(img, 11, 5, ORANGE)
    set_pixel(img, 12, 5, ORANGE)

    # asa esquerda - cinzenta (linhas 7-10, cols 1-5)
    wing_l = {7: (1, 3), 8: (1, 4), 9: (2, 4), 10: (3, 5)}
    for row, (c0, c1) in wing_l.items():
        fill_rect(img, c0, row, c1, row, GRAY)

    # asa direita - cinzenta (linhas 7-10, cols 11-15)
    wing_r = {7: (12, 14), 8: (11, 14), 9: (10, 13), 10: (9, 12)}
    for row, (c0, c1) in wing_r.items():
        fill_rect(img, c0, row, c1, row, GRAY)

    # pontas das asas mais escuras
    for x, y in [(1, 8), (1, 9), (14, 7), (14, 8)]:
        set_pixel(img, x, y, DARK_GRAY)

    # cauda (linhas 12-13, cols 7-9)
    fill_rect(img, 7, 12, 9, 12, LIGHT_GRAY)
    fill_rect(img, 8, 13, 8, 13, LIGHT_GRAY)

    # patas laranja (linhas 13-14)
    set_pixel(img, 6, 13, ORANGE)
    set_pixel(img, 9, 13, ORANGE)
    set_pixel(img, 5, 14, ORANGE)
    set_pixel(img, 10, 14, ORANGE)

    return img


# ---------------------------------------------------------------------------
# Golfinho (16x16) - forma curvada cinzento-azulada, barbatana
# ---------------------------------------------------------------------------
def make_dolphin() -> Image.Image:
    img = new_canvas(16, 16)

    # corpo principal (forma curva da esq. para dir.)
    body = {
        3: (12, 14),   # rabo
        4: (10, 14),
        5: (7, 13),
        6: (4, 12),
        7: (2, 11),
        8: (2, 10),
        9: (3, 10),
        10: (4, 11),
        11: (5, 12),
        12: (6, 13),
    }
    for row, (c0, c1) in body.items():
        fill_rect(img, c0, row, c1, row, TEAL)

    # ventre mais claro (parte inferior do corpo)
    belly = {
        7: (3, 6),
        8: (3, 6),
        9: (4, 6),
        10: (5, 7),
        11: (6, 8),
    }
    for row, (c0, c1) in belly.items():
        fill_rect(img, c0, row, c1, row, TEAL_LIGHT)

    # escuro nas costas
    back = {5: (8, 12), 6: (5, 11), 7: (3, 9)}
    for row, (c0, c1) in back.items():
        fill_rect(img, c0, row, c1, row, TEAL_DARK)

    # cabeca/focinho (esquerda)
    head = {6: (2, 3), 7: (1, 2), 8: (1, 1)}
    for row, (c0, c1) in head.items():
        fill_rect(img, c0, row, c1, row, TEAL)
    set_pixel(img, 1, 7, TEAL_LIGHT)  # bico/focinho

    # olho
    set_pixel(img, 3, 7, BLACK)

    # barbatana dorsal (cols 8-10, linhas 3-6)
    fin = {3: (9, 9), 4: (8, 10), 5: (8, 10), 6: (8, 10)}
    for row, (c0, c1) in fin.items():
        fill_rect(img, c0, row, c1, row, TEAL_DARK)

    # rabo (dividido em 2 lobos)
    set_pixel(img, 13, 2, TEAL)
    set_pixel(img, 14, 2, TEAL)
    set_pixel(img, 15, 3, TEAL)
    set_pixel(img, 13, 4, TEAL)
    set_pixel(img, 14, 5, TEAL)

    return img


# ---------------------------------------------------------------------------
# Tartaruga (16x16) - carapaca verde-castanha, cabeca, 4 patas
# ---------------------------------------------------------------------------
def make_turtle() -> Image.Image:
    img = new_canvas(16, 16)

    # carapaca oval (linhas 4-13, cols 4-12)
    shell_rows = {
        4: (6, 10),
        5: (4, 12),
        6: (4, 12),
        7: (3, 12),
        8: (3, 12),
        9: (4, 12),
        10: (4, 12),
        11: (5, 11),
        12: (6, 10),
    }
    for row, (c0, c1) in shell_rows.items():
        fill_rect(img, c0, row, c1, row, GREEN)

    # padrão da carapaca (hexágonos simplificados)
    pattern_center = GREEN_DARK
    fill_rect(img, 7, 6, 9, 8, pattern_center)
    fill_rect(img, 5, 8, 7, 10, pattern_center)
    fill_rect(img, 9, 8, 11, 10, pattern_center)
    fill_rect(img, 7, 10, 9, 11, pattern_center)

    # bordas da carapaca mais claras
    border = YELLOW
    for x, y in [(6, 4), (7, 4), (8, 4), (9, 4), (10, 4)]:
        set_pixel(img, x, y, border)

    # cabeca (linhas 2-5, cols 7-9)
    fill_rect(img, 7, 2, 9, 5, GREEN)
    # olhos
    set_pixel(img, 7, 3, BLACK)
    set_pixel(img, 9, 3, BLACK)

    # patas (4 cantos)
    # frente esq.
    fill_rect(img, 2, 6, 3, 8, GREEN)
    # frente dir.
    fill_rect(img, 13, 6, 14, 8, GREEN)
    # tras esq.
    fill_rect(img, 2, 10, 3, 12, GREEN)
    # tras dir.
    fill_rect(img, 13, 10, 14, 12, GREEN)

    # cauda
    set_pixel(img, 8, 13, GREEN)

    return img


# ---------------------------------------------------------------------------
# Caranguejo (16x16) - corpo laranja, 4 patas cada lado, 2 pinças
# ---------------------------------------------------------------------------
def make_crab() -> Image.Image:
    img = new_canvas(16, 16)

    # corpo central oval (linhas 6-12, cols 5-11)
    body_rows = {
        6: (6, 10),
        7: (5, 11),
        8: (4, 12),
        9: (4, 12),
        10: (5, 11),
        11: (6, 10),
        12: (7, 9),
    }
    for row, (c0, c1) in body_rows.items():
        fill_rect(img, c0, row, c1, row, ORANGE)

    # padrão do casco
    fill_rect(img, 7, 8, 9, 10, ORANGE_DARK)

    # contorno mais escuro
    border_pixels = [
        (6, 6), (7, 6), (8, 6), (9, 6), (10, 6),
        (4, 8), (4, 9), (12, 8), (12, 9),
    ]
    for x, y in border_pixels:
        set_pixel(img, x, y, ORANGE_DARK)

    # olhos no topo (pedúnculos)
    set_pixel(img, 7, 5, ORANGE)
    set_pixel(img, 9, 5, ORANGE)
    set_pixel(img, 7, 4, BLACK)
    set_pixel(img, 9, 4, BLACK)

    # patas esquerda (4 patas, linhas 7-12)
    legs_l = [(3, 7), (2, 8), (1, 9), (2, 10), (3, 11), (1, 11), (2, 12)]
    for x, y in legs_l:
        set_pixel(img, x, y, ORANGE)

    # patas direita
    legs_r = [(13, 7), (14, 8), (15, 9), (14, 10), (13, 11), (15, 11), (14, 12)]
    for x, y in legs_r:
        set_pixel(img, x, y, ORANGE)

    # pinças esquerda
    fill_rect(img, 1, 5, 2, 6, ORANGE_DARK)
    set_pixel(img, 0, 5, ORANGE_DARK)
    # pinças direita
    fill_rect(img, 14, 5, 15, 6, ORANGE_DARK)
    set_pixel(img, 15, 4, ORANGE_DARK)

    return img


# ---------------------------------------------------------------------------
# Efeito: gota de chuva (2x6 px) -- dentro dos limites 1-4 wide, 1-8 tall
# ---------------------------------------------------------------------------
def make_rain_particle() -> Image.Image:
    img = new_canvas(2, 6)
    RAIN_COLOR = (100, 150, 220, 200)
    RAIN_DARK = (60, 100, 180, 220)
    for y in range(6):
        set_pixel(img, 0, y, RAIN_COLOR)
        set_pixel(img, 1, y, RAIN_COLOR)
    set_pixel(img, 0, 5, RAIN_DARK)
    set_pixel(img, 1, 5, RAIN_DARK)
    return img


# ---------------------------------------------------------------------------
# Efeito: estrela cadente (16x4 px) -- dentro 8-32 wide
# ---------------------------------------------------------------------------
def make_shooting_star() -> Image.Image:
    img = new_canvas(16, 4)
    STAR_WHITE = (255, 255, 230, 255)
    STAR_YELLOW = (255, 230, 100, 200)
    STAR_TRAIL = (180, 180, 255, 120)
    STAR_DIM = (100, 100, 200, 60)
    # cabeca brilhante (direita)
    fill_rect(img, 14, 1, 15, 2, STAR_WHITE)
    set_pixel(img, 13, 0, STAR_YELLOW)
    set_pixel(img, 13, 3, STAR_YELLOW)
    # rastro decrescente (da direita para esquerda)
    for x in range(8, 14):
        alpha = int(180 * (x - 8) / 6)
        img.putpixel((x, 1), (STAR_YELLOW[0], STAR_YELLOW[1], STAR_YELLOW[2], alpha))
        img.putpixel((x, 2), (STAR_YELLOW[0], STAR_YELLOW[1], STAR_YELLOW[2], max(0, alpha - 40)))
    for x in range(0, 8):
        alpha = int(60 * x / 8)
        img.putpixel((x, 1), (STAR_TRAIL[0], STAR_TRAIL[1], STAR_TRAIL[2], alpha))
    return img


# ---------------------------------------------------------------------------
# Efeito: bioluminescência (8x8 px) -- tons azuis/ciano, R < B
# ---------------------------------------------------------------------------
def make_bioluminescence() -> Image.Image:
    img = new_canvas(8, 8)
    cx, cy = 3.5, 3.5
    for y in range(8):
        for x in range(8):
            dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if dist < 3.5:
                intensity = max(0.0, 1.0 - dist / 3.5)
                r = int(30 * intensity)    # R muito baixo
                g = int(180 * intensity)   # G médio
                b = int(255 * intensity)   # B máximo
                a = int(220 * intensity)
                if a > 0:
                    set_pixel(img, x, y, (r, g, b, a))
    # centro brilhante
    set_pixel(img, 3, 3, (60, 230, 255, 255))
    set_pixel(img, 4, 3, (40, 220, 255, 230))
    set_pixel(img, 3, 4, (40, 220, 255, 230))
    set_pixel(img, 4, 4, (30, 200, 255, 200))
    return img


# ---------------------------------------------------------------------------
# Upscale nearest-neighbour
# ---------------------------------------------------------------------------
def upscale(img: Image.Image, scale: int = 4) -> Image.Image:
    w, h = img.size
    return img.resize((w * scale, h * scale), Image.Resampling.NEAREST)


# ---------------------------------------------------------------------------
# Prova visual: sprites lado a lado (T-607)
# ---------------------------------------------------------------------------
def make_proof_t607(
    seagull: Image.Image,
    dolphin: Image.Image,
    turtle: Image.Image,
    crab: Image.Image,
) -> Image.Image:
    scale = 4
    sprites = [seagull, dolphin, turtle, crab]
    labels = ["Gaivota", "Golfinho", "Tartaruga", "Caranguejo"]
    pad = 8
    sprite_size = 16 * scale  # 64px
    w = len(sprites) * (sprite_size + pad) + pad
    h = sprite_size + pad * 2 + 20  # +20 para texto (so PNG, sem fonte)

    out = Image.new("RGBA", (w, h), (30, 30, 40, 255))
    for i, sp in enumerate(sprites):
        big = upscale(sp, scale)
        x = pad + i * (sprite_size + pad)
        y = pad
        # fundo cinzento por baixo do sprite para visibilidade
        bg = Image.new("RGBA", (sprite_size, sprite_size), (60, 60, 80, 255))
        out.paste(bg, (x, y))
        out.paste(big, (x, y), big)
    return out


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    out_chars = ROOT / "game" / "character"
    out_effects = ROOT / "game" / "effect"
    out_proof = ROOT / "docs" / "proof"
    out_comfyui = ROOT / "docs" / "comfyui"

    for d in (out_chars, out_effects, out_proof, out_comfyui):
        d.mkdir(parents=True, exist_ok=True)

    print("Gerando sprites de animais...")
    seagull = make_seagull()
    dolphin = make_dolphin()
    turtle = make_turtle()
    crab = make_crab()

    seagull.save(out_chars / "seagull.png")
    dolphin.save(out_chars / "dolphin.png")
    turtle.save(out_chars / "turtle.png")
    crab.save(out_chars / "crab.png")
    print(f"  Gravados em {out_chars}/")

    print("Gerando sprites de efeitos...")
    rain = make_rain_particle()
    star = make_shooting_star()
    bio = make_bioluminescence()

    rain.save(out_effects / "rain_particle.png")
    star.save(out_effects / "shooting_star.png")
    bio.save(out_effects / "bioluminescence.png")
    print(f"  Gravados em {out_effects}/")

    print("Gerando prova visual T-607...")
    proof = make_proof_t607(seagull, dolphin, turtle, crab)
    proof.save(out_proof / "T-607-animais-visitantes.png")
    print(f"  Screenshot: {out_proof}/T-607-animais-visitantes.png")

    print("Verificando dimensoes...")
    _verify_sprites(out_chars, out_effects)

    print("Done.")


def _verify_sprites(out_chars: Path, out_effects: Path) -> None:
    from PIL import Image as PILImage

    checks = [
        (out_chars / "seagull.png", lambda img: True, "seagull existe"),
        (out_chars / "dolphin.png", lambda img: 16 <= img.width <= 48, "dolphin 16-48px"),
        (out_chars / "turtle.png", lambda img: 16 <= img.width <= 32, "turtle 16-32px"),
        (out_chars / "crab.png", lambda img: 8 <= img.width <= 24, "crab 8-24px"),
        (out_effects / "rain_particle.png", lambda img: img.width <= 4 and img.height <= 8, "rain 1-4x1-8px"),
        (out_effects / "shooting_star.png", lambda img: 8 <= img.width <= 32, "star 8-32px"),
        (out_effects / "bioluminescence.png", lambda img: img.width <= 16 and img.height <= 16, "bio 4-16px"),
    ]
    for path, check_fn, label in checks:
        img = PILImage.open(path)
        ok = check_fn(img)
        status = "OK" if ok else "FALHOU"
        print(f"  {status}: {label} -> {img.size}")
        if not ok:
            sys.exit(1)

    # verificar bioluminescência azul dominante
    import numpy as np
    bio = PILImage.open(out_effects / "bioluminescence.png").convert("RGB")
    arr = __import__("numpy").array(bio)
    r, g, b = arr[:, :, 0].mean(), arr[:, :, 1].mean(), arr[:, :, 2].mean()
    assert r < b, f"bioluminescence R={r:.1f} nao e menor que B={b:.1f}"
    print(f"  OK: bioluminescence R={r:.1f} < B={b:.1f}")


if __name__ == "__main__":
    main()
