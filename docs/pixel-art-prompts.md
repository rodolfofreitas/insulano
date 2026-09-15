# Insulano - Pixel Art Generation Prompts
## Painel de Especialistas: FLUX.2 Klein 4B + LoRA Pixel Art

*Documento gerado por painel de 3 especialistas em pixel art para jogos indie.*
*Projecto: Insulano - Godot 4 screensaver. ADR-013 activo.*
*Versão: 1.0 - 2026-09-16*

---

## Filosofia de Design

### Premissa Central
O Insulano é um ecrã de poupança com alma. O náufrago existe num espaço entre a comédia resignada e o charme indie - perto do **Graveyard Keeper** na personalidade, perto do **Stardew Valley** na legibilidade e cor. A câmara é **lateral** (side view), como o Johnny Castaway original. Cada sprite deve ser legível a tamanho final e belo a tamanho de geração.

> **Especialista A (Character):** "Cada personagem tem que contar uma história na sua silhueta. A 32x48px não há espaço para detalhes supérfluos - cada pixel tem propósito."

> **Especialista B (Environment):** "Os backgrounds são o espaço emocional do jogo. A paleta quente tropical cria a sensação de paraíso-prisão. Profundidade com 2-3 planos mesmo em sprites pequenos."

> **Especialista C (Technical):** "Consistency é rainha. Seed fixas por sprite, paleta master com índices, pipeline reproduzível. Um sprite gerado hoje deve ser combinável com um gerado daqui a 6 meses."

---

## 🎨 Paleta Mestre do Projecto (Master Palette)

Esta paleta governa **todos** os sprites. Variações são permitidas mas devem derivar destas cores-base.

| # | Nome | Hex | Uso |
|---|------|-----|-----|
| 1 | **Outline Escuro** | `#1a0a00` | Contorno de todos os sprites - caracteres, vegetação, objectos |
| 2 | **Areia Clara** | `#f4d47a` | Plataforma de areia, highlight de pele |
| 3 | **Areia Média** | `#c9a84c` | Areia em sombra, pele do náufrago |
| 4 | **Areia Escura** | `#8b6914` | Borda da plataforma, sombras profundas de areia |
| 5 | **Oceano Claro** | `#5bb8d4` | Água superficial, reflexos |
| 6 | **Oceano Médio** | `#2d7fa8` | Água principal, gradiente do céu |
| 7 | **Oceano Profundo** | `#1a4a6e` | Água em sombra, céu nocturno inferior |
| 8 | **Céu Tropical** | `#87ceeb` | Gradiente de céu diurno, superior |
| 9 | **Verde Palma** | `#4a8c2a` | Folhas de palmeira, vegetação |
| 10 | **Verde Escuro** | `#2d5a1a` | Sombra de folhas, arbustos |
| 11 | **Coco Castanho** | `#5c3d1e` | Cocos, tronco de palmeira, cabelo do náufrago |
| 12 | **Branco Sujo** | `#e8e0d0` | Gaivota, espuma do mar, nuvens |

---

## Sprites Prioritários - Top 8

---

### 1. Náufrago Idle

**Descrição:** Homem barbudo, descalço, calções esfarrapados, expressão resignada mas bem-humorada. Pose de espera - levemente inclinado, braços relaxados.

---

#### 👥 Debate do Painel

> **Especialista A:** "Quero a cabeça ligeiramente inclinada para um lado - a pose de 'e agora?'. Barba espessa mas desenhada com 3-4 tons, não só pixels aleatórios. Os calções têm que ter buraco visível na coxa direita."
>
> **Especialista B:** "Discordo na inclinação - a 32px vai parecer bug. Manteria a cabeça direita mas com os ombros ligeiramente caídos. Isso lê-se melhor a pequena escala."
>
> **Especialista C:** "Acordo com B para o sprite de produção. Mas no prompt de geração a 512px pedimos a pose expressiva do A - depois na edição final normalizamos a cabeça. Melhor gerar com personalidade e ajustar do que gerar neutro."
>
> **✅ Decisão:** Gerar com personalidade (Especialista A), normalizar cabeça em pós-processamento se necessário (Especialista C).

---

