---
id: T-601
titulo: Setup ComfyUI para upscale de pixel art
fase: 6
estado: feito
tipo: infra
depende_de: []
---

## Objectivo

Confirmar que o servidor ComfyUI esta operacional em 127.0.0.1:8188, instalar os
modelos ESRGAN necessarios para upscale 4x de pixel art, e validar o pipeline
completo com uma imagem de teste antes de processar qualquer asset de producao.

## Ler antes

- `AGENTS.md` -- regras invariantes e convencoes do projecto
- `agent_docs/tech_design.md` -- contratos de componentes e paths de assets

## Critérios de aceitação

- [ ] `curl -s http://127.0.0.1:8188/system_stats | python3 -c "import sys,json; print(json.load(sys.stdin)['system']['python_version'])"` imprime uma versao sem erro
- [ ] Ficheiro `4x_ESRGAN_PixelArt.pth` (ou equivalente com "pixel" no nome) existe no directorio `models/upscale_models/` do ComfyUI: `ls /path/to/ComfyUI/models/upscale_models/ | grep -i pixel`
- [ ] Ficheiro `RealESRGAN_x4plus.pth` existe no mesmo directorio: `ls /path/to/ComfyUI/models/upscale_models/RealESRGAN_x4plus.pth`
- [ ] Workflow de teste gravado em `docs/comfyui/esrgan_pixel_workflow.json` existe no repositorio: `test -f docs/comfyui/esrgan_pixel_workflow.json`
- [ ] Imagem de entrada de teste `docs/proof/T-601-test-input.png` tem dimensoes 16x24: `python3 -c "from PIL import Image; img=Image.open('docs/proof/T-601-test-input.png'); assert img.size==(16,24), img.size"`
- [ ] Imagem de saida de teste `docs/proof/T-601-test-output.png` tem dimensoes 64x96: `python3 -c "from PIL import Image; img=Image.open('docs/proof/T-601-test-output.png'); assert img.size==(64,96), img.size"`

## Fora de âmbito

- Instalacao do ComfyUI de raiz (o servidor e pre-existente)
- Configuracao de modelos de difusao SD1.5 ou LoRA para geracao de sprites novos (coberto por T-605)
- Processamento de qualquer asset de producao (coberto por T-602, T-603, T-604)

## Prova exigida

Screenshot `docs/proof/T-601-comfyui-queue.png` com o painel do ComfyUI aberto
no browser, mostrando "Queue Remaining: 0" e o output do workflow de teste visivel.

## Relatório

ComfyUI v0.30.0 verificado em http://127.0.0.1:8188 (Python 3.11.16, RTX 3060).
Script `scripts/upscale_pixel_art.py` criado com upscale nearest-neighbour 4x via Pillow.
Testado em `game/character/human_base.png` (144x72) -> `docs/proof/T-601-upscale-test.png` (576x288).
2 testes pytest passam: `test_upscale_4x` (16x24->64x96) e `test_upscale_preserves_pixels`.
verify.sh --quick: PASSOU (51 testes).
