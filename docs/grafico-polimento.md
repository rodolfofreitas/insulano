# Fase 6: Polimento Grafico

Documento de processo para a Fase 6 do Insulano. Audiencia: agentes de codigo (Claude Code, Hermes)
que executam as tarefas do backlog. Todos os comandos sao exactos e executaveis. Todos os criterios
sao binarios (passou/falhou). Sem ambiguidade.

Repositorio: `~/Programacao/Kaeto/Insulano`. Todos os caminhos sao relativos a esta raiz.

---

## 1. Inventario de Assets Actuais

Assets PNG activos em `game/` (excluindo `addons/` e `Majadroid Brand Resources/`).
Dimensoes medidas com `python3 -c "from PIL import Image; ..."` a 2026-09-14.

| Caminho (em `game/`) | Dimensoes | Modo | Tamanho em disco | Licenca | Estado |
|---|---|---|---|---|---|
| `character/human_base.png` | 144x72 px | P (indexed) | 2168 B | CC-BY 3.0 (Antifarea, Clint Bellanger, Doubi) | activo, spritesheet de 27 frames (9 col x 3 lin) a 16x24 por frame |
| `character/fishingrod.png` | 32x6 px | RGBA | 311 B | MIT (Doubi, por confirmar) | activo |
| `object/raw_fish.png` | 32x16 px | RGBA | 219 B | MIT (Doubi, por confirmar) | activo |
| `object/dummy_object.png` | 16x32 px | RGBA | 108 B | MIT (Doubi, por confirmar) | placeholder, sera substituido por objectos do companheiro |
| `world/Tiny-Islands-by-Majadroid/tilemap.png` | 224x160 px | RGBA | 17413 B | CC0 (Majadroid) | activo, tileset 16x16 (14 col x 10 lin) |
| `world/Tiny-Islands-by-Majadroid/tilemap-separated.png` | 320x256 px | RGBA | 21253 B | CC0 (Majadroid) | activo, versao com separacao de tiles |
| `world/Tiny-Islands-by-Majadroid/buttons.png` | 96x128 px | RGBA | 2071 B | CC0 (Majadroid) | nao usado em jogo, candidato a remover do export |

### Problemas conhecidos

| Asset | Problema |
|---|---|
| `human_base.png` | Modo P (indexed): ESRGAN requer RGBA. Converter antes do upscale. |
| `human_base.png` | Resolucao baixa visivelmente pixelada em ecras de alta densidade sem nearest-neighbour. |
| `fishingrod.png` | 32x6 muito estreito: verificar que o upscale 4x nao introduz artefactos nas bordas horizontais. |
| `dummy_object.png` | Placeholder sem forma definitiva: candidato a substituicao por sprite proprio (Caminho B). |
| `buttons.png` | Nao usado em jogo activo. Nao deve ser incluido no export (T-505 pendente). |

### Dimensoes resultantes apos upscale 4x

| Asset | Original | Apos 4x |
|---|---|---|
| `human_base.png` | 144x72 | 576x288 (frames 64x96 cada) |
| `fishingrod.png` | 32x6 | 128x24 |
| `raw_fish.png` | 32x16 | 128x64 |
| `dummy_object.png` | 16x32 | 64x128 |
| `tilemap.png` | 224x160 | 896x640 (tiles 64x64 cada) |
| `tilemap-separated.png` | 320x256 | 1280x1024 |
| `buttons.png` | 96x128 | 384x512 |

---

## 2. Caminho A: Upscale ESRGAN (prioridade 1)

Objetivo: melhorar a qualidade dos sprites existentes sem alterar o estilo nem a paleta.
Fator de escala: 4x. O Godot e a logica de jogo nao mudam: so os PNGs no disco sao substituidos.

### 2.1 Modelos ESRGAN recomendados para pixel art

| Modelo | Ficheiro | Recomendacao |
|---|---|---|
| 4x-UltraSharp | `4x-UltraSharp.pth` | Primeira opcao. Preserva bordas, sem blur, ideal para pixel art com contornos definidos. |
| 4x_NMKD-Superscale-SP_178000_G | `4x_NMKD-Superscale-SP_178000_G.pth` | Segunda opcao. Bom para sprites com gradientes suaves. |
| RealESRGAN_x4plus | `RealESRGAN_x4plus.pth` | Nao usar para pixel art: introduz anti-aliasing e suavizacao que destroem o aspecto pixelado. |
| RealESRGAN_x4plus_anime_6B | `RealESRGAN_x4plus_anime_6B.pth` | Alternativa aceitavel para sprites com estilo anime; testar e comparar com 4x-UltraSharp. |