#### Prompt Positivo
```
pixel art game sprite, castaway man idle pose, side view facing right,
bearded man with thick unkempt beard, bare feet, tattered brown shorts with visible tear,
resigned but good-humored expression, slight shoulder droop, relaxed arms at sides,
(indie game character:1.3), (Stardew Valley style:1.2), (Graveyard Keeper aesthetic:1.1),
warm tropical color palette, (1px black outline:1.4), clean pixel art,
(32x48 pixel character:1.3), transparent background, single character sprite,
sun-bronzed skin 4 tone shading, expressive face despite small size,
tousled dark hair, stubble to full beard gradient, worn fabric texture on shorts,
pixel art spritesheet style, game-ready asset, (no anti-aliasing:1.5),
(crisp pixel edges:1.4), limited color palette 16 colors max
```

#### Prompt Negativo
```
3D render, photorealistic, smooth gradients, anti-aliasing, blurry edges,
chibi proportions, anime style, cartoon vector, watercolor, oil painting,
multiple characters, background scenery, top-down view, front view,
modern clothing, shoes, clean clothes, shaved, unhappy grimace,
extra limbs, deformed hands, floating pixels, noise artifacts,
high resolution painting style, digital art non-pixel, CGI
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×768px (manter ratio 2:3 do sprite final) |
| **Seed sugerida** | `42069` |
| **CFG Scale** | 7.5 |
| **Steps** | 35 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.85 |
| **LoRA** | game-character-sheet v1.0, weight 0.6 |

#### Paleta Específica (6 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Outline | `#1a0a00` | Contorno e linha interna |
| Pele clara | `#e8956a` | Highlight de pele, face |
| Pele média | `#c9723a` | Pele base |
| Pele escura | `#8b4a1e` | Sombra de pele |
| Calções | `#6b4423` | Tecido desbotado |
| Calções claro | `#9a6b3a` | Highlight de tecido |

#### Notas de Pós-Processamento
1. **Downscale:** Escalar de 512×768 para 32×48px com **nearest-neighbor** (nunca bilinear/bicubic)
2. **Paleta:** Aplicar paleta mestre com índice fixo - usar Aseprite > Palette > Apply Palette
3. **Outline check:** Verificar que o contorno `#1a0a00` está 100% fechado (sem gaps)
4. **Transparência:** Background branco/uniforme → Cor>Cor Alpha em Aseprite
5. **Pixels soltos:** Verificar e remover pixels isolados de 1px que não pertencem ao contorno

---

### 2. Náufrago a Andar

**Descrição:** Mesmo personagem, mid-stride para a direita, perna esquerda à frente, braço direito balançado.

---

#### 👥 Debate do Painel

> **Especialista A:** "O stride tem que ser exagerado - a 32px o movimento sutil desaparece. Perna levantada a pelo menos 45°. Braços em oposição clara. Expressão no rosto deve ser idêntica ao idle - continuidade de personagem."
>
> **Especialista B:** "Concordo no exagero. Adicionar sombra projectada no chão para anchorar o personagem - mesmo que seja só 3-4 pixels de elipse."
>
> **Especialista C:** "Atenção: este sprite vai fazer parte de um walk cycle. O prompt deve pedir APENAS o frame mid-stride - não um ciclo completo. Seed diferente do idle mas com os mesmos parâmetros de LoRA para consistência."
>
> **✅ Decisão:** Frame único mid-stride com expressão idêntica ao idle, seed offset +1 da idle seed.

---

#### Prompt Positivo
```
pixel art game sprite, castaway man walking animation frame, mid-stride pose,
side view facing right, same bearded character, left leg forward right leg back,
right arm swung forward left arm back, (dynamic walking pose:1.3),
(indie game walk cycle frame:1.4), Stardew Valley character movement style,
warm tropical palette, (1px black outline:1.4), bare feet in motion,
tattered shorts flapping slightly, (mid-stride single frame:1.5),
same face same beard same outfit as idle sprite, consistent character design,
pixel art spritesheet single frame, transparent background, no background,
(crisp pixel art:1.5), (no anti-aliasing:1.5), limited 16 color palette,
game-ready sprite asset, exaggerated stride for small resolution
```

