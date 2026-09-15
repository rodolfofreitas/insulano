#!/usr/bin/env python3
"""Testes pytest para scripts/upscale_pixel_art.py."""

import sys
from pathlib import Path
import pytest
from PIL import Image

# Garante que scripts/ está no path
sys.path.insert(0, str(Path(__file__).parent.parent))
from upscale_pixel_art import upscale_nearest


def test_upscale_4x(tmp_path: Path) -> None:
    """Imagem 16x24 deve resultar em 64x96 com scale=4."""
    # Cria imagem de teste 16x24
    src = tmp_path / "test_sprite.png"
    img = Image.new("RGBA", (16, 24), color=(100, 150, 200, 255))
    img.save(src)

    dest = str(tmp_path / "test_sprite_4x.png")
    upscale_nearest(str(src), dest, scale=4)

    result = Image.open(dest)
    assert result.size == (64, 96), f"Esperado (64, 96), obtido {result.size}"


def test_upscale_preserves_pixels(tmp_path: Path) -> None:
    """Pixel (0,0) vermelho deve permanecer vermelho após upscale nearest-neighbour."""
    src = tmp_path / "red_pixel.png"
    img = Image.new("RGBA", (16, 24), color=(0, 0, 0, 255))
    # Coloca pixel vermelho em (0,0)
    img.putpixel((0, 0), (255, 0, 0, 255))
    img.save(src)

    dest = str(tmp_path / "red_pixel_4x.png")
    upscale_nearest(str(src), dest, scale=4)

    result = Image.open(dest).convert("RGBA")
    pixel = result.getpixel((0, 0))
    assert pixel == (255, 0, 0, 255), f"Esperado vermelho (255,0,0,255), obtido {pixel}"