Modelo a usar por defeito neste projecto: `4x-UltraSharp`.

### 2.2 Configuracao do ComfyUI para pixel art

Regras obrigatorias. Se alguma nao for respeitada, o sprite resultante falha.

| Parametro | Valor obrigatorio | Razao |
|---|---|---|
| Interpolacao de redimensionamento | nearest-neighbour | Qualquer outro modo (bilinear, bicubico, lanczos) borra os pixels e destroi o aspecto pixelado. |
| Formato de saida | PNG com transparencia (RGBA) | JPEG perde transparencia e introduz artefactos de compressao. |
| Conversao de modo P para RGBA | obrigatoria antes do upscale | O ESRGAN nao aceita modo P (indexed). human_base.png requer esta conversao. |
| Pos-processamento de nitidez (sharpening) | desligado | O 4x-UltraSharp ja e agressivo; sharpening extra cria halos brancos nas bordas. |
| Escala exacta | exactamente 4x | Escalas fracionarias (3.8x, 4.2x) desalinham o grid de pixels. |

### 2.3 Descricao do workflow ComfyUI (Caminho A)

O workflow e carregado em `http://127.0.0.1:8188` via interface web ou API REST.
Nao e necessario criar o JSON manualmente: a interface web do ComfyUI permite arrastar os nos.

**Nos necessarios, por ordem:**

1. **Load Image** (`LoadImage`): carregar o PNG original.
2. **Convert Image Mode** (`ImageBatch` ou script custom): converter de modo P para RGBA se necessario.
   Para `human_base.png` especificamente: usar o no `ImageColorToRGBA` ou pre-converter em linha de
   comando com `python3 -c "from PIL import Image; img = Image.open('in.png').convert('RGBA'); img.save('out.png')"`.
3. **Upscale Image (using Model)** (`ImageUpscaleWithModel`): seleccionar o modelo `4x-UltraSharp`.
4. **Image Scale** (`ImageScale`): modo `nearest-exact`, largura e altura a 0 (manter proporcao calculada
   pelo upscale). Este no garante que o resultado e exactamente 4x sem fraccoes de pixel.
5. **Save Image** (`SaveImage`): guardar em `output/` com prefixo identico ao nome original.

**Verificacao pos-workflow (obrigatoria antes de substituir o ficheiro em `game/`):**

```bash
python3 -c "
from PIL import Image
img = Image.open('caminho/para/output.png')
print(img.width, img.height, img.mode)
# Verificar: largura = original * 4, altura = original * 4, modo = RGBA
"
```

### 2.4 Como substituir PNGs no Godot sem partir os .import

O Godot 4 gera um ficheiro `.import` para cada PNG com um UID unico. Ao substituir o PNG no disco,
o `.import` continua valido desde que o caminho nao mude. O procedimento correcto e:

**Passo 1: guardar backup do original**
```bash
cp game/character/human_base.png game/character/human_base.png.bak
```

**Passo 2: copiar o novo PNG para o mesmo caminho**
```bash
cp /caminho/para/upscaled/human_base.png game/character/human_base.png
```

**Passo 3: verificar que o .import existe e tem o mesmo UID**
```bash
cat game/character/human_base.png.import | grep uid
# O uid nao muda; o Godot regenera os dados de importacao, nao o UID.
```

**Passo 4: regenerar os dados de importacao**
```bash
godot --headless --path game/ --import 2>&1 | grep -v "Can't send message"
# Nao deve conter SCRIPT ERROR
```

**Passo 5: verificar que o Godot arranca com o novo asset**
```bash
bash scripts/verify.sh
# Deve terminar sem FALHOU
```

**Passo 6: abrir a captura visual e confirmar**
```bash
bash scripts/verify.sh --visual
# Inspeccionar docs/proof/ para confirmar que o sprite esta correcto em jogo
```

**Regra de rollback:** se `verify.sh` falhar apos a substituicao, restaurar o backup:
```bash
cp game/character/human_base.png.bak game/character/human_base.png
godot --headless --path game/ --import
```