#### Prompt Negativo
```
multiple frames, animation strip, spritesheet grid, standing pose, idle pose,
3D render, smooth gradients, anti-aliasing, blurry, different character design,
different clothes, background, scenery, top-down, front facing,
motion blur, speed lines, extra frames, contact frame, floating
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×768px |
| **Seed sugerida** | `42070` (idle +1) |
| **CFG Scale** | 7.5 |
| **Steps** | 35 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.85 |
| **LoRA** | game-character-sheet v1.0, weight 0.6 |

#### Paleta Específica
Idêntica ao Náufrago Idle - **obrigatório** para consistência de personagem.

#### Notas de Pós-Processamento
1. **Downscale:** 512×768 → 32×48px nearest-neighbor
2. **Alignment:** Posicionar os pés na mesma linha baseline do sprite idle
3. **Palette lock:** Usar exactamente os mesmos índices de cor do idle (importar paleta do idle no Aseprite)
4. **Comparação:** Colocar idle e walk side-by-side para verificar consistência de proporções antes de finalizar

---

### 3. Palmeira Principal

**Descrição:** Palmeira alta e tropical, vista lateral, com cocos visíveis, sombra própria, folhas expressivas.

---

#### 👥 Debate do Painel

> **Especialista A:** "A palmeira é o cenário-personagem da ilha. Tem que ter carácter - ligeiramente curvada, com 5-7 folhas de tamanhos diferentes. Os cocos devem ser discretos mas identificáveis."
>
> **Especialista B:** "Estrutura em 3 planos: tronco com textura de fibra, folhas em camadas (2 atrás, 3 à frente), sombra elíptica no chão. A sombra é crucial para anchorar a árvore na areia."
>
> **Especialista C:** "Dois sprites distintos: palmeira SEM sombra (para compor com a plataforma) e palmeira COM sombra (para uso standalone). O prompt deve especificar qual. Começo com a SEM sombra."
>
> **✅ Decisão:** Gerar versão sem sombra integrada; sombra é adicionada via código Godot (shader ou sprite separado). Simplifica pipeline e permite animação da sombra.

---

#### Prompt Positivo
```
pixel art game sprite, tropical palm tree side view, tall coconut palm,
slightly curved trunk with fiber texture detail, (5-7 palm fronds:1.3),
large fan leaves with internal gradient shading, (2-3 coconuts visible:1.2),
no ground shadow (separate layer), isolated tree sprite transparent background,
(indie game environment asset:1.4), Stardew Valley vegetation style,
warm tropical greens, (1px dark outline on leaves:1.3),
brown fibrous trunk segments, lighter trunk highlights,
(64x128 pixel scale environment:1.3), pixel art vegetation,
(no anti-aliasing:1.5), (crisp pixel edges:1.4),
limited palette greens and browns, game-ready tileable asset,
layered leaf depth (back leaves darker front leaves lighter)
```

#### Prompt Negativo
```
3D tree, photorealistic bark, smooth gradients, anti-aliasing,
cartoon vector flat, ground included, shadow baked in,
multiple trees, forest background, front-facing symmetric tree,
top-down view, dead tree, autumn colors, snow, unrealistic proportions,
extra thin trunk, broken branches, no leaves, floating elements
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×1024px (ratio 1:2 para palmeira alta) |
| **Seed sugerida** | `73412` |
| **CFG Scale** | 7.0 |
| **Steps** | 30 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.8 |
| **LoRA** | pixel-art-nature v1.0, weight 0.7 |

#### Paleta Específica (7 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Outline | `#1a0a00` | Contorno |
| Tronco claro | `#8b6914` | Highlight de tronco |
| Tronco médio | `#5c3d1e` | Tronco base |
| Tronco escuro | `#3d2510` | Sombra de tronco |
| Folha clara | `#6ab04a` | Highlight de folhas |
| Folha média | `#4a8c2a` | Folhas base |
| Folha escura | `#2d5a1a` | Sombra de folhas, profundidade |

#### Notas de Pós-Processamento
1. **Downscale:** 512×1024 → 64×128px nearest-neighbor
2. **Folhas:** Verificar que cada folha tem pelo menos 2 tons de verde (highlight + base)
3. **Tronco:** As linhas horizontais de fibra devem ser visíveis a 64px (pelo menos 1px de contraste)
4. **Cocos:** A 64px os cocos devem ser pontos de 2×2px no tom `#5c3d1e`
5. **Transparência:** Fundo deve ser completamente limpo - verificar cantos das folhas

---

### 4. Plataforma de Areia

**Descrição:** Tile horizontal seamless, areia quente, borda inferior com água, repetível infinitamente.

---

#### 👥 Debate do Painel

> **Especialista A:** "Este tile é o chão onde o náufrago vive. Tem que ter variação subtil de textura - grãos de areia implícitos mas não barulhentos. Dithering fino no topo para simular textura."
>
> **Especialista B:** "Estrutura em 3 camadas verticais: areia clara no topo, transição com dithering, água turquesa na borda inferior. O tile deve ter 'profundidade percebida' mesmo sendo plano. Adicionar uma ou duas conchas ou pebbles para variação."
>
> **Especialista C:** "CRÍTICO: Este tile tem que fazer seamless perfeito. O prompt deve pedir explicitamente seamless/tileable. Resolução de geração: 512×256 (ratio 2:1) para depois escalar para 256×64. Seed com resultado seamless verificado."
>
> **✅ Decisão:** Tile seamless horizontal com água na borda inferior, dithering sutil na areia, 1-2 detalhes mínimos (concha ou pedregulho).

