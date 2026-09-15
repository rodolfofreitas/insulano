#!/usr/bin/env python3
"""Gera os sprites dos objectos do companheiro imaginario (lote 1).

Sprites 16x24 (pixel art Stardew Valley / Graveyard Keeper), fundo RGBA transparente,
contorno preto 1px, gravados em game/object/ com prefixo companion_.

Uso: python3 scripts/generate_companion_sprites.py
"""
from PIL import Image, ImageDraw
from pathlib import Path

W, H = 16, 24

OBJ = Path('game/object')
OBJ.mkdir(exist_ok=True)

# Versoes 4x
OUT4 = Path('game/data/companion_sprites')
OUT4.mkdir(exist_ok=True)


def _upscale(img: Image.Image, scale: int = 4) -> Image.Image:
    return img.resize((img.width * scale, img.height * scale), Image.Resampling.NEAREST)


# ---------- coco 16x24 ----------
def make_coconut():
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Corpo do coco (oval castanho escuro)
    d.ellipse([2, 4, 13, 17], fill=(90, 55, 25, 255), outline=(30, 15, 5, 255))
    # Textura de fibra
    d.line([5, 7, 8, 10], fill=(55, 30, 10, 255), width=1)
    d.line([8, 7, 11, 10], fill=(55, 30, 10, 255), width=1)
    d.line([6, 11, 10, 14], fill=(55, 30, 10, 255), width=1)
    # Olhinhos (3 buracos escuros)
    d.point((6, 6), fill=(20, 8, 2, 255))
    d.point((8, 6), fill=(20, 8, 2, 255))
    d.point((10, 6), fill=(20, 8, 2, 255))
    # Folhas de palmeira em cima
    d.line([6, 3, 3, 0], fill=(80, 140, 50, 255), width=1)
    d.line([8, 3, 8, 0], fill=(80, 140, 50, 255), width=1)
    d.line([10, 3, 13, 0], fill=(80, 140, 50, 255), width=1)
    # Sombra em baixo
    d.ellipse([4, 18, 12, 21], fill=(50, 30, 10, 80))
    img.save(OBJ / 'companion_coco.png')
    _upscale(img).save(OUT4 / 'coco_4x.png')
    print('  coco: ', OBJ / 'companion_coco.png')


# ---------- tabua 16x24 ----------
def make_plank():
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Tabua principal (deitada ao centro)
    d.rectangle([1, 8, 14, 15], fill=(160, 105, 50, 255), outline=(75, 45, 18, 255))
    # Grão de madeira (linhas horizontais)
    d.line([2, 10, 13, 10], fill=(130, 85, 38, 255), width=1)
    d.line([2, 13, 13, 13], fill=(130, 85, 38, 255), width=1)
    # Veios verticais
    d.line([4, 9, 4, 14], fill=(115, 75, 32, 255), width=1)
    d.line([8, 9, 8, 14], fill=(115, 75, 32, 255), width=1)
    d.line([12, 9, 12, 14], fill=(115, 75, 32, 255), width=1)
    # Prego oxidado (pontinho cinzento)
    d.point((4, 9), fill=(120, 110, 90, 255))
    d.point((12, 14), fill=(120, 110, 90, 255))
    # Sombra
    d.rectangle([2, 16, 13, 17], fill=(60, 35, 12, 60))
    img.save(OBJ / 'companion_tabua.png')
    _upscale(img).save(OUT4 / 'tabua_4x.png')
    print('  tabua:', OBJ / 'companion_tabua.png')


# ---------- destroco 16x24 ----------
def make_wreckage():
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Forma irregular de destroco de barco (castanho escuro)
    d.polygon([2, 12, 4, 5, 9, 4, 14, 8, 13, 15, 5, 17], fill=(75, 45, 25, 255), outline=(35, 18, 8, 255))
    # Planche sobrepostas
    d.line([4, 8, 10, 7], fill=(55, 32, 14, 255), width=1)
    d.line([3, 12, 12, 11], fill=(55, 32, 14, 255), width=1)
    d.line([5, 15, 11, 14], fill=(55, 32, 14, 255), width=1)
    # Prego / parafuso visivel
    d.point((7, 7), fill=(150, 130, 100, 255))
    d.point((10, 13), fill=(150, 130, 100, 255))
    # Textura de musgo/tempo
    d.point((4, 10), fill=(60, 80, 40, 180))
    d.point((11, 9), fill=(60, 80, 40, 180))
    d.point((6, 14), fill=(60, 80, 40, 180))
    # Sombra
    d.polygon([3, 17, 5, 18, 13, 16, 14, 18, 5, 20], fill=(40, 20, 8, 60))
    img.save(OBJ / 'companion_destroco.png')
    _upscale(img).save(OUT4 / 'destroco_4x.png')
    print('  destroco:', OBJ / 'companion_destroco.png')


# ---------- garrafa 16x24 ----------
def make_bottle():
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Gargalo
    d.rectangle([6, 1, 9, 6], fill=(70, 130, 70, 210), outline=(35, 75, 35, 255))
    # Corpo da garrafa (ovaloide)
    d.ellipse([3, 6, 12, 20], fill=(75, 150, 75, 170), outline=(35, 90, 35, 255))
    # Reflexo de luz (diagonal clara)
    d.line([5, 9, 7, 13], fill=(160, 220, 160, 100), width=1)
    d.point((6, 9), fill=(200, 240, 200, 130))
    # Rolha
    d.rectangle([6, 0, 9, 2], fill=(180, 130, 70, 255), outline=(120, 85, 40, 255))
    # Mensagem enrolada (pontinho castanho dentro da garrafa)
    d.ellipse([7, 13, 10, 16], fill=(220, 190, 130, 120), outline=(160, 130, 80, 180))
    # Sombra em baixo
    d.ellipse([4, 20, 11, 23], fill=(40, 80, 40, 60))
    img.save(OBJ / 'companion_garrafa.png')
    _upscale(img).save(OUT4 / 'garrafa_4x.png')
    print('  garrafa:', OBJ / 'companion_garrafa.png')


if __name__ == '__main__':
    print('Gerando sprites dos objectos do companheiro (16x24)...')
    make_coconut()
    make_plank()
    make_wreckage()
    make_bottle()
    print('Done. Ficheiros 4x em', OUT4)