**Nota sobre o `.import`:** nao editar o ficheiro `.import` manualmente. O Godot 4 usa UIDs internos
que nao correspondem ao conteudo do ficheiro. Qualquer edicao manual corrompe o recurso.

**Nota sobre o filter do Godot:** apos o upscale, verificar que o import do sprite usa
`texture/filter: 0` (nearest-neighbour) no `.import`. Se estiver a 1 (linear), alterar:
```bash
sed -i 's/texture\/filter=1/texture\/filter=0/g' game/character/human_base.png.import
```

### 2.5 Criterios de qualidade: o upscale passou se

Todos os itens abaixo devem ser verdadeiros. Um item falso significa que o upscale falhou.

| Criterio | Como verificar |
|---|---|
| Dimensoes exactas: largura_original * 4 e altura_original * 4 | `python3 -c "from PIL import Image; img = Image.open('f.png'); assert img.width == W*4 and img.height == H*4"` |
| Modo RGBA (nao P, nao RGB) | `python3 -c "from PIL import Image; assert Image.open('f.png').mode == 'RGBA'"` |
| Transparencia preservada: pixels que eram transparentes continuam transparentes | `python3 scripts/check_alpha.py f_original.png f_upscaled.png` (script a criar em T-602) |
| Sem pixels brancos ou pretos espurios nas bordas dos sprites | inspeccao visual em `docs/proof/` com zoom 400% |
| Grid de frames alinhado: em human_base.png, cada frame e exactamente 64x96 | `python3 -c "assert 576 % 9 == 0 and 288 % 3 == 0"` |
| Paleta original reconhecivel: as cores principais nao mudaram de hue | comparacao visual antes/depois em `docs/proof/` |
| verify.sh sem FALHOU apos substituicao | `bash scripts/verify.sh` com exit 0 |
| boot_smoke.gd passa: personagem visivelmente correctamente desenhado | `bash scripts/verify.sh --visual`, inspeccionar PNG |

---

## 3. Caminho B: Novos Sprites (prioridade 2, fase posterior)

Este caminho e executado depois do Caminho A estar completo e aprovado. Gerar sprites novos
com IA local (Stable Diffusion 1.5 com LoRA de pixel art no ComfyUI).

### 3.1 Catalogo de sprites a gerar

#### Objectos do companheiro imaginario (8 objectos)

Definidos em `game/data/companion_objects.json`. Cada objecto e um sprite 16x24 isolado em fundo
transparente, estilo pixel art coerente com `human_base.png`.

| ID | Nome PT | Descricao visual |
|---|---|---|
| obj_coconut | coco | fruto redondo castanho, fenda no topo |
| obj_plank | tabua | tabua de madeira rectangular, veio de madeira visivel |
| obj_wreckage | destroco | pedaco de casco de barco partido, madeira escura |
| obj_bottle | garrafa | garrafa verde de vidro, rolha de cortica |
| obj_buoy | boia | boia esferica laranja e branca, argola metalica |
| obj_hat | chapeu | chapeu de palha com aba larga |
| obj_compass | bussola | bussola redonda, agulha vermelha |
| obj_lantern | lanterna | lanterna de oleo, chama amarela dentro |

#### Animais visitantes

Sprites para eventos aleatorios. Tamanho: 16x16 ou 24x16 conforme a forma do animal.

| ID | Nome PT | Dimensoes | Notas |
|---|---|---|---|
| anim_seagull | gaivota | 24x16 | asa aberta ou pousada, duas poses |
| anim_dolphin | golfinho | 32x16 | vista lateral, arco de salto |
| anim_turtle | tartaruga | 16x16 | vista de cima, casco detalhado |
| anim_crab | caranguejo | 16x12 | vista frontal, pincas levantadas |

#### Efeitos visuais

Sprites de particulas e efeitos de ambiente. Sem contorno definido (blend por additive ou alpha).

| ID | Descricao | Dimensoes | Modo de blend |
|---|---|---|---|
| fx_rain | gota de chuva individual | 2x8 | alpha |
| fx_star | estrela cintilante 4 pontas | 8x8 | additive |
| fx_biolum | mancha de bioluminescencia | 16x16 | additive |
| fx_sparkle | faiscas de fogueira | 4x4 | additive |

#### Sprites de feriados

Para eventos do modulo de calendario (Fase 4, T-401, T-402).