---

#### Prompt Positivo
```
pixel art game tile, seamless horizontal sand platform tile, side view,
(seamless tileable texture:1.5), warm sandy beach ground,
top layer bright warm sand with subtle dithering grain texture,
middle layer medium sand with slight shadow,
bottom edge shallow turquoise water border (1/4 height),
(water edge with tiny wave pixels:1.2), 1 or 2 small shells or pebbles as detail,
(indie game platform tile:1.4), Stardew Valley ground tile style,
(no visible tile seams:1.5), horizontal repeat seamless,
warm golden sandy palette, (1px dark edge outline:1.2),
(256x64 pixel tile scale:1.3), pixel art ground asset,
(no anti-aliasing:1.5), (crisp pixels:1.4), limited palette
```

#### Prompt Negativo
```
visible seams, tile edges, not seamless, stone tile, grass tile,
3D render, smooth gradient, anti-aliasing, top-down view,
complex pattern, too many details, busy texture, photorealistic sand,
dark sand, grey sand, wet sand, mud, dirt, snow, ice
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×256px |
| **Seed sugerida** | `88421` |
| **CFG Scale** | 6.5 |
| **Steps** | 28 |
| **Sampler** | Euler a |
| **LoRA** | pixel-art-sprites v1.0, weight 0.75 |
| **LoRA** | pixel-art-tiles v1.0, weight 0.85 |

#### Paleta Específica (6 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Areia clara | `#f4d47a` | Topo da plataforma, luz directa |
| Areia média | `#c9a84c` | Areia base, área principal |
| Areia escura | `#8b6914` | Sombra de areia, borda lateral |
| Água clara | `#5bb8d4` | Borda de água, reflexo |
| Água média | `#2d7fa8` | Água principal na borda inferior |
| Outline | `#1a0a00` | Linha de borda do tile |

#### Notas de Pós-Processamento
1. **Downscale:** 512×256 → 256×64px nearest-neighbor
2. **Teste seamless:** Duplicar o tile horizontalmente em Aseprite e verificar que a junta não é visível a 1px de distância
3. **Borda de água:** Deve ter exatamente 12-16px de altura no tile final (64px)
4. **Godot:** Importar como `TileSet` com modo `Seamless` activado
5. **Variação:** Gerar 2-3 variantes com seeds diferentes para variedade na ilha (mesma paleta, detalhes diferentes)

---

### 5. Horizonte Oceano

**Descrição:** Faixa lateral/background, gradiente azul, ondas subtis, luz do sol ao horizonte.

---

#### 👥 Debate do Painel

> **Especialista A:** "O horizonte tem que criar sensação de imensidão. Linha do horizonte a 1/3 da altura. Sol - mesmo que seja só um semicírculo de pixels amarelos - faz toda a diferença emocional."
>
> **Especialista B:** "Acordado. 3 zonas: céu no topo (20%), faixa de sol/horizonte (30%), oceano no fundo (50%). O oceano usa dithering checker clássico pixel art com 2 tons de azul. Ondas são padrão de 3px de altura, repetível."
>
> **Especialista C:** "Este é um background tile - precisa de ser seamless horizontal também. Gerar em 512×256, usar para tile de 256×128px. A linha do horizonte deve estar exactamente a altura constante para não piscar ao tile."
>
> **✅ Decisão:** Background tile seamless com 3 zonas (céu/horizonte/oceano), sol discreto, dithering clássico na água.

---

#### Prompt Positivo
```
pixel art background tile, ocean horizon side view, seamless horizontal tile,
(seamless tileable:1.5), tropical ocean panorama,
top 20% sky with warm blue gradient, horizon line at 1/3 height,
(small sun or sun reflection on water:1.2), warm golden light at horizon,
ocean fills bottom half with (classic 2-tone dithering pattern:1.3),
subtle wave pattern 3px height repeating, deep blue to medium blue gradient,
(indie game background:1.4), Celeste-style background depth,
no characters, no land visible, infinite ocean feel,
(256x128 pixel background tile:1.3), pixel art environmental art,
(no anti-aliasing:1.5), limited blue palette with warm sun accent,
(crisp pixel dithering:1.4)
```

