#!/usr/bin/env python3
"""Upscale de pixel art com nearest-neighbour 4x.

Uso: python3 scripts/upscale_pixel_art.py input.png [output.png] [scale]

Exemplos:
    python3 scripts/upscale_pixel_art.py game/character/human_base.png
    python3 scripts/upscale_pixel_art.py sprite.png upscaled.png 4
"""

import sys
from pathlib import Path
from typing import Optional
from PIL import Image


def upscale_nearest(input_path: str, output_path: Optional[str] = None, scale: int = 4) -> str:
    """Upscale uma imagem usando nearest-neighbour (preserva pixels nítidos).

    Args:
        input_path: Caminho da imagem de entrada.
        output_path: Caminho de saída (opcional). Se None, gera <stem>_4x.png.
        scale: Factor de escala (default 4).

    Returns:
        Caminho do ficheiro de saída.
    """
    src = Path(input_path)
    if not src.exists():
        raise FileNotFoundError(f"Imagem não encontrada: {input_path}")

    img = Image.open(src).convert("RGBA")
    w, h = img.size
    new_size = (w * scale, h * scale)
    upscaled = img.resize(new_size, Image.Resampling.NEAREST)

    if output_path is None:
        dest = src.parent / f"{src.stem}_{scale}x{src.suffix}"
    else:
        dest = Path(output_path)
        dest.parent.mkdir(parents=True, exist_ok=True)

    upscaled.save(dest)
    print(f"Upscale {scale}x: {src} ({w}x{h}) -> {dest} ({new_size[0]}x{new_size[1]})")
    return str(dest)


def main() -> None:
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(1)

    input_path = args[0]
    output_path: Optional[str] = args[1] if len(args) > 1 else None
    scale = int(args[2]) if len(args) > 2 else 4

    result = upscale_nearest(input_path, output_path, scale)
    print(f"Guardado em: {result}")


if __name__ == "__main__":
    main()