| ID | Feriado | Dimensoes | Descricao |
|---|---|---|---|
| hol_xmas_tree | Natal (25 Dez) | 16x24 | arvore de Natal minuscula com estrela no topo |
| hol_xmas_gift | Natal (25 Dez) | 16x16 | embrulho com laco |
| hol_newyear_firework | Ano Novo (1 Jan) | 16x16 | fogo de artificio a explodir |
| hol_newyear_bottle | Ano Novo (1 Jan) | 8x24 | garrafa de champanhe com rolha a voar |

### 3.2 Consistencia de paleta e estilo

Regra: todos os sprites gerados devem ser reduzidos para a paleta de `human_base.png` apos geracao.

**Extrair a paleta do sprite de referencia:**
```bash
python3 -c "
from PIL import Image
img = Image.open('game/character/human_base.png').convert('RGBA')
pixels = set(img.getdata())
palette = sorted([p for p in pixels if p[3] > 0])
for c in palette:
    print('#%02x%02x%02x' % (c[0], c[1], c[2]))
" > docs/paleta-referencia.txt
```

**Reduzir um sprite gerado para a paleta de referencia:**
```bash
python3 scripts/quantize_palette.py \
  --reference game/character/human_base.png \
  --input output/sprite_gerado.png \
  --output game/object/sprite_final.png
# Script a criar em T-611
```

**Verificar que o sprite final usa apenas cores da paleta:**
```bash
python3 -c "
from PIL import Image
ref = set(tuple(p[:3]) for p in Image.open('game/character/human_base.png').convert('RGBA').getdata() if p[3] > 0)
novo = set(tuple(p[:3]) for p in Image.open('game/object/sprite_final.png').convert('RGBA').getdata() if p[3] > 0)
extras = novo - ref
print('Cores fora da paleta:', len(extras))
for c in extras:
    print('#%02x%02x%02x' % c)
"
# Criterio: 0 cores fora da paleta (ou justificacao documentada para cada excepcao)
```

### 3.3 Prompt base para pixel art 16x24

Prompt positivo (em ingles, que e o que os modelos SD entendem melhor):

```
pixel art, 16x24 pixels, transparent background, single sprite, isolated object,
[DESCRICAO DO OBJECTO], 2D game asset, retro style, clean edges, no anti-aliasing,
limited color palette, isometric top-down slight angle, indie game sprite
```

Prompt negativo (obrigatorio):

```
blurry, smooth, 3d render, photorealistic, watermark, text, multiple objects,
background, shadow, noise, jpeg artifacts, antialiasing, gradient, high resolution
```

Substituir `[DESCRICAO DO OBJECTO]` pela descricao em ingles de cada sprite (ex: `coconut fruit`, `wooden plank`).

**Parametros de geracao:**
- Resolucao de geracao: 512x512 (SD1.5 nativo)
- Apos geracao: redimensionar para 16x24 com nearest-neighbour, depois quantizar para a paleta
- Steps: 20 a 30
- CFG scale: 7 a 10
- Sampler: DPM++ 2M Karras

---

## 4. Processo de Aprovacao

Regra do projecto: nenhum sprite novo ou alterado entra em commit sem passar por este processo.

### 4.1 Passos obrigatorios

**Passo 1: captura antes/depois**
```bash
# Antes: capturar o estado actual
bash scripts/verify.sh --visual
cp docs/proof/T-NNN-screenshot.png docs/proof/T-NNN-antes.png

# Depois do upscale ou geracao: capturar o novo estado
bash scripts/verify.sh --visual
cp docs/proof/T-NNN-screenshot.png docs/proof/T-NNN-depois.png
```

As duas imagens ficam em `docs/proof/T-NNN-antes.png` e `docs/proof/T-NNN-depois.png`.

**Passo 2: registo em `docs/assets-licencas.md`**

Para assets gerados por IA propria (ComfyUI local, modelos open source):

```markdown
| `object/obj_coconut.png` | gerado por IA propria (ComfyUI + 4x-UltraSharp) | licenca propria do projecto (Insulano) | gerado localmente | nenhuma | confirmado |
```

Para assets upscalados de originais CC-BY ou MIT: a licenca do original mantem-se. Registar
a transformacao na coluna "Fonte":