#### Prompt Negativo
```
land visible, characters, trees, beach, sand, top-down, front view,
photorealistic water, smooth gradients, anti-aliasing, stormy weather,
night sky, dark ocean, monochrome, visible tile seams, complex cloud patterns
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×256px |
| **Seed sugerida** | `55831` |
| **CFG Scale** | 6.0 |
| **Steps** | 28 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.7 |
| **LoRA** | pixel-art-backgrounds v1.0, weight 0.85 |

#### Paleta Específica (7 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Céu alto | `#87ceeb` | Céu superior |
| Horizonte | `#f0c060` | Luz do sol, reflexo no horizonte |
| Oceano claro | `#5bb8d4` | Água superficial, cristas de onda |
| Oceano médio | `#2d7fa8` | Água principal |
| Oceano fundo | `#1a4a6e` | Água em sombra, fundo do tile |
| Sol | `#ffd700` | Disco solar ou reflexo |
| Espuma | `#e8e0d0` | Cristas de ondas, espuma |

#### Notas de Pós-Processamento
1. **Downscale:** 512×256 → 256×128px nearest-neighbor
2. **Horizonte:** Linha do horizonte deve estar a exactamente y=42px no tile final (128px de altura)
3. **Seamless:** Testar tile horizontal - especialmente o padrão de ondas
4. **Composição:** Este tile fica atrás da plataforma de areia; verificar compatibilidade de paleta

---

### 6. Céu Diurno

**Descrição:** Faixa de fundo, gradiente azul claro, algumas nuvens, calor tropical.

---

#### 👥 Debate do Painel

> **Especialista A:** "Nuvens com carácter - não apenas blob branco. 2-3 nuvens de diferentes tamanhos, com 3 tons (highlight, base, sombra). Céu deve respirar calor - azul levemente amarelado no horizonte."
>
> **Especialista B:** "Para tile seamless, as nuvens não podem estar perto das bordas horizontais ou criam artefactos. Posicionar nuvens no centro ou usar nuvens decorativas que passam por cima do seam. Céu em paralax: este tile é a camada de fundo mais distante."
>
> **Especialista C:** "Seed importante para este - gerar 4-5 variantes e escolher a que tem melhor seamless. Largura de 512px (final 256px) facilita seamless. Nuvens devem ocupar <40% da área total."
>
> **✅ Decisão:** Tile seamless com nuvens no centro, distanciadas das bordas, gradiente de azul-quente.

---

#### Prompt Positivo
```
pixel art background tile, daytime tropical sky, seamless horizontal tile,
(seamless tileable:1.5), clear blue sky with (2-3 white clouds:1.2),
sky gradient (bright white-blue at top, warmer light blue at bottom),
(fluffy pixel art clouds with 3-tone shading:1.3) white highlight, cloud base, soft grey shadow,
clouds positioned in center not near tile edges, tropical warm atmosphere,
(indie game sky background:1.4), Stardew Valley sky style,
no sun visible (sun in horizon tile), no characters, no land,
(256x128 pixel sky tile:1.3), pixel art sky,
(no anti-aliasing:1.5), (crisp pixel clouds:1.4),
limited 6 color sky palette, warm tropical feeling, clear weather
```

#### Prompt Negativo
```
stormy clouds, dark sky, night sky, rain clouds, cartoon sun with face,
characters, land, ocean, smooth gradients throughout, anti-aliasing,
visible seams, complex cloud formations, too many clouds, busy texture,
photorealistic sky, overexposed, grey sky, winter sky
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×256px |
| **Seed sugerida** | `11947` |
| **CFG Scale** | 6.0 |
| **Steps** | 25 |
| **Sampler** | Euler a |
| **LoRA** | pixel-art-sprites v1.0, weight 0.7 |
| **LoRA** | pixel-art-backgrounds v1.0, weight 0.8 |

#### Paleta Específica (6 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Céu alto | `#87ceeb` | Azul de céu superior |
| Céu médio | `#a8d8ea` | Gradiente de céu |
| Céu baixo | `#c8e8f4` | Céu perto do horizonte, mais branco |
| Nuvem clara | `#e8e0d0` | Highlight de nuvem |
| Nuvem base | `#d0cdc8` | Nuvem base |
| Nuvem sombra | `#b8b4b0` | Sombra inferior de nuvem |

#### Notas de Pós-Processamento
1. **Downscale:** 512×256 → 256×128px nearest-neighbor
2. **Seamless check:** Espelhar tile e verificar transição de nuvens
3. **Camadas Godot:** Parallax layer com scroll factor 0.1 (nuvens movem mais devagar que ilha)
4. **Variantes:** Gerar 3 variantes com densidades diferentes de nuvens para o ciclo dia

---

### 7. Céu Nocturno

**Descrição:** Azul escuro/roxo, estrelas, coordenar com `NightSky.gd` existente.

---

#### 👥 Debate do Painel

> **Especialista A:** "O céu nocturno é o oposto emocional do dia - deve ser belo mas ligeiramente melancólico. Lua crescente no tile central, estrelas de diferentes tamanhos (1px e 2px) para profundidade."
>
> **Especialista B:** "NightSky.gd já existe - verificar se ele gera as estrelas proceduralmente. Se sim, o tile só precisa do gradiente de fundo e a lua. As estrelas do tile seriam decorativas/fixas, as do shader seriam as dinâmicas."
>
> **Especialista C:** "IMPORTANTE - coordenar com NightSky.gd. Se o GDScript adiciona estrelas em runtime, o tile deve ser só o gradiente + lua para evitar duplicação. Pedir ao prompt APENAS fundo nocturno sem estrelas, separar num segundo pass se necessário."
>
> **✅ Decisão:** Gerar tile base SEM estrelas (gradiente nocturno + lua). NightSky.gd adiciona estrelas proceduralmente. Gerar também versão COM estrelas como fallback caso NightSky.gd seja desactivado.

---

#### Prompt Positivo - Versão Base (para NightSky.gd)
```
pixel art background tile, tropical night sky background, seamless horizontal tile,
(seamless tileable:1.5), deep blue to purple gradient night sky,
NO stars (stars added by shader), (crescent moon in upper area:1.3),
moon with 3-tone shading (white highlight, cream base, grey shadow),
subtle moonlight glow around moon (2-3px soft pixel halo),
dark blue purple gradient (deep at top, slightly lighter at bottom for horizon glow),
(indie game night sky background:1.4), romantic melancholy atmosphere,
no characters, no land, no clouds,
(256x128 pixel background:1.3), pixel art night,
(no anti-aliasing:1.5), (crisp pixels:1.4), limited dark palette
```

#### Prompt Positivo - Versão Completa (fallback sem NightSky.gd)
```
pixel art background tile, tropical night sky with stars, seamless horizontal tile,
(seamless tileable:1.5), deep blue to dark purple gradient,
(scattered stars of 2 sizes 1px and 2px:1.3), crescent moon upper center,
moonlight reflection shimmer on distant ocean at horizon,
(10-15 visible stars:1.2), star twinkle variety (pure white and cream),
romantic tropical night atmosphere, indie game pixel art,
no characters, no land visible,
(256x128 pixel night background:1.3), (crisp pixel stars:1.4),
(no anti-aliasing:1.5), limited 8 color dark palette
```

#### Prompt Negativo
```
day sky, bright colors, sun, warm colors, characters, land, trees,
too many stars (cluttered), anti-aliasing, smooth gradients,
visible seams, photorealistic, cartoon moon with face,
stormy, rainy, neon colors, light pollution
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 512×256px |
| **Seed sugerida (base)** | `77203` |
| **Seed sugerida (completo)** | `77204` |
| **CFG Scale** | 6.5 |
| **Steps** | 30 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.75 |
| **LoRA** | pixel-art-backgrounds v1.0, weight 0.8 |

#### Paleta Específica (7 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Céu profundo | `#0d0a1a` | Céu superior, mais escuro |
| Azul nocturno | `#1a1a3e` | Gradiente principal de céu |
| Roxo nocturno | `#2d1a4a` | Toque roxo, mistério |
| Horizonte noite | `#1a4a6e` | Horizonte levemente mais claro |
| Lua clara | `#f0f0e0` | Highlight da lua |
| Lua base | `#d4d0c0` | Lua base |
| Estrelas | `#ffffff` | Estrelas (versão completa) |

#### Notas de Pós-Processamento
1. **Downscale:** 512×256 → 256×128px nearest-neighbor
2. **Coordenação NightSky.gd:** Verificar parâmetro `star_color` em NightSky.gd - usar `#ffffff` e `#e8e8d8` para consistência
3. **Transição:** Criar versão de transição (crepúsculo) interpolando esta paleta com a paleta de céu diurno
4. **Lua position:** Posicionar lua a ~x=192, y=32 no tile final (256×128) - zona que fica sempre visível

---

### 8. Gaivota

**Descrição:** Ave branca pequena, vista lateral, em voo com asas abertas.

---

#### 👥 Debate do Painel