```markdown
| `character/human_base.png` | Antifarea, Clint Bellanger, Doubi; upscale ESRGAN por projecto | CC-BY 3.0 (original) | upscale 4x de OpenGameArt original | credito visivel | confirmado |
```

**Passo 3: aprovacao visual do Rodolfo**

A tarefa fica em `estado: humano` ate o Rodolfo confirmar. O agente escreve no Relatorio da tarefa:

```
Aprovacao pendente: docs/proof/T-NNN-antes.png e docs/proof/T-NNN-depois.png disponiveis.
Aguardar confirmacao do Rodolfo antes de alterar estado para feito.
```

**Passo 4: commit apenas apos aprovacao**

```bash
git add game/character/human_base.png game/character/human_base.png.import docs/proof/ docs/assets-licencas.md
git commit -m "visual(T-NNN): upscale 4x human_base.png com 4x-UltraSharp"
```

### 4.2 O que nao precisa de aprovacao do Rodolfo

- Alteracoes a scripts de automacao (`scripts/`), configuracao do ComfyUI, documentacao desta fase.
- Upscale que passa todos os criterios binarios da secao 2.5 pode ser commitado pelo agente
  SE o Rodolfo tiver pre-aprovado o workflow num commit anterior. A pre-aprovacao e registada
  na tarefa `T-601` (setup e validacao do workflow).

---

## 5. Configuracao do ComfyUI Local

ComfyUI: `http://127.0.0.1:8188`. Actualmente offline. Precisa de ser arrancado manualmente
ou via script antes de qualquer tarefa do Caminho A ou B.

### 5.1 Modelos necessarios

Directorio base de modelos ComfyUI: tipicamente `~/.comfyui/models/` ou o directorio onde
o ComfyUI foi instalado, em `ComfyUI/models/`.

| Tipo | Modelo | Ficheiro | Directorio |
|---|---|---|---|
| ESRGAN Upscale | 4x-UltraSharp | `4x-UltraSharp.pth` | `models/upscale_models/` |
| ESRGAN Upscale | 4x_NMKD-Superscale-SP_178000_G | `4x_NMKD-Superscale-SP_178000_G.pth` | `models/upscale_models/` |
| SD1.5 Base (Caminho B) | v1-5-pruned-emaonly | `v1-5-pruned-emaonly.safetensors` | `models/checkpoints/` |
| LoRA Pixel Art (Caminho B) | pixel-art-style | `pixel-art-xl-v1.1.safetensors` ou equivalente | `models/loras/` |
| VAE (Caminho B) | vae-ft-mse-840000 | `vae-ft-mse-840000-ema-pruned.safetensors` | `models/vae/` |

Para o Caminho A (upscale), apenas os modelos ESRGAN sao necessarios.

### 5.2 Como verificar se esta configurado correctamente

```bash
# Verificar que o servidor esta a responder
curl -s http://127.0.0.1:8188/system_stats | python3 -m json.tool | head -20
# Esperado: JSON com "system" e "devices"

# Listar modelos de upscale instalados
curl -s http://127.0.0.1:8188/object_info/UpscaleModelLoader | \
  python3 -c "import sys, json; d = json.load(sys.stdin); print(d['UpscaleModelLoader']['input']['required']['model_name'][0])"
# Esperado: lista contendo "4x-UltraSharp.pth"

# Verificar que o modelo ESRGAN existe em disco
find ~/.comfyui/models/upscale_models/ -name "4x-UltraSharp.pth" 2>/dev/null || \
find ~/ComfyUI/models/upscale_models/ -name "4x-UltraSharp.pth" 2>/dev/null
# Esperado: caminho completo para o ficheiro
```

### 5.3 Script de health check

Guardar em `scripts/comfyui_health.sh`:

```bash
#!/usr/bin/env bash
# scripts/comfyui_health.sh
# Verifica se o ComfyUI esta configurado e pronto para o Caminho A (upscale ESRGAN).
# Exit 0: tudo OK. Exit 1: algum problema, mensagem impressa em stderr.

set -euo pipefail

COMFYUI_URL="http://127.0.0.1:8188"
REQUIRED_MODEL="4x-UltraSharp.pth"

echo "=== ComfyUI Health Check ==="

# 1. Servidor a responder
if ! curl -sf "${COMFYUI_URL}/system_stats" > /dev/null 2>&1; then
  echo "FALHOU: ComfyUI nao responde em ${COMFYUI_URL}" >&2
  echo "Arrancar com: scripts/comfyui_start.sh" >&2
  exit 1
fi
echo "PASSOU: servidor responde"

# 2. Modelo ESRGAN presente
MODEL_LIST=$(curl -sf "${COMFYUI_URL}/object_info/UpscaleModelLoader" 2>/dev/null | \
  python3 -c "import sys, json; d = json.load(sys.stdin); print('\n'.join(d['UpscaleModelLoader']['input']['required']['model_name'][0]))" 2>/dev/null || echo "")

if echo "${MODEL_LIST}" | grep -q "${REQUIRED_MODEL}"; then
  echo "PASSOU: modelo ${REQUIRED_MODEL} disponivel"
else
  echo "FALHOU: modelo ${REQUIRED_MODEL} nao encontrado" >&2
  echo "Modelos disponiveis: ${MODEL_LIST}" >&2
  exit 1
fi

# 3. Fila de tarefas vazia (nao ha processamento em curso)
QUEUE=$(curl -sf "${COMFYUI_URL}/queue" 2>/dev/null | \
  python3 -c "import sys, json; d = json.load(sys.stdin); print(len(d.get('queue_running', [])) + len(d.get('queue_pending', [])))" 2>/dev/null || echo "0")
echo "PASSOU: fila de tarefas = ${QUEUE} itens"

echo "=== ComfyUI pronto ==="
```

```bash
chmod +x scripts/comfyui_health.sh
bash scripts/comfyui_health.sh
```

### 5.4 Como arrancar o servidor

**Localizar a instalacao do ComfyUI:**
```bash
# Opcao 1: instalacao padrao em home
ls ~/ComfyUI/main.py 2>/dev/null && echo "Encontrado em ~/ComfyUI"

# Opcao 2: procurar em Programacao
find ~/Programacao -name "main.py" -path "*/ComfyUI/*" 2>/dev/null | head -5
```

**Arrancar (em background):**
```bash
# Substituir CAMINHO_COMFYUI pelo caminho real encontrado acima
CAMINHO_COMFYUI=~/ComfyUI
cd "${CAMINHO_COMFYUI}"
python3 main.py --listen 127.0.0.1 --port 8188 &
COMFY_PID=$!
echo "ComfyUI PID: ${COMFY_PID}"

# Aguardar estar pronto (maximo 60 segundos)
for i in $(seq 1 60); do
  if curl -sf http://127.0.0.1:8188/system_stats > /dev/null 2>&1; then
    echo "ComfyUI pronto ao fim de ${i}s"
    break
  fi
  sleep 1
done
```

**Script de arranque completo:** guardar em `scripts/comfyui_start.sh` com o conteudo acima.

**Parar o servidor:**
```bash
kill "${COMFY_PID}" 2>/dev/null || pkill -f "python3 main.py --listen 127.0.0.1 --port 8188"
```

---

## 6. Tarefas da Fase 6

Lista de tarefas a adicionar ao backlog em `backlog/fase-6/`. Cada tarefa segue o formato
obrigatorio do projecto (ver `AGENTS.md` secao 2 e os ficheiros em `backlog/fase-0/`).

### 6.1 Tabela de tarefas

| ID | Titulo | Tipo | Depende de | Criterio de saida |
|---|---|---|---|---|
| T-601 | Setup e verificacao do ComfyUI local | infra | nenhum | `scripts/comfyui_health.sh` com exit 0 |
| T-602 | Script de verificacao de alpha e paleta | codigo | T-601 | pytest em `scripts/test_comfyui_tools.py` a PASSOU |
| T-603 | Upscale 4x de human_base.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-604 | Upscale 4x de fishingrod.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-605 | Upscale 4x de raw_fish.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-606 | Upscale 4x de dummy_object.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-607 | Upscale 4x de tilemap.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-608 | Upscale 4x de tilemap-separated.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU, aprovacao do Rodolfo |
| T-609 | Upscale 4x de buttons.png | visual | T-601, T-602 | criterios da secao 2.5 todos PASSOU (se mantido no export) |
| T-610 | Validacao integrada: Godot com todos os sprites upscalados | visual | T-603, T-604, T-605, T-606, T-607, T-608 | verify.sh --full sem FALHOU, screenshot com sprites a 4x visivelmente mais nitidos |
| T-611 | Novos sprites: 8 objectos do companheiro | visual | T-610 | 8 PNGs em `game/object/`, paleta verificada, aprovacao do Rodolfo |
| T-612 | Novos sprites: 4 animais visitantes | visual | T-611 | 4 sprites em `game/object/animals/`, integrados nos eventos da Fase 3 |
| T-613 | Novos sprites: efeitos visuais (chuva, estrelas, bioluminescencia) | visual | T-611 | 4 sprites de efeitos, integrados no sistema de particulas |
| T-614 | Novos sprites: feriados (Natal, Ano Novo) | visual | T-611 | 4 sprites em `game/object/holidays/`, integrados no modulo de calendario |
| T-615 | Fecho da Fase 6: verify.sh --full e actualizacao do roadmap | docs | T-610, T-614 | verify.sh --full sem FALHOU, roadmap actualizado, CHANGELOG com versao 0.6.0 |

### 6.2 Templates das tarefas de backlog

Os ficheiros abaixo devem ser criados em `backlog/fase-6/`. Os titulos de seccao precisam dos
acentos correctos (o `backlog.py check` rejeita versoes sem acento).

**T-601: Setup e verificacao do ComfyUI local**

```markdown
---
id: T-601
titulo: Setup e verificacao do ComfyUI local
fase: 6
estado: pronto
tipo: infra
depende_de: []
---

## Objectivo
Garantir que o ComfyUI esta instalado, com os modelos ESRGAN necessarios, e que o
script de health check confirma tudo binariamente.

## Ler antes
- `docs/grafico-polimento.md` seccao 5 (Configuracao do ComfyUI Local)
- `docs/assets-licencas.md`

## Critérios de aceitação
- [ ] `scripts/comfyui_start.sh` existe e arranca o servidor em 127.0.0.1:8188
- [ ] `scripts/comfyui_health.sh` tem exit 0
- [ ] `curl http://127.0.0.1:8188/object_info/UpscaleModelLoader` lista "4x-UltraSharp.pth"
- [ ] `scripts/check_docs.py` sem FALHOU

## Fora de âmbito
- Instalar o ComfyUI se nao estiver instalado: tarefa passa a estado humano
- Configurar Stable Diffusion 1.5 ou LoRAs (necessario so no Caminho B)

## Prova exigida
- Output de `bash scripts/comfyui_health.sh` no Relatorio
- `docs/proof/T-601-comfyui-health.png` (screenshot da interface web)

## Relatorio
```

**T-602: Script de verificacao de alpha e paleta**

```markdown
---
id: T-602
titulo: Script de verificacao de alpha e paleta para sprites upscalados
fase: 6
estado: pronto
tipo: codigo
depende_de: [T-601]
---

## Objectivo
Criar dois scripts Python que os agentes usam para validar sprites apos upscale:
`scripts/check_alpha.py` (transparencia preservada) e `scripts/quantize_palette.py`
(reducao de paleta para o Caminho B).

## Ler antes
- `docs/grafico-polimento.md` seccao 2.5 (Criterios de qualidade)
- `docs/grafico-polimento.md` seccao 3.2 (Consistencia de paleta)

## Critérios de aceitação
- [ ] `scripts/check_alpha.py original.png upscaled.png` com exit 0 se alpha preservado, exit 1 se nao
- [ ] `scripts/quantize_palette.py --reference ref.png --input in.png --output out.png` funciona
- [ ] Testes pytest em `scripts/test_comfyui_tools.py` com fixtures de PNGs sinteticos, a PASSAR
- [ ] `scripts/check_docs.py` sem FALHOU

## Fora de âmbito
- Interface grafica ou integracao com ComfyUI API
- Suporte a formatos nao PNG

## Prova exigida
- Output de `pytest scripts/test_comfyui_tools.py -v` no Relatorio

## Relatorio
```

**T-603: Upscale 4x de human_base.png**

```markdown
---
id: T-603
titulo: Upscale 4x de human_base.png com ESRGAN 4x-UltraSharp
fase: 6
estado: pronto
tipo: visual
depende_de: [T-601, T-602]
---

## Objectivo
Substituir `game/character/human_base.png` (144x72, modo P) pela versao upscalada
(576x288, modo RGBA) sem alterar o estilo ou a paleta.