> **Especialista A:** "A gaivota é personagem secundário - precisa de personalidade. Bico ligeiramente aberto, olho visível (1-2px preto), penas com 2-3 tons. Asas em posição de planagem, não de batimento."
>
> **Especialista B:** "Para leitura a pequena escala, a silhueta é tudo. Gaivota em voo tem que ser reconhecível em 16×8px - a silueta de M maiúsculo das asas é universal. Poucos detalhes mas os certos."
>
> **Especialista C:** "Sprite tiny - tamanho final ~16×8px. Gerar em 256×128px para ter detalhes suficientes, depois escalar. Seed importante aqui porque um pixel na posição errada desaparece. Gerar 5 variantes e escolher a melhor silhueta."
>
> **✅ Decisão:** Silhueta prioritária (Especialista B), com detalhe mínimo de olho e bico (Especialista A). Gerar em 256×128, escalar para 16×8px.

---

#### Prompt Positivo
```
pixel art game sprite, seagull in flight side view, small bird sprite,
(white seagull flying:1.4), wings spread in gliding position M-shape,
side view facing right, visible eye (1-2 pixels black dot),
slightly open beak, (crisp bird silhouette:1.5),
white and light grey feathers with minimal shading (3 tones max),
yellow-orange beak detail, black wingtip pixels,
(tiny game sprite:1.4), instantly recognizable bird silhouette,
transparent background, single bird no flock,
indie game style, (no anti-aliasing:1.5), pixel art animal sprite,
(16x8 pixel scale bird:1.3), (crisp pixel edges:1.5)
```

#### Prompt Negativo
```
flock of birds, multiple birds, perched bird, standing bird, cartoon bird,
3D render, smooth feathers, anti-aliasing, realistic feather detail,
background, landscape, ocean, complex wing position, flapping mid-stroke,
too large, too detailed, pigeon, eagle, parrot, different bird species
```

#### Parâmetros Técnicos
| Parâmetro | Valor |
|-----------|-------|
| **Resolução de geração** | 256×128px |
| **Seed sugerida** | `33156` |
| **CFG Scale** | 8.0 |
| **Steps** | 35 |
| **Sampler** | DPM++ 2M Karras |
| **LoRA** | pixel-art-sprites v1.0, weight 0.9 |
| **Variantes a gerar** | 5 (escolher melhor silhueta) |

#### Paleta Específica (5 cores)
| Cor | Hex | Uso no sprite |
|-----|-----|---------------|
| Outline | `#1a0a00` | Contorno da gaivota |
| Branco pluma | `#e8e0d0` | Corpo, asas (cor primária) |
| Cinza pluma | `#c0b8a8` | Sombra de asas, profundidade |
| Bico | `#e8a030` | Bico amarelo-laranja |
| Olho | `#0a0a0a` | Ponto de olho |

#### Notas de Pós-Processamento
1. **Downscale:** 256×128 → 16×8px nearest-neighbor
2. **Silhueta check:** A 16×8 a gaivota deve ser reconhecível como pássaro em voo sem contexto
3. **Olho:** A 16×8 o olho é 1 pixel - verificar que não desapareceu no downscale
4. **Frame de voo:** Se necessário um ciclo de voo, este é o frame de planagem; o frame de batimento de asas tem as asas levantadas (~45°)

---

## Regras de Consistência

*Estas regras aplicam-se a TODOS os sprites do projecto Insulano sem excepção.*

### 1. Outline Obrigatório
- Cor: `#1a0a00` (nunca `#000000` puro - muito duro)
- Espessura: **1px** em todos os sprites
- O outline deve ser **fechado** (sem gaps na silhueta)
- Excepção: elementos de fundo seamless não têm outline nos bordos do tile

### 2. Paleta Indexada
- Máximo **16 cores** por sprite de personagem
- Máximo **8 cores** por tile de fundo
- **Todas** as cores devem pertencer à Master Palette ou ser derivações documentadas
- Usar Aseprite com paleta indexada activa durante edição para evitar drift de cor

### 3. Tamanhos Finais Canónicos
| Tipo | Tamanho Final | Tamanho de Geração |
|------|--------------|-------------------|
| Personagem (náufrago) | 32×48px | 512×768px |
| Personagem pequeno (gaivota) | 16×8px | 256×128px |
| Árvore/Vegetação | 64×128px | 512×1024px |
| Tile de plataforma | 256×64px | 512×256px |
| Background tile | 256×128px | 512×256px |

### 4. Downscale Sempre Nearest-Neighbor
- Nunca usar bilinear, bicubic, ou Lanczos em sprites
- Em Aseprite: Image > Scale > Interpolation: None
- Em Python/PIL: `Image.NEAREST`
- Em Godot: `texture_filter = TEXTURE_FILTER_NEAREST`