## Ler antes
- `docs/grafico-polimento.md` seccao 2 (Caminho A)
- `docs/assets-licencas.md` (licenca original CC-BY 3.0)

## Critérios de aceitação
- [ ] `game/character/human_base.png` tem dimensoes 576x288
- [ ] Modo RGBA (nao P nem RGB)
- [ ] `scripts/check_alpha.py game/character/human_base.png.bak game/character/human_base.png` com exit 0
- [ ] `game/character/human_base.png.import` tem `texture/filter=0`
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] `bash scripts/verify.sh --visual` com screenshot mostrando o naufrago nitido
- [ ] `docs/proof/T-603-antes.png` e `docs/proof/T-603-depois.png` existem
- [ ] `docs/assets-licencas.md` actualizado com nota de upscale
- [ ] Estado passa a humano ate aprovacao visual do Rodolfo

## Fora de âmbito
- Alterar as animacoes ou o numero de frames
- Reanimar o sprite

## Prova exigida
- `docs/proof/T-603-antes.png` e `docs/proof/T-603-depois.png` (zoom 400% para se ver o detalhe)
- Output de `python3 -c "from PIL import Image; img = Image.open('game/character/human_base.png'); print(img.size, img.mode)"` no Relatorio

## Relatorio
```

As tarefas T-604 a T-609 seguem o mesmo template que T-603, substituindo o nome do ficheiro
e as dimensoes. A tabela abaixo resume os parametros variaveis:

| Tarefa | Ficheiro | Original | Resultado | Dependencias extras |
|---|---|---|---|---|
| T-604 | `character/fishingrod.png` | 32x6 | 128x24 | nenhuma |
| T-605 | `object/raw_fish.png` | 32x16 | 128x64 | nenhuma |
| T-606 | `object/dummy_object.png` | 16x32 | 64x128 | nota: e placeholder, pode ser substituido em T-611 |
| T-607 | `world/Tiny-Islands-by-Majadroid/tilemap.png` | 224x160 | 896x640 | verificar que tiles 64x64 alinham com TileSet do Godot |
| T-608 | `world/Tiny-Islands-by-Majadroid/tilemap-separated.png` | 320x256 | 1280x1024 | igual a T-607 |
| T-609 | `world/Tiny-Islands-by-Majadroid/buttons.png` | 96x128 | 384x512 | apenas se mantido no export; caso contrario marcar como nao aplicavel |

**Nota para T-607 e T-608:** o TileSet do Godot referencia tiles por posicao em pixeis.
Apos upscale 4x, o tamanho de cada tile passa de 16x16 para 64x64. O recurso TileSet
em `game/` deve ser actualizado para reflectir o novo `tile_size = Vector2i(64, 64)`.
Isto pode ser feito em GDScript ou directamente no `.tres` do TileSet. Verificar com
`bash scripts/verify.sh` apos a alteracao.

---

## 7. Notas de Implementacao para Agentes

### Ordem de execucao recomendada

```
T-601 -> T-602 -> T-603 -> T-604 -> T-605 -> T-606 -> T-607 -> T-608 -> T-609 -> T-610 -> T-611 -> T-612 -> T-613 -> T-614 -> T-615
```

As tarefas T-603 a T-609 podem ser executadas em paralelo depois de T-601 e T-602 estarem
feitas. Cada uma e independente das outras (ficheiros diferentes).

### Regra de rollback por tarefa

Cada tarefa de upscale faz backup do original antes de substituir. Se `verify.sh` falhar
apos a substituicao, restaurar o backup e registar no Relatorio o erro exacto.

### Comunicacao com o Rodolfo

Tarefas visuais ficam em `estado: humano` depois de o agente ter feito tudo o que podia.
O agente escreve no Relatorio: quais os ficheiros gerados, onde estao as provas, e o que
o Rodolfo precisa de confirmar. Nao marcar `estado: feito` sem resposta do Rodolfo.

### Verificacao que o ComfyUI esta offline

Antes de iniciar qualquer tarefa do Caminho A ou B:
```bash
bash scripts/comfyui_health.sh || { echo "ComfyUI offline. Arrancar com scripts/comfyui_start.sh"; exit 1; }
```

Se o ComfyUI nao estiver instalado, a tarefa T-601 passa automaticamente a `estado: humano`
e o agente reporta o bloqueio ao Rodolfo.