### 5. Baseline de Personagens
- O fundo dos pés do náufrago está na mesma linha em TODOS os frames de animação
- Esta baseline alinha-se com o topo da plataforma de areia

### 6. Vista Lateral Exclusiva
- Todos os sprites de personagem e vegetação são em **side view**
- Personagens olham para a **direita** por defeito (virar horizontalmente para a esquerda em código)
- Sem perspectiva isométrica, sem top-down

### 7. Seeds Documentadas
- Cada sprite tem uma seed fixa documentada neste ficheiro
- Regenerar com a mesma seed reproduz resultados idênticos
- Alterar seed = sprite diferente = rever consistência com restantes sprites

### 8. Sem Anti-Aliasing
- Todos os prompts incluem `(no anti-aliasing:1.5)` e `(crisp pixel edges:1.4)`
- Em pós-processamento, verificar e remover pixels semi-transparentes manualmente

### 9. Atmosfera Quente
- A ilha está sempre em clima tropical quente
- Paleta sempre inclinada para tons quentes (amarelos, laranjas, verdes saturados)
- Nunca tons frios/azulados nos sprites de primeiro plano (reservado para oceano/céu)

### 10. Personagem Consistente
- O náufrago tem a mesma barba, os mesmos calções, o mesmo tom de pele em TODOS os sprites
- Ao adicionar novos frames, importar a paleta do sprite idle como referência

---

## Pipeline Recomendado

### Fase 1 - Setup
```bash
# Instalar FLUX.2 Klein 4B (quando disponível)
# Instalar LoRA pixel-art-sprites
# Configurar ComfyUI ou A1111 com workflow pixel art
# Verificar: docs/comfyui/ para workflow existente no projecto
```

### Fase 2 - Geração

**Ordem recomendada de geração:**

1. **Primeiro: Náufrago Idle** (ancora a paleta de personagem)
2. **Segundo: Náufrago a Andar** (validar consistência com idle)
3. **Terceiro: Palmeira** (ancora a paleta de vegetação)
4. **Quarto: Plataforma de Areia** (ancora paleta de chão)
5. **Quinto: Horizonte Oceano** (âncora de fundo)
6. **Sexto: Céu Diurno** (completa background dia)
7. **Sétimo: Céu Nocturno** (completa background noite)
8. **Oitavo: Gaivota** (personagem secundário independente)

**Por cada sprite:**
```
1. Usar seed documentada
2. Gerar 4 variantes (mesma seed ±1, ±2)
3. Escolher variante com melhor silhueta/legibilidade
4. Documentar seed final escolhida
```

### Fase 3 - Pós-Processamento em Aseprite

```
1. Abrir imagem gerada (512px)
2. Aplicar Master Palette (Palette > Apply Palette)
3. Corrigir outline manualmente onde necessário
4. Verificar transparência (sem pixels semi-transparentes)
5. Scale Down: Image > Scale > [tamanho final] > Interpolation: None
6. Verificar legibilidade a tamanho final (zoom out a 1:1)
7. Ajuste final de pixels soltos ou artefactos
8. Exportar como PNG com transparência
```

### Fase 4 - Integração Godot

```gdscript
# Em todos os nós de sprite:
$Sprite2D.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
# Ou em Project Settings:
# Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest
```

### Fase 5 - Validação

**Checklist por sprite antes de commit:**
- [ ] Outline `#1a0a00` fechado
- [ ] Paleta indexada correcta (≤16 cores)
- [ ] Tamanho final correcto
- [ ] Transparência limpa
- [ ] Legível a tamanho final (1:1 zoom)
- [ ] Seed documentada neste ficheiro
- [ ] Consistente com sprites do mesmo personagem/ambiente

### Ferramentas no Pipeline

| Ferramenta | Uso | Onde |
|------------|-----|------|
| **FLUX.2 Klein 4B** | Geração base | ComfyUI (docs/comfyui/) |
| **LoRA pixel-art-sprites** | Estilo pixel art | ComfyUI LoRA node |
| **Aseprite** | Edição, paleta, downscale | Local |
| **Python + Pillow** | Batch processing, downscale | Scripts a criar em scripts/ |
| **Godot 4** | Integração, teste in-game | Projecto principal |

---

*Documento mantido pelo painel de especialistas. Actualizar seeds e notas após cada sessão de geração.*
*Próxima revisão: após Fase 7 do roadmap.*
