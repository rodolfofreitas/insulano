# Identidade Visual do Insulano

*Documento de Art Direction v1.0 -- audiencia: agentes de codigo e Rodolfo.*

Repositorio: `~/Programacao/Kaeto/Insulano`. Todos os caminhos sao relativos a esta raiz.

---

## 1. Referencia Visual e Objectivo

### 1.1 Johnny Castaway como inspiracao legal

O Johnny Castaway (Sierra On-Line, 1992) e a referencia de produto, nao de assets. Os sprites
originais sao propriedade da Sierra/Activision e estao proibidos neste projecto (ver
`docs/assets-licencas.md` secao Proibido). O que se estuda e a linguagem visual, nao os
pixeis concretos.

O que torna o Johnny Castaway visualmente eficaz:

| Elemento | Descricao tecnica | Objectivo para o Insulano |
|---|---|---|
| Proporcoes do personagem | ~60x80px, cabeca/corpo em ratio 1:2.5, humanamente verosimil | Abandono do ratio chibi actual (cabeca grande), transicao para 1:2 a 1:2.5 |
| Pele e bronzeado | 3 a 4 tons de castanho quente com transicao suave via dithering | Paleta de pele de 4 tons por fase/estacao |
| Silhueta legivel | Contorno escuro consistente (1px), personagem reconhecivel a qualquer tamanho | Contorno preto `#1a0a00` ou `#0d0500` em todos os sprites |
| Ilha com profundidade | Areia com gradiente centro-claro/bordas-escuras, sombra real da palmeira | Background pintado, nao tilemap plano |
| Palmeira com textura | Tronco com linhas de fibra, folhas com gradiente interno, cocos visiveis | Arvores proprias desenhadas pixel a pixel |
| Oceano com dithering | Padrao alternado azul/roxo na agua, horizonte distinto | Shader de onda ou dithering com 2 a 3 tons de azul |

### 1.2 Inventario de Referencia: Sprites do Johnny Castaway (Spriters Resource)

Este inventario foi compilado a partir dos sprites originais do Johnny Castaway (Sierra On-Line, 1992)
obtidos via Spriters Resource para fins de referencia e estudo de linguagem visual. Os sprites
originais sao propriedade da Sierra/Activision e estao proibidos neste projecto. O que se documenta
aqui e o vocabulario de animacoes e eventos -- nao os pixeis.

#### Folha 1: gjdive.bmp e mjoive.bmp (mergulho e agua)

**Johnny, animacoes de agua:**
- Johnny a mergulhar em varios angulos: de frente, de lado, de costas, em espiral
- Queda na agua, a boiar, a afundar dramaticamente
- Animacao de bola a rolar (evento comico)
- Sombra de queda projectada no chao

**Efeitos de agua observados:**
- Splash pequeno lateral (4-6 frames)
- Splash grande central, explosao de agua (6-8 frames)
- Splash em arco e splash vertical alto
- Pingos de agua dispersos
- Ondulacoes de superficie (loop)

**Personagens secundarios observados:**
- Sereia deitada (3 poses: a boiar, a relaxar, a desaparecer sob a agua) -- correspondencia directa com o arco "O Amor Imaginario" do Insulano
- Pato azul (mascote, 3 poses)
- Gaivota branca (4 poses: de pe, a ler jornal, a voar com papel, parada)
- Bote insuflavel vermelho (3 estados: vazio, com Johnny dentro, afundado)
- Sistema de pontuacao numerico para o evento de mergulho com pontos (5.6, 5.2, 10.0, etc.)

**Macaco Mojo (mjoive.bmp):**
- Ciclo de corrida (4 frames)
- Mergulho, fase aerea, nado
- Garrafa com Mojo dentro (evento comico de escala errada)
- Fragmentos de explosao verde

#### Folha 2: Spritesheet Completo do Johnny e Mojo

**Animacoes principais do Johnny catalogadas:**

| Ficheiro de referencia | Conteudo | Relevancia para o Insulano |
|---|---|---|
| `gjhot.bmp` | Deitado a apanhar sol, poses relaxadas | Equivale ao nosso `sleep`/`idle_deitado` |
| `gjhorse.bmp` | A montar um cavalo (evento absurdo raro) | Inspira eventos raros do tipo "de onde vem isto" |
| `gjhula.bmp` | A dancar hula com saia de palha | Evento comico raro: celebracao com disfarce |
| `gjhunt.bmp` | A catar algo, depois tornado de frustacao | Inspira animacao `tornado` (evento de frustacao) |
| `gjwalk.bmp` | Ciclo de caminhada 4 direccoes, ~8 frames por direccao, 32 frames total | Base para o nosso ciclo de walk |
| `gjwsol.bmp` | Poses contemplativas solitarias | Inspira `idle` das Fases IV e V (mais lento, mais silencioso) |
| `litebulb.bmp` | Momento eureka com lampada acima da cabeca | Evento `eureka` com sprite de lampada separado |
| `sjrftsk.bmp` | Surf de areia ou skate improvisado | Evento raro: naufrago inventa desporto |
| `sjrftik.bmp` | Tecnica especial de pesca com bastao | Variante da animacao `fish` |
| `sjwork.bmp` | A cavar com pa | Animacao `dig` para construcao de jangada e sinalizacao |
| `sjsur.bmp` | Surf com prancha | Evento raro de agua |
| `sleep.bmp` | Deitado a dormir, varias poses, a roncar | Base detalhada para o nosso `sleep` |
| `jcharge.bmp` | A correr para qualquer coisa com energia | Animacao de corrida ou carga (evento de entusiasmo) |
| `sjrjop.bmp` | A saltar, animacao de salto exagerado | `startle` exagerado ou evento de celebracao |
| `mjtele.bmp` | Mojo com telescopio, a ver ao longe | Equivale ao `look_up` do naufrago a ver navios |
| `mjbath.bmp` | Mojo a tomar banho | Evento comico: naufrago a "tomar banho" na chuva |
| `mjjob1.bmp` | Mojo a trabalhar | Animacao de trabalho geral |
| `sttoll.bmp` | Parado com ar de tolo, a olhar sem destino | Variante do `idle` de aborrecimento (TEDIO alto) |
| `shmist.bmp` | Nevoa / misterio | Efeito visual de evento lendario |

---

### 1.3 Estilo Visual do Insulano

O Insulano nao copia o Johnny Castaway: define o seu proprio dialecto visual a partir dos mesmos
principios. O estilo-alvo e descrito assim:

**Realista-caricato**: as proporcoes sao humanas (nao chibi), mas ligeiramente exageradas nos
elementos expressivos: olhos um pouco maiores, postura um pouco mais dramatica, gestos
que comunicam estado emocional sem texto. Pensa num personagem de banda desenhada de 8 pixeis
por olho, nao de 2.

**Proporcional**: ratio cabeca/corpo entre 1:2 e 1:2.5. A 64x96px, a cabeca ocupa cerca de
32px de altura. As maos e pes sao visiveis e articulados.

**Com personalidade lida na silhueta**: o naufrago em Fase I e o mesmo em Fase V em termos de
estrutura de sprite, mas a silhueta ja comunica a diferenca: Fase I ombros encolhidos, Fase V
cabelo e barba que adicionam volume.

### 1.4 Dimensoes-alvo

| Elemento | Dimensoes actuais | Dimensoes-alvo | Factor |
|---|---|---|---|
| Frame do naufrago | 16x24px | 64x96px | 4x |
| Spritesheet total (9x3 frames) | 144x72px | 576x288px | 4x (upscale) ou redesenho nativo |
| Tile da ilha | 16x16px | 64x64px | 4x |
| Palmeira principal | nao existe | 128x192px | novo |
| Arbusto tropical | nao existe | 32x48px | novo |
| Arvore morta | nao existe | 64x128px | novo |
| Palmeira inclinada | nao existe | 80x128px | novo |

A transicao de 16x24 para 64x96 pode ser feita por duas vias:
- **Upscale ESRGAN** (Fase 6, T-602 a T-610): melhora os sprites existentes sem redesenho.
  Resultado rapido mas limitado pelo chibi original.
- **Redesenho nativo** (Fase 7, T-701): desenho novo a 64x96 com as proporcoes correctas.
  E o objectivo desta fase.

A Fase 7 assume que o redesenho nativo e feito. O upscale e um passo intermedio de qualidade.

---

## 2. O Naufrago: Evolucao Visual ao Longo do Tempo Real

O sistema de aparencia do naufrago e determinado por tres variaveis lidas em tempo de execucao:

```gdscript
# Em save.json (user://save.json)
days_survived: int        # dias acumulados desde o primeiro arranque

# Calculado no arranque
current_season: String    # "verao" | "outono" | "inverno" | "primavera"
phase: int                # 1 a 5, derivado de days_survived
```

O selector de aparencia combina estas tres variaveis para escolher o sprite correcto:

```
aparencia = fase(days_survived) + variacao_sazonal(current_season)
```

### 2a. Crescimento de Cabelo e Barba: Cinco Fases Visuais

Cada fase corresponde a um spritesheet distinto (ou a uma camada separada no shader, ver secao 2c).
A mudanca de fase ocorre silenciosamente, sem anuncio.

#### Fase I: O Choque (Dias 1-7)

**Aparencia geral:** rosto limpo ou com sombra de barba maxima de 1-2 dias. Cabelo curto e
arrumado: ainda nao cresceu o suficiente para despenteado. Olhos ligeiramente abertos a mais,
postura com ombros encolhidos. Camisa rasgada mas ainda reconhecivel como camisa.

**Paleta de pele base:**

| Tom | Hex | Uso |
|---|---|---|
| Sombra profunda | `#3d1a08` | contorno e sombreado profundo |
| Sombra | `#7a3510` | sombra lateral e pescoco |
| Pele base | `#c8723a` | superficie principal |
| Luz | `#e8a060` | frente exposta ao sol |
| Realce | `#f0c090` | fronte e maos |

**Paleta de cabelo:**

| Tom | Hex | Uso |
|---|---|---|
| Castanho escuro | `#2d1a0a` | base do cabelo |
| Castanho medio | `#5c3418` | cor principal |
| Castanho quente | `#8a5828` | reflexo de luz |

**Animacoes afectadas:** todas as animacoes base. O idle tem movimento minimo, olhos que piscam
com frequencia normal, postura levemente curvada.

---

#### Fase II: A Rotina (Dias 8-30)

**Aparencia geral:** barbicha de uma semana visivel nos maxilares e no queixo (3 a 5 pixeis
de barba). Cabelo cresceu 4-6 pixeis, começa a cair para os lados. Expressao mais neutral,
menos panica. A camisa esta mais rasgada, pode estar a ser usada como lenco na cabeca em
alguns estados de idle.

**Diferenca de sprite vs Fase I:** adicionar layer de barba (4px de altura no queixo, 2px nos
maxilares). Cabelo ocupa mais pixeis na lateral da cabeca.

**Paleta de barba (mesma base do cabelo, tons ligeiramente mais escuros):**

| Tom | Hex | Uso |
|---|---|---|
| Pelo escuro | `#251408` | base da barba |
| Pelo medio | `#4a2a12` | corpo da barba |

**Animacoes afectadas:** idle inclui momento de cocar a barba (2 frames extra no loop).

---

#### Fase III: A Adaptacao (Dias 31-90)

**Aparencia geral:** barba media cobrindo o mento e maxilares ate metade do pescoco. Cabelo
despenteado, nao atado, cai pelos ombros. Expressao relaxada. A camisa virou fitas que o
naufrago usa como atadura nos pulsos ou simplesmente foi abandonada (torso nu bronzeado).
Calcoes brancos desgastados com manchas.

**Diferenca de sprite vs Fase II:** barba cobre mais area (6-8px de altura), cabelo e maior
e pode ter um ou dois pixeis a sair do contorno da cabeca para os lados. O torso nu exige
redraw da parte superior do corpo.

**Paleta de calcoes desgastados:**

| Tom | Hex | Uso |
|---|---|---|
| Branco sujo | `#d8ceb8` | superficie principal |
| Bege | `#b8a890` | sombra nos calcoes |
| Castanho claro | `#907860` | manchas e desgaste |

**Animacoes afectadas:** o sit e o look_up ganham postura mais relaxada. O fish ganha gesto
de lancar mais fluido.

---

#### Fase IV: O Filosofo (Dias 91-180)

**Aparencia geral:** barba longa descendo ate ao peito (10-14px). Cabelo comprido atado com
tira de pano numa rabo de cavalo. Expressao contemplativa, olhos semicerrados. Torso nu ou
com pano cruzado ao peito estilo bandoleira feita de trapos. Calcoes em farrapos.

**Diferenca de sprite vs Fase III:** a barba e agora um elemento visivel que afecta o contorno
da silhueta. O cabelo atado adiciona volume atras da cabeca. O look_up e o sit mostram postura
de meditacao.

**Paleta de trapos/bandoleira:**

| Tom | Hex | Uso |
|---|---|---|
| Bege escuro | `#8a7860` | pano desgastado |
| Castanho claro | `#6a5840` | sombra no pano |

**Animacoes afectadas:** o idle tem momentos mais longos de imobilidade. O startle e mais
lento (o filosofo nao se assusta facilmente). O wave e mais solenizado.

---

#### Fase V: O Lendario (Dias 180+)

**Aparencia geral:** barba e cabelo muito compridos, quase selvagens. O cabelo cai pelos
ombros e parte da barba toca a cintura. O naufrago parece ter fundido com a ilha. Usa
colares de conchas ou uma coroa de folhas de palmeira improvisada. A pele esta extremamente
bronzeada e curtida. Os olhos tem um brilho diferente.

**Diferenca de sprite vs Fase IV:** a barba e cabelo sao agora os maiores modificadores de
silhueta, adicionando 8-12px em varias direcoes. O contorno do personagem e mais irregular
e organico. Elementos decorativos (conchas, folhas) sao pixeis adicionais.

**Paleta de pele (Fase V, verao, pele maxima):**

| Tom | Hex | Uso |
|---|---|---|
| Sombra profunda | `#2a1005` | contorno |
| Sombra | `#5a2808` | sombra lateral |
| Pele muito bronzeada | `#a85820` | superficie |
| Luz | `#c87830` | zonas iluminadas |

**Animacoes afectadas:** o idle inclui momentos de contemplacao longa (8-12 frames extra).
O walk e mais pausado. O wave pode ser substituido por um gesto mais esoterico.

---

### 2b. Variacao Sazonal

A estacao e determinada pelo mes do relogio do sistema, calculado no arranque:

```gdscript
func get_current_season() -> String:
    var month = Time.get_date_dict_from_system()["month"]
    if month >= 6 and month <= 8:
        return "verao"
    elif month >= 9 and month <= 11:
        return "outono"
    elif month == 12 or month <= 2:
        return "inverno"
    else:
        return "primavera"
```

Nota: setembro esta incluido no verao (Jun-Set) conforme especificado. Ajustar os limites
conforme a decisao do Rodolfo.

#### Verao (Junho a Setembro)

**Modificacoes de aparencia:**
- Pele: aplicar multiplicador de bronzeado. A cor base da pele sobe 1 nivel de saturacao e
  desce 1 nivel de luminosidade. Hex de referencia para pele verao Fase I: `#b05a20` (base)
  vs `#c8723a` (padrao).
- Roupa: camisa mais rasgada, por vezes completamente ausente. Calcoes mais curtos (crop nos
  pixeis inferiores).
- Expressao: relaxada, meia sorrisa mais frequente no idle.
- Efeito visual adicional (opcional): gotas de suor no idle de alta temperatura.

**Paleta de pele verao:**

| Tom | Hex | Verao Hex | Diferenca |
|---|---|---|---|
| Sombra profunda | `#3d1a08` | `#2d1205` | mais escuro |
| Sombra | `#7a3510` | `#622a0c` | mais escuro |
| Pele base | `#c8723a` | `#a85820` | muito bronzeado |
| Luz | `#e8a060` | `#c87838` | mais saturado |
| Realce | `#f0c090` | `#d89050` | mais quente |

#### Outono (Outubro a Novembro)

**Modificacoes de aparencia:**
- Pele: tons medios, nem bronzeada nem palida. Usar a paleta base sem modificar.
- Expressao: ligeiramente melancolica, olhos com canto mais baixo.
- Efeito comico: probabilidade de 5% por frame de idle de aparecer uma folha seca pousada
  na cabeca do naufrago. A folha dura 2-4 segundos antes de cair.
- Roupa: comeca a aparecer pano enrolado nos ombros como capa improvisada.

**Folha de outono (sprite separado, 8x6px):**

| Tom | Hex | Uso |
|---|---|---|
| Laranja escuro | `#c85010` | base da folha |
| Laranja medio | `#e07830` | corpo |
| Amarelo | `#f0b040` | nervura central |

#### Inverno (Dezembro a Marco)

**Modificacoes de aparencia:**
- Pele: mais clara, ton palido-azulado. Aplicar tint frio sobre a paleta base.
- Barba (Fases II a V): pixeis brancos ou azuis claros intercalados na barba, simulando gelo
  ou neve.
- Postura: ombros mais encolhidos no idle. Os brazos cruzados sao a posicao preferencial
  quando o naufrago esta parado.
- Expressao: olhos mais cerrados (linha de olho 1px mais alta), nariz vermelho (1-2 pixeis
  cor `#c84030`).

**Paleta de pele inverno:**

| Tom | Hex | Inverno Hex | Diferenca |
|---|---|---|---|
| Sombra profunda | `#3d1a08` | `#2a2030` | tint frio |
| Sombra | `#7a3510` | `#605870` | dessaturado |
| Pele base | `#c8723a` | `#a09098` | muito palido |
| Luz | `#e8a060` | `#c8c0c8` | quase branco frio |

**Pixeis de gelo/neve na barba (Fases II a V):**

| Tom | Hex | Uso |
|---|---|---|
| Branco gelado | `#e8f0ff` | floco de neve/gelo |
| Azul claro | `#c0d0e8` | reflexo de gelo |

#### Primavera (Abril a Maio)

**Modificacoes de aparencia:**
- Pele: tons base, sem modificacao.
- Expressao: mais esperancosa, um pouco mais de frequencia de sorrisos no idle.
- Efeito decorativo: probabilidade de 3% por frame de idle de aparecer uma flor pequena
  (8x8px) perto do naufrago, pousada na areia ou atras da orelha (Fases III a V).
- Postura: mais erecta, ombros mais levantados.

**Flor de primavera (sprite separado, 8x8px):**

| Tom | Hex | Uso |
|---|---|---|
| Branco | `#f0f0f0` | petalas |
| Amarelo | `#f0d020` | centro da flor |
| Verde | `#408020` | caule |

---

### 2c. Implementacao Tecnica em Godot

Tres abordagens possiveis para implementar as variacoes sem explodir o numero de ficheiros.

#### Opcao A: Spritesheet Unico com Todas as Variacoes

**Conceito:** um unico PNG com todas as combinacoes de fase e estacao, organizado em grelha.
Com 5 fases e 4 estacoes, sao 20 linhas de sprites (cada linha tem as animacoes base).

**Pros:**
- Um unico ficheiro no Godot, uma unica referencia de textura.
- Sem custo de runtime para troca de material ou shader.
- Compativel com AnimatedSprite2D sem modificacoes.

**Contras:**
- Spritesheet muito grande. Estimativa para 9 animacoes x frames medios x 20 variantes:
  9 col x 12 frames x 64px = 6912px de largura, 20 linhas x 96px = 1920px de altura.
  Total: ~6912x1920px. Impraticavel para um unico ficheiro.
- Qualquer ajuste a uma variante exige reeditar o ficheiro monolito.
- Impossivel de gerar incrementalmente.

**Complexidade:** muito alta. Nao recomendado.

---

#### Opcao B: CanvasModulate por Estacao

**Conceito:** usar um no `CanvasModulate` na cena para aplicar um tint de cor global a toda
a cena, simulando a mudanca de estacao. Um tint azulado para inverno, amarelado para verao.

```gdscript
# Em island.gd, no _ready()
func apply_season_tint(season: String) -> void:
    var tint_map = {
        "verao":     Color(1.05, 0.95, 0.85),  # quente
        "outono":    Color(1.0,  0.95, 0.90),   # ligeiramente amarelado
        "inverno":   Color(0.85, 0.90, 1.05),   # frio
        "primavera": Color(1.0,  1.0,  1.0),    # neutro
    }
    $CanvasModulate.color = tint_map.get(season, Color.WHITE)
```

**Pros:**
- Implementacao em 10 linhas de GDScript.
- Zero ficheiros adicionais.
- Funciona imediatamente com os sprites actuais.

**Contras:**
- O tint afecta TUDO na cena: naufrago, ilha, interface, particulas. Nao e selectivo.
- Nao permite diferenca de pele bronzeada vs palida com precisao; e apenas uma cor global.
- Nao resolve o crescimento de barba e cabelo (exige spritesheets por fase de qualquer modo).
- Resultado visual generico, nao o estilo detalhado descrito neste documento.

**Complexidade:** muito baixa. Util como placeholder durante o desenvolvimento.

---

#### Opcao C: Shader de Cor por Estacao + Spritesheet por Fase (RECOMENDADO)

**Conceito:** cinco spritesheets (um por fase), cada um com todas as animacoes base. Um
shader de fragmento aplicado ao naufrago (via `ShaderMaterial` no `AnimatedSprite2D`) remapeia
cores especificas conforme a estacao activa. As cores da pele sao remapeadas para tons mais
quentes ou frios sem alterar o sprite base.

**Estrutura de ficheiros:**

```
game/character/
    naufrago_fase1.png    (64*9 x 96*N frames)
    naufrago_fase2.png
    naufrago_fase3.png
    naufrago_fase4.png
    naufrago_fase5.png
    naufrago.gdshader
```

**Shader de remapeamento de paleta (esquema base):**

```glsl
shader_type canvas_item;

// Cor de pele base que sera substituida
uniform vec4 skin_base : source_color = vec4(0.784, 0.447, 0.227, 1.0); // #c8723a
// Cor de substituicao (controlada por GDScript por estacao)
uniform vec4 skin_replace : source_color = vec4(0.784, 0.447, 0.227, 1.0);
// Tolerancia de correspondencia de cor
uniform float tolerance : hint_range(0.0, 0.5) = 0.08;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    if (col.a < 0.01) { COLOR = col; return; }
    float dist = distance(col.rgb, skin_base.rgb);
    if (dist < tolerance) {
        // Preservar luminosidade relativa, aplicar nova cor de pele
        float brightness = dot(col.rgb, vec3(0.299, 0.587, 0.114));
        float base_brightness = dot(skin_base.rgb, vec3(0.299, 0.587, 0.114));
        float ratio = brightness / max(base_brightness, 0.001);
        COLOR = vec4(skin_replace.rgb * ratio, col.a);
    } else {
        COLOR = col;
    }
}
```

**GDScript de controlo:**

```gdscript
# Em naufrago.gd
var season_skin_colors = {
    "verao":     Color("#a85820"),
    "outono":    Color("#c8723a"),  # base
    "inverno":   Color("#a09098"),
    "primavera": Color("#c8723a"),  # base
}

func update_appearance(phase: int, season: String) -> void:
    # Trocar spritesheet por fase
    var phase_textures = {
        1: preload("res://character/naufrago_fase1.png"),
        2: preload("res://character/naufrago_fase2.png"),
        3: preload("res://character/naufrago_fase3.png"),
        4: preload("res://character/naufrago_fase4.png"),
        5: preload("res://character/naufrago_fase5.png"),
    }
    $AnimatedSprite2D.sprite_frames = load_frames_from_texture(phase_textures[phase])
    # Aplicar cor de pele por estacao via shader
    var mat = $AnimatedSprite2D.material as ShaderMaterial
    mat.set_shader_parameter("skin_replace", season_skin_colors[season])
```

**Pros:**
- Cinco spritesheets geraveis independentemente (um por fase).
- A variacao sazonal e parametrica: nao exige sprites adicionais para cada estacao.
- Facil de ajustar: mudar a cor de pele do inverno e so alterar um hex no GDScript.
- Escalavel: adicionar uma nova variante de cor e adicionar uma entrada ao dicionario.
- Efeitos comicos (folha no outono, flor na primavera) sao sprites separados instanciados
  como nos filhos, nao afectam o spritesheet base.

**Contras:**
- O shader de remapeamento de paleta requer calibracao cuidadosa da tolerancia para evitar
  remapear pixeis que nao sao de pele (ex: areia na sombra dos pes).
- Elementos muito diferentes entre fases (barba longa, cabelo atado) nao podem ser resolvidos
  por shader: exigem sprites distintos, o que e precisamente o modelo de um spritesheet por fase.
- Cinco ficheiros em vez de um, mas cada um e editavel independentemente.

**Complexidade:** media. E a abordagem correcta para este projecto.

---

## 3. A Ilha: Redesenho Completo

### 3a. As Arvores

Quatro elementos vegetais distintos. Cada um tem nome, simbolismo, especificacoes de pixel art,
comportamento sazonal e posicao na ilha.

#### Arvore 1: A Palmeira Principal

| Atributo | Valor |
|---|---|
| Dimensoes | 128x192px (tronco + folhas + cocos) |
| Posicao na ilha | centro-esquerda, atras do ponto de paragem frequente do naufrago |
| Simbolismo | a companhia constante, o tempo que passa, o lugar que e casa |

**Descricao visual detalhada:**

Tronco: 10-14px de largura na base, afunilando para 8-10px no topo. Textura de anel de
palmeira: linhas horizontais curvadas em tons de castanho, com 3-4 tons alternados para
criar a ilusao de relevo. As linhas de textura sao espacadas 4-6px. Ligeiramente inclinado
para a direita (3-5 graus).

| Tom do tronco | Hex | Uso |
|---|---|---|
| Castanho escuro | `#3a2010` | aneis escuros, contorno |
| Castanho medio | `#6a4020` | superficie principal |
| Castanho claro | `#9a6835` | zonas de luz |
| Bege | `#c09060` | realce maximo |

Folhas: 6 a 8 folhas de palmeira em arco, cada folha com 40-60px de comprimento. Cada folha
e uma curva de pixeis com 4-6px de largura na base e 1-2px na ponta. Cor base `#2a6010`,
sombra `#184008`, luz `#5a9020`, realce `#80c030`. As folhas oscilam em loop de 4-6 frames
por accao do vento (animacao de idle da palmeira, separada do naufrago).

Cocos: 2-3 cocos visiveis no topo do tronco, abaixo das folhas. Cada coco e um ovalo de
10x12px. Castanho escuro `#3a2010` com um ponto de luz `#7a5030`.

Sombra na areia: elipse alongada projectada no chao, orientada conforme a hora do dia. A 
sombra e um sprite separado (elipse com 80x20px, cor `#a89060` com alpha 128) cujo angulo
de rotacao e posicao sao controlados pelo ciclo dia-noite.

**Variacao sazonal:**

| Estacao | Modificacao |
|---|---|
| Verao | Folhas mais saturadas (`#3a8010`), cocos mais visiveis (maior contraste) |
| Outono | 1-2 folhas com tom amarelado (`#a0a020`), animacao de folha a cair de 3 em 3 minutos |
| Inverno | Folhas com tint frio (`#2a5030`), nao cai neve (palmeira tropical) |
| Primavera | Folhas vivas, ponto de broto novo no topo da palmeira (2x4px, verde claro `#a0e040`) |

---

#### Arvore 2: O Arbusto Tropical

| Atributo | Valor |
|---|---|
| Dimensoes | 32x48px |
| Posicao na ilha | canto inferior-direito da ilha, perto da agua |
| Simbolismo | a vida persistente, o pequeno que sobrevive |

**Descricao visual detalhada:**

Arbusto denso e arredondado, sem tronco visivel. Massa de folhas ovais sobrepostas em tres
tons de verde: `#206010` (interior/sombra), `#408020` (corpo), `#60c030` (topo iluminado).
O contorno irregular e criado por pixeis alternados (nao uma curva suave). 4-6 flores
brancas de 4x4px distribuidas pela superficie, visiveis apenas na primavera.

**Variacao sazonal:**

| Estacao | Modificacao |
|---|---|
| Verao | Verde mais vivo, sem flores |
| Outono | 30% das folhas com tom castanho-amarelado (`#a08020`), animacao de queda de folhas |
| Inverno | Folhas reduzidas (ramo central mais visivel), tons mais cinzentos |
| Primavera | Flores brancas (`#f0f0f0`) e rosa claro (`#f0b0c0`) distribuidas, 6-8 flores |

---

#### Arvore 3: A Arvore Morta

| Atributo | Valor |
|---|---|
| Dimensoes | 64x128px |
| Posicao na ilha | canto superior-esquerdo, isolada, longe do naufrago |
| Simbolismo | o tempo que passa, a solidao, o que nao volta |

**Descricao visual detalhada:**

Tronco de madeira seca, cinzento-escuro, com fissuras visiveis. Largura na base: 12-16px,
afunilando para 6-8px no topo. Ramificacoes sem folhas: 3 galhos principais que bifurcam
em galhos mais finos, terminando em pontas de 1px. As ramificacoes superiores estendem-se
para ambos os lados, adicionando 20-30px de largura ao sprite no topo.

| Tom do tronco | Hex | Uso |
|---|---|---|
| Cinzento muito escuro | `#201810` | contorno e fissuras |
| Cinzento escuro | `#504030` | superficie sombria |
| Cinzento medio | `#806050` | superficie principal |
| Cinzento claro | `#a08070` | zonas de luz |

O corvo: sprite separado de 16x12px que tem probabilidade de pousar num dos galhos. Asas
fechadas, preto `#101010` com brilho azul `#181828` nos contornos. Permanece 10-30 segundos.
Pode aparecer em qualquer estacao.

**Variacao sazonal:**

| Estacao | Modificacao |
|---|---|
| Verao | Sem alteracao (arvore morta nao tem folhas) |
| Outono | Um galho tem 2-3 folhas secas artificialmente presas (vestigios do passado) |
| Inverno | Neve pousada nos galhos horizontais (linha branca `#e8f0ff` de 2px na parte superior de cada galho) |
| Primavera | Sem alteracao. O contraste com os outros elementos floridos e intencional |

---

#### Arvore 4: A Palmeira Inclinada

| Atributo | Valor |
|---|---|
| Dimensoes | 80x128px |
| Posicao na ilha | extremo direito da ilha, inclinada sobre o oceano (30-40 graus) |
| Simbolismo | o lugar de pensar, a fronteira entre a ilha e o mundo, o ponto de vista |

**Descricao visual detalhada:**

Palmeira mais pequena que a principal, com o tronco inclinado para a direita em 30-40 graus.
O tronco tem 8-10px de largura, textura identica a Palmeira Principal mas com escala reduzida.
4-5 folhas, ligeiramente menores (30-45px). 1-2 cocos. O naufrago pode sentar no tronco
inclinado: o ponto de sit desta arvore e uma posicao especifica no spritesheet de sit.

A inclinacao exige que o sprite seja desenhado em angulo e nao pode ser simplesmente o sprite
da Palmeira Principal rodado (a rotacao de sprites em pixel art nao funciona com nearest-neighbour).

**Variacao sazonal:** identica a Palmeira Principal.

---

### 3b. O Fundo da Ilha

#### Areia

O fundo da ilha e pintado como um unico sprite de background (nao tilemap). A areia tem um
gradiente manual desenhado pixel a pixel:

| Zona | Hex | Posicao |
|---|---|---|
| Centro claro | `#f0e0a0` | centro geometrico da ilha |
| Areia media | `#d8c880` | area geral |
| Areia sombria | `#b8a860` | bordas da ilha |
| Borda escura | `#907840` | transicao para a agua |

A textura de grao e criada com pixels isolados de ton ligeiramente diferente (variacao de
+-8 em cada canal RGB) distribuidos aleatoriamente em 5-8% da superficie. Este ruido e
gerado uma vez e gravado no sprite, nao computado em runtime.

#### Oceano

Duas opcoes tecnicas:

**Opcao dithering:** o oceano e um sprite pintado com padrao de dithering entre dois tons:
`#2060c0` (azul) e `#4050a0` (azul-roxo). O padrao de dithering cria a ilusao de terceiro
tom (`#3058b0`) sem pixeis adicionais. Para animacao de ondas, o padrao de dithering desloca-se
horizontalmente 1-2px por frame (4-6 frames em loop).

| Tom da agua | Hex | Posicao |
|---|---|---|
| Azul oceano | `#2060c0` | superficie principal |
| Azul-roxo | `#4050a0` | segundo tom do dithering |
| Azul claro | `#60a0e0` | espuma e cristas das ondas |
| Branco-azulado | `#c0e0f8` | linha de horizonte e espuma |

**Opcao shader:** shader de fragmento aplicado a um `ColorRect` ou `Sprite2D` que cobre
a area do oceano. O shader desloca UV em funcao do tempo para simular ondulacao.

```glsl
shader_type canvas_item;
uniform sampler2D wave_texture;
uniform float wave_speed = 0.3;
uniform float wave_amplitude = 0.005;

void fragment() {
    vec2 uv = UV;
    uv.x += sin(uv.y * 8.0 + TIME * wave_speed) * wave_amplitude;
    COLOR = texture(wave_texture, uv);
}
```

A textura de onda e um gradiente de azuis desenhado em pixel art (128x64px).

**Recomendado:** a opcao dithering e mais fiel ao estilo Johnny Castaway e mais simples
de manter. O shader e mais flexivel mas requer calibracao visual adicional.

#### Ceu

O ceu usa o `day_night_palette.json` existente (`game/data/day_night_palette.json`) para
interpolar entre gradientes conforme a hora do sistema. O fundo do ceu e um `GradientTexture1D`
aplicado verticalmente num `ColorRect`.

Nuvens ocasionais: sprites de 32x16px que derivam lentamente da esquerda para a direita.
Duas formas de nuvem desenhadas em pixel art, instanciadas aleatoriamente. Aparecem apenas
quando o ceu esta claro (nao a noite, nao durante chuva).

| Tom da nuvem | Hex | Uso |
|---|---|---|
| Branco | `#f8f8ff` | area principal |
| Cinzento claro | `#d0d0e0` | sombra inferior |
| Azul-cinzento | `#a0a8c0` | sombra mais profunda |

#### Sombras

A sombra da Palmeira Principal e a mais relevante. E um sprite de elipse (`sombra_palmeira.png`,
80x20px) com alpha de 140-160. A posicao e angulo de rotacao sao calculados em funcao da hora:

```gdscript
# Em island.gd
func update_palm_shadow(hour_float: float) -> void:
    # hour_float: 0.0 a 24.0
    # Manha: sombra longa para oeste. Tarde: sombra longa para leste. Meio-dia: curta.
    var angle = (hour_float - 12.0) * 15.0  # 15 graus por hora
    var length_factor = abs(hour_float - 12.0) / 6.0  # 0 ao meio-dia, 1 as 6h/18h
    $PalmShadow.rotation_degrees = angle
    $PalmShadow.scale.x = 1.0 + length_factor * 2.0
    $PalmShadow.modulate.a = 0.5 + (1.0 - length_factor) * 0.15  # mais opaca ao meio-dia
```

---

### 3c. Implementacao Tecnica do Background

#### Background pintado vs Tilemap vs Hibrido

| Abordagem | Descricao | Pros | Contras | Veredicto |
|---|---|---|---|---|
| Tilemap | Continuar com Tiny Islands CC0 (ou tileset proprio 64x64) | Familiar, facil de editar | Sem profundidade, sem gradiente, sem sombras, aspecto plano | Abandonar para o visual-alvo |
| Background pintado | Um PNG de fundo fixo (ex: 1280x800px) pintado como sprite unico | Controlo total do gradiente, profundidade, sombras | Sem flexibilidade de layout, ficheiro maior, nao tile-able | Correcto para a ilha |
| Hibrido (RECOMENDADO) | Background pintado para areia e oceano + arvores como sprites independentes | Fundo com qualidade pintada, arvores animaveis separadamente, sombras controlaveis por GDScript | Mais nodes na cena, coordenacao de camadas (z-index) | Abordagem correcta |

**Estrutura de nos da cena com abordagem hibrida:**

```
IslandScene (Node2D)
  Sky (ColorRect + GradientTexture1D)   -- z: -10, cobre todo o ecra
  Ocean (Sprite2D ou ColorRect + shader) -- z: -5
  IslandBackground (Sprite2D)            -- z: 0, fundo de areia pintado
  PalmShadow (Sprite2D)                  -- z: 1, sombra da palmeira
  DeadTree (AnimatedSprite2D)            -- z: 2
  Shrub (AnimatedSprite2D)               -- z: 3
  MainPalm (AnimatedSprite2D)            -- z: 4
  Naufrago (CharacterBody2D)             -- z: 5
  LeaningPalm (AnimatedSprite2D)         -- z: 6 (na frente do naufrago quando sentado)
  Clouds (Node2D)                        -- z: 7
  UI (CanvasLayer)                       -- z: 100
```

O z-index e critico para a sensacao de profundidade: a Palmeira Inclinada fica na frente
do naufrago quando ele esta sentado nela.

---

## 4. Spritesheet do Naufrago: Especificacoes Tecnicas

### 4.1 Dimensoes por Frame

| Opcao | Dimensoes | Resolucao visual | Tamanho do spritesheet completo (est.) | Recomendacao |
|---|---|---|---|---|
| Conservador | 48x72px | Boa, proporcoes correctas | ~1728x864px (10 anim x 6 frames med. x 3 fases) | Para prototipo rapido |
| Recomendado | 64x96px | Excelente, detalhe facial possivel | ~2304x1152px | Para versao final |

Usar 64x96px para o redesenho nativo. O upscale ESRGAN ja produz 64x96px (4x de 16x24), o que
confirma que este e o tamanho certo para continuar.

### 4.2 Animacoes Necessarias

| ID | Nome | Frames | Direccoes | FPS | Notas |
|---|---|---|---|---|---|
| `idle` | Repouso em pe | 4 a 8 | 1 (frontal) | 4 | Loop com variantes longas de contemplacao (Fases IV-V) |
| `walk_down` | Andar para baixo (frontal) | 6 | 1 | 8 | |
| `walk_up` | Andar para cima (costas) | 6 | 1 | 8 | |
| `walk_left` | Andar para a esquerda | 6 | 1 | 8 | |
| `walk_right` | Andar para a direita | 6 | 1 | 8 | Pode ser flip de walk_left se simetrico |
| `fish` | Pescar | 8 a 10 | 1 (lateral) | 6 | Inclui lancamento e espera |
| `sleep` | Dormir | 4 | 1 (deitado) | 2 | Respiracao visivel (torso que sobe/desce) |
| `wave` | Acenar | 6 | 1 (frontal) | 8 | |
| `startle` | Assustar-se | 4 | 1 (frontal) | 12 | Rapido: salto e pouso |
| `look_up` | Olhar para o ceu | 4 | 1 (frontal) | 4 | Cabeca inclinada para cima |
| `eat` | Comer | 6 | 1 (frontal) | 6 | Mao a levar objecto a boca |
| `sit` | Sentar | 6 | 1 (lateral) | 4 | Inclui transicao sentar/levantar (2 frames) |

Total estimado: 74 a 88 frames por spritesheet de fase.

### 4.3 Organizacao do Spritesheet

A grelha e organizada por linha de animacao. Cada linha tem o numero maximo de frames da
animacao mais longa (10 frames). Frames em branco (transparentes) completam as linhas curtas.

```
Linha  0: idle           (8 frames x 64px = 512px de largura)
Linha  1: walk_down      (6 frames)
Linha  2: walk_up        (6 frames)
Linha  3: walk_left      (6 frames)
Linha  4: walk_right     (6 frames)
Linha  5: fish           (10 frames)
Linha  6: sleep          (4 frames)
Linha  7: wave           (6 frames)
Linha  8: startle        (4 frames)
Linha  9: look_up        (4 frames)
Linha 10: eat            (6 frames)
Linha 11: sit            (6 frames)
```

Dimensoes totais do spritesheet:
- Largura: 10 frames x 64px = 640px
- Altura: 12 animacoes x 96px = 1152px
- Total: 640x1152px por spritesheet de fase
- Cinco fases: cinco ficheiros de 640x1152px

### 4.4 Formato de Ficheiro

| Parametro | Valor |
|---|---|
| Formato | PNG com transparencia |
| Modo de cor | RGBA (32-bit) |
| Compressao | sem perdas (lossless) |
| Background | transparente (alpha 0) |
| Convencao de nome | `naufrago_faseN.png` (N = 1 a 5) |
| Caminho no repositorio | `game/character/` |

### 4.5 Integracao com AnimatedSprite2D Sem Partir o Codigo

O codigo actual referencia animacoes por nome (`"walk"`, `"fish"`, etc.) atraves do
`SpriteFrames` resource. Para integrar novos spritesheets sem alterar o codigo de jogo:

**Passo 1:** criar o `SpriteFrames` resource para a fase 1 com os nomes de animacao identicos
aos actuais. Guardar em `game/character/naufrago_fase1.tres`.

**Passo 2:** no no do naufrago, trocar o `SpriteFrames` carregado conforme a fase:

```gdscript
# Em naufrago.gd
var phase_frames = {
    1: preload("res://character/naufrago_fase1.tres"),
    2: preload("res://character/naufrago_fase2.tres"),
    3: preload("res://character/naufrago_fase3.tres"),
    4: preload("res://character/naufrago_fase4.tres"),
    5: preload("res://character/naufrago_fase5.tres"),
}

func set_phase(phase: int) -> void:
    var current_anim = $AnimatedSprite2D.animation
    var current_frame = $AnimatedSprite2D.frame
    $AnimatedSprite2D.sprite_frames = phase_frames[phase]
    $AnimatedSprite2D.play(current_anim)
    $AnimatedSprite2D.frame = min(current_frame, $AnimatedSprite2D.sprite_frames.get_frame_count(current_anim) - 1)
```

**Passo 3:** verificar que todos os nomes de animacao no novo `SpriteFrames` sao identicos
aos do original. O `backlog.py check` nao valida isto: usar um teste GUT dedicado.

**Passo 4:** o filtro de importacao deve ser `texture/filter: 0` (nearest-neighbour) em
cada `.import`. Verificar apos substituicao:

```bash
grep "texture/filter" game/character/naufrago_fase1.png.import
# Esperado: texture/filter=0
```

---

## 5. Pipeline de Criacao com ComfyUI

ComfyUI local: `http://127.0.0.1:8188`. Verificar disponibilidade com `bash scripts/comfyui_health.sh`
antes de iniciar qualquer geracao.

### 5.1 Prompt Base para o Naufrago por Fase

Todos os prompts assumem SD1.5 com LoRA `pixelart-sd15.safetensors` activado (peso 0.8 a 1.0).

**Prompt positivo base (invariante):**

```
pixel art, 64x96 pixels, transparent background, castaway character sprite,
2D side-scrolling game asset, retro style, clean pixel edges, no anti-aliasing,
limited color palette, front-facing, full body, indie game sprite, isolated character
```

**Modificacoes por fase:**

| Fase | Adicionar ao prompt |
|---|---|
| I | `clean-shaven, short hair, disoriented expression, torn shirt, white shorts, tanned skin` |
| II | `week-old beard stubble, slightly longer hair, neutral expression, more torn shirt, tanned skin` |
| III | `medium beard, messy hair, bare chest, adapted expression, very worn shorts, dark tan` |
| IV | `long beard reaching chest, long hair tied back, philosophical expression, cloth bandolier, rags, dark brown tan` |
| V | `very long wild beard, very long unkempt hair, shell necklace, palm leaf crown, mystical expression, extremely dark tan` |

**Prompt negativo (obrigatorio):**

```
blurry, smooth, 3d render, photorealistic, watermark, text, multiple characters,
gradient, high resolution, chibi, anime style, background, shadow, noise,
jpeg artifacts, antialiasing, modern clothes, shoes
```

**Parametros de geracao:**

| Parametro | Valor |
|---|---|
| Checkpoint | `v1-5-pruned-emaonly.safetensors` |
| LoRA | `pixelart-sd15.safetensors`, peso 0.85 |
| Resolucao de geracao | 512x768px (ratio aproximado a 64x96) |
| Steps | 25 a 35 |
| CFG scale | 7 a 9 |
| Sampler | DPM++ 2M Karras |
| Seed | fixar durante uma sessao para consistencia |

Apos geracao: redimensionar para 64x96 com nearest-neighbour, depois separar em frames manualmente.

### 5.2 Prompt Base para Cada Arvore

**Prompt positivo base para arvores:**

```
pixel art, transparent background, single tree sprite, 2D game asset, retro style,
clean pixel edges, no anti-aliasing, limited color palette, tropical island, indie game
```

| Arvore | Adicionar ao prompt | Dimensoes alvo |
|---|---|---|
| Palmeira Principal | `tall palm tree, visible coconuts, detailed trunk texture, large fronds, tropical`, 128px high | 128x192px |
| Arbusto Tropical | `small tropical bush, dense round foliage, white flowers`, 32px high | 32x48px |
| Arvore Morta | `dead dry tree, bare branches, no leaves, grey cracked bark, single crow perch`, 64px high | 64x128px |
| Palmeira Inclinada | `leaning palm tree, tilted 35 degrees, over water, coconuts, tropical fronds`, 80px high | 80x128px |

**Prompt negativo (identico ao do naufrago, adicionar):**

```
realistic, detailed, multiple trees, forest, photorealistic
```

### 5.3 Consistencia de Paleta entre Geracao e Correccoes Manuais

Regra: todos os sprites gerados por IA sao quantizados para a paleta-mestre antes de entrar
no repositorio. A paleta-mestre e definida a partir do sprite do naufrago Fase I aprovado.

**Extrair paleta do sprite aprovado:**

```bash
python3 -c "
from PIL import Image
img = Image.open('game/character/naufrago_fase1.png').convert('RGBA')
pixels = set(img.getdata())
palette = sorted([p for p in pixels if p[3] > 0], key=lambda x: (x[0]+x[1]+x[2]))
for c in palette:
    print('#%02x%02x%02x' % (c[0], c[1], c[2]))
" > docs/paleta-mestre.txt
```

**Quantizar um sprite gerado:**

```bash
python3 scripts/quantize_palette.py \
  --reference game/character/naufrago_fase1.png \
  --input output/arvore_gerada.png \
  --output game/world/palmeira_principal.png
```

A paleta pode ser expandida por decisao do Rodolfo. Cada cor nova fora da paleta deve ser
registada em `docs/paleta-mestre.txt` com justificacao.

### 5.4 Workflow Sugerido de Criacao

```
1. GERAR    -- ComfyUI: prompt + parametros -> 4 a 8 variantes do sprite
2. REVER    -- Inspeccao visual pelo Rodolfo ou pelo agente: escolher a melhor variante
3. AJUSTAR  -- Aseprite/LibreSprite: correccoes manuais de pixels incorrectos, alinhamento
               de grid, limpeza de contornos, adicao de pixels em falta
4. QUANTIZAR -- scripts/quantize_palette.py: reduzir a paleta-mestre
5. VERIFICAR -- python3 scripts/check_alpha.py: transparencia preservada
6. REGISTAR -- docs/assets-licencas.md: entrada "gerado por IA propria (ComfyUI SD1.5)"
7. APROVAR  -- Rodolfo confirma. Estado da tarefa: feito
8. COMMITAR -- git add + git commit com mensagem visual(T-NNN)
```

### 5.5 Ferramentas de Pixel Art Manual para Refinamento

| Ferramenta | Uso | Instalar |
|---|---|---|
| Aseprite | Editor de pixel art profissional, suporte nativo a spritesheets e animacoes, paletas, dithering manual | `sudo pacman -S aseprite` ou compilar da fonte |
| LibreSprite | Fork open-source do Aseprite (mais antigo), gratuito sem compilacao | `sudo pacman -S libresprite` (AUR) |
| GIMP | Correccoes pontuais, manipulacao de canais alpha, redimensionamento nearest-neighbour | `sudo pacman -S gimp` |

**Configuracao obrigatoria no Aseprite/LibreSprite para pixel art:**
- Modo de cor: Indexed (paleta) ou RGB
- Zoom de trabalho: minimo 8x, preferivel 16x
- Grid: ligar a grelha de 64x96px (frame size)
- Antialiasing: desligado em todas as ferramentas de desenho
- Interpolacao de escala: nearest-neighbour

---

## 6. Roadmap de Implementacao

A tabela abaixo ordena as tarefas por impacto visual imediato e dependencias.

| Ordem | Tarefa | Impacto Visual | Depende de | Paralelizavel com |
|---|---|---|---|---|
| 1 | T-701: Redesenho naufrago Fase I | Alto: base de tudo | nada | nada |
| 2 | T-707: Background da ilha (areia + gradiente) | Alto: substitui fundo plano | nada | T-701 |
| 3 | T-704: Palmeira Principal | Alto: primeiro elemento novo visivel | nada | T-701, T-707 |
| 4 | T-708: Oceano animado | Medio: fundo mais vivo | T-707 | T-705, T-706 |
| 5 | T-705: Arbusto Tropical e Arvore Morta | Medio: diversidade visual | T-704 (paleta) | T-708 |
| 6 | T-706: Palmeira Inclinada | Medio: lugar do naufrago | T-704 (estilo) | T-708 |
| 7 | T-702: Variantes sazonais do naufrago | Alto: dinamismo | T-701 | T-709 |
| 8 | T-709: Sistema de sombras dinamicas | Medio: profundidade | T-704, T-707 | T-702, T-703 |
| 9 | T-703: Sistema de fases visuais | Alto: evolucao ao longo do tempo | T-701, T-702 | nada |
| 10 | T-710: Revisao visual completa | Validacao | todas anteriores | nada |

### Estimativa de Sprites por Elemento

| Elemento | Sprites a criar | Animacoes | Frames totais (est.) |
|---|---|---|---|
| Naufrago Fase I | 1 spritesheet | 12 animacoes | 74 a 88 frames |
| Naufrago Fases II a V | 4 spritesheets | 12 animacoes | 296 a 352 frames |
| Palmeira Principal | 1 sprite base + animacao vento | 1 animacao (4-6 frames) | 6 frames |
| Arbusto Tropical | 1 sprite base + variantes sazonais | 2 animacoes (queda folha, flor) | 8 frames |
| Arvore Morta | 1 sprite base | estatico + corvo (6 frames) | 7 frames |
| Palmeira Inclinada | 1 sprite base + animacao vento | 1 animacao (4 frames) | 4 frames |
| Background ilha | 1 PNG pintado | estatico | 1 frame |
| Oceano (dithering) | 1 sprite animado | 1 animacao (4-6 frames) | 6 frames |
| Sombra palmeira | 1 sprite base | estatico (rotacao por GDScript) | 1 frame |
| Folha outono | 1 sprite | queda (4 frames) | 4 frames |
| Flor primavera | 1 sprite | estatico | 1 frame |
| Corvo | 1 sprite | pousado/asas (6 frames) | 6 frames |

Total estimado: 415 a 488 frames novos a criar para a Fase 7 completa.

---

## 7. Tarefas Novas para o Backlog (Fase 7)

Ficheiros a criar em `backlog/fase-7/`. Formato identico ao das fases anteriores.
As seccoes com acentos sao obrigatorias para o `backlog.py check` nao falhar.

### Tabela Resumo

| ID | Titulo | Fase | Tipo | Depende de | Criterio de saida resumido |
|---|---|---|---|---|---|
| T-701 | Redesenho do naufrago Fase I (base limpa) | 7 | visual | nenhum | spritesheet 640x1152px RGBA, 12 anim, aprovacao do Rodolfo |
| T-702 | Variantes sazonais do naufrago (shader + spritesheet) | 7 | visual | T-701 | shader calibrado, 4 estacoes visivelmente distintas em screenshot |
| T-703 | Sistema de fases visuais do naufrago (selector por days_survived) | 7 | codigo | T-701, T-702 | GDScript com selector, teste GUT, fases I a V distinguiveis |
| T-704 | A Palmeira Principal | 7 | visual | nenhum | PNG 128x192px, sombra separada, animacao de vento 4-6 frames |
| T-705 | O Arbusto Tropical e a Arvore Morta | 7 | visual | T-704 (paleta) | 2 sprites, variantes sazonais, corvo funcional na Arvore Morta |
| T-706 | A Palmeira Inclinada | 7 | visual | T-704 (estilo) | PNG 80x128px, ponto de sit integrado no codigo do naufrago |
| T-707 | Background da ilha (areia + gradiente) | 7 | visual | nenhum | PNG pintado de fundo, z-index correcto, aprovacao do Rodolfo |
| T-708 | Oceano animado | 7 | visual | T-707 | animacao de ondas (dithering ou shader), horizonte distinto |
| T-709 | Sistema de sombras dinamicas | 7 | codigo | T-704, T-707 | sombra da palmeira move com a hora, verify.sh sem FALHOU |
| T-710 | Revisao visual completa Fase 7 | 7 | docs | T-701 a T-709 | verify.sh --full sem FALHOU, screenshot de aprovacao, CHANGELOG 0.7.0 |

### Templates das Tarefas

#### T-701: Redesenho do Naufrago Fase I

```markdown
---
id: T-701
titulo: Redesenho do naufrago Fase I (base limpa)
fase: 7
estado: pronto
tipo: visual
depende_de: []
---

## Objectivo
Criar o spritesheet nativo a 64x96px do naufrago em Fase I (O Choque, Dias 1-7),
com 12 animacoes, proporcoes realistas-caricatas conforme docs/visual-identity.md.
Este spritesheet e a base para todas as outras fases e variantes.

## Ler antes
- docs/visual-identity.md secoes 2a, 4
- docs/grafico-polimento.md secao 3.1 e 3.2

## Critérios de aceitação
- [ ] Ficheiro `game/character/naufrago_fase1.png` com dimensoes 640x1152px, modo RGBA
- [ ] 12 animacoes presentes: idle, walk_down, walk_up, walk_left, walk_right, fish, sleep, wave, startle, look_up, eat, sit
- [ ] Paleta de pele conforme docs/visual-identity.md secao 2a Fase I
- [ ] Contorno escuro (`#1a0a00` ou similar) consistente em todos os frames
- [ ] Ratio cabeca/corpo entre 1:2 e 1:2.5
- [ ] `game/character/naufrago_fase1.tres` (SpriteFrames resource) com nomes de animacao identicos aos actuais
- [ ] Filtro nearest-neighbour no `.import`
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] `docs/assets-licencas.md` actualizado: "gerado por IA propria (ComfyUI SD1.5) + refinamento manual"
- [ ] Aprovacao visual do Rodolfo (estado humano ate confirmacao)

## Fora de âmbito
- Fases II a V (sao T-703)
- Variantes sazonais (sao T-702)
- Animacoes especificas de eventos lendarios

## Prova exigida
- `docs/proof/T-701-naufrago-fase1.png`: screenshot com naufrago Fase I em jogo
- Comparacao lado a lado com sprite original 16x24px

## Relatorio
```

---

#### T-702: Variantes Sazonais do Naufrago

```markdown
---
id: T-702
titulo: Variantes sazonais do naufrago (shader + spritesheet)
fase: 7
estado: pronto
tipo: visual
depende_de: [T-701]
---

## Objectivo
Implementar o sistema de variacao sazonal do naufrago conforme docs/visual-identity.md
secao 2b e 2c (Opcao C recomendada): shader de remapeamento de cor por estacao + sprites
separados para efeitos comicos (folha de outono, flor de primavera).

## Ler antes
- docs/visual-identity.md secoes 2b, 2c
- docs/grafico-polimento.md

## Critérios de aceitação
- [ ] `game/character/naufrago.gdshader` implementado com remapeamento de pele
- [ ] `ShaderMaterial` aplicado ao AnimatedSprite2D do naufrago
- [ ] Quatro cores de pele sazonais definidas no GDScript (ver tabelas na secao 2b)
- [ ] `get_current_season()` implementado e testado com GUT para os 12 meses
- [ ] Sprite de folha de outono (`game/character/fx_leaf.png`, 8x6px) com animacao de queda
- [ ] Sprite de flor de primavera (`game/character/fx_flower.png`, 8x8px)
- [ ] Screenshots das quatro estacoes em `docs/proof/T-702-estacoes.png`
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Variacao sazonal das arvores (e parte de T-704 e T-705)
- Roupas diferentes por estacao (resolvido por sprite de fase, nao por shader)

## Prova exigida
- Quatro screenshots lado a lado mostrando o naufrago nas quatro estacoes

## Relatorio
```

---

#### T-703: Sistema de Fases Visuais do Naufrago

```markdown
---
id: T-703
titulo: Sistema de fases visuais do naufrago (selector por days_survived)
fase: 7
estado: pronto
tipo: codigo
depende_de: [T-701, T-702]
---

## Objectivo
Implementar o selector de fase visual em GDScript que le `days_survived` do save.json
e carrega o SpriteFrames correspondente. A transicao de fase e silenciosa (sem anuncio).

## Ler antes
- docs/visual-identity.md secao 2, 4.5
- docs/narrative-design.md secao 1 (tabela de fases)

## Critérios de aceitação
- [ ] `get_visual_phase(days_survived: int) -> int` implementado e testado
- [ ] Limiares: Fase I dias 1-7, II 8-30, III 31-90, IV 91-180, V 181+
- [ ] `set_phase(phase: int)` carrega o SpriteFrames correcto sem interromper a animacao actual
- [ ] A animacao em curso continua no mesmo frame apos troca de fase (nao reinicia)
- [ ] Teste GUT: simular days_survived 1, 8, 31, 91, 181 e verificar fase resultante
- [ ] Teste GUT: verificar que os nomes de animacao sao identicos em todos os SpriteFrames
- [ ] `bash scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Animacao de transicao entre fases (nao existe: a mudanca e silenciosa)
- Fase visual diferente da fase narrativa (sao sinonimas)

## Prova exigida
- Output de `pytest` ou GUT com todos os testes a PASSAR

## Relatorio
```

---

#### T-704: A Palmeira Principal

```markdown
---
id: T-704
titulo: A Palmeira Principal
fase: 7
estado: pronto
tipo: visual
depende_de: []
---

## Objectivo
Criar o sprite da Palmeira Principal conforme docs/visual-identity.md secao 3a Arvore 1,
e integra-lo na cena da ilha com animacao de vento e sombra dinamica (placeholder de sombra;
sombra completa e T-709).

## Ler antes
- docs/visual-identity.md secoes 3a, 3c

## Critérios de aceitação
- [ ] `game/world/palmeira_principal.png`: PNG 128x192px, RGBA, animacao de vento (4-6 frames)
- [ ] `game/world/palmeira_principal_sombra.png`: elipse 80x20px, alpha 140-160
- [ ] Nos na cena: MainPalm (AnimatedSprite2D) com z=4, PalmShadow (Sprite2D) com z=1
- [ ] Paleta conforme tabela de tronco da secao 3a
- [ ] Variantes sazonais do sprite implementadas (ver tabela secao 3a)
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Sombra dinamica por hora (e T-709)
- Cocos interactivos

## Prova exigida
- `docs/proof/T-704-palmeira.png`: screenshot com palmeira em jogo

## Relatorio
```

---

#### T-705: O Arbusto Tropical e a Arvore Morta

```markdown
---
id: T-705
titulo: O Arbusto Tropical e a Arvore Morta
fase: 7
estado: pronto
tipo: visual
depende_de: [T-704]
---

## Objectivo
Criar os sprites do Arbusto Tropical e da Arvore Morta conforme docs/visual-identity.md
secao 3a Arvores 2 e 3, incluindo variantes sazonais e o sprite do corvo visitante.

## Ler antes
- docs/visual-identity.md secao 3a arvores 2 e 3
- docs/events-catalogue.md (verificar se ha eventos que referenciam o corvo)

## Critérios de aceitação
- [ ] `game/world/arbusto_tropical.png`: 32x48px, RGBA, variantes sazonais
- [ ] `game/world/arvore_morta.png`: 64x128px, RGBA, neve de inverno
- [ ] `game/world/corvo.png`: 16x12px, RGBA, animacao de 6 frames (pousado)
- [ ] Nos na cena com z-index correcto (ver secao 3c)
- [ ] Animacao de queda de folha no outono para o Arbusto Tropical
- [ ] Flores de primavera no Arbusto Tropical (probabilistica por timer)
- [ ] Logica do corvo: aparece no galho da Arvore Morta com intervalo aleatorio de 5-15 min, dura 10-30s
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Interaccao do naufrago com o corvo (pode ser evento futuro)

## Prova exigida
- `docs/proof/T-705-arvores.png`: screenshot com ambas as arvores e corvo

## Relatorio
```

---

#### T-706: A Palmeira Inclinada

```markdown
---
id: T-706
titulo: A Palmeira Inclinada
fase: 7
estado: pronto
tipo: visual
depende_de: [T-704]
---

## Objectivo
Criar o sprite da Palmeira Inclinada (lugar favorito do naufrago) e integrar o ponto de
sit correspondente no comportamento de sentar do naufrago.

## Ler antes
- docs/visual-identity.md secao 3a Arvore 4
- agent_docs/tech_design.md (comportamento sit)

## Critérios de aceitação
- [ ] `game/world/palmeira_inclinada.png`: 80x128px, RGBA, inclinada 30-40 graus, animacao de vento (4 frames)
- [ ] No na cena: LeaningPalm com z=6 (na frente do naufrago)
- [ ] Ponto de sit definido em GDScript: quando o naufrago executa `sit` nesta posicao, usa a palmeira como suporte
- [ ] Variantes sazonais identicas a Palmeira Principal
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Interaccao de pesca a partir da palmeira inclinada (evento futuro)

## Prova exigida
- `docs/proof/T-706-inclinada.png`: screenshot com naufrago sentado na palmeira inclinada

## Relatorio
```

---

#### T-707: Background da Ilha (Areia e Gradiente)

```markdown
---
id: T-707
titulo: Background da ilha (areia e gradiente)
fase: 7
estado: pronto
tipo: visual
depende_de: []
---

## Objectivo
Substituir o tilemap plano actual por um background pintado com gradiente de areia
(centro claro, bordas escuras) e transicao suave para o oceano, conforme secao 3b.

## Ler antes
- docs/visual-identity.md secoes 3b, 3c
- docs/grafico-polimento.md secao 2.4 (substituicao de assets no Godot)

## Critérios de aceitação
- [ ] `game/world/island_background.png`: dimensoes do ecra de referencia, RGBA, gradiente de areia pintado
- [ ] Textura de grao implementada (ruido de +-8 RGB em 5-8% dos pixeis)
- [ ] Nos da cena reorganizados conforme hierarquia da secao 3c
- [ ] TileMap original removido da cena (ou desactivado com nota)
- [ ] Paleta de areia conforme tabela da secao 3b
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Oceano (e T-708)
- Sombras (e T-709)

## Prova exigida
- `docs/proof/T-707-background.png`: screenshot com fundo novo

## Relatorio
```

---

#### T-708: Oceano Animado

```markdown
---
id: T-708
titulo: Oceano animado
fase: 7
estado: pronto
tipo: visual
depende_de: [T-707]
---

## Objectivo
Implementar o oceano animado com dithering ou shader conforme docs/visual-identity.md
secao 3b, com horizonte distinto e animacao de ondas visivel.

## Ler antes
- docs/visual-identity.md secao 3b (Oceano)

## Critérios de aceitação
- [ ] Oceano visivel com animacao de ondas (dithering ou shader, a decisao e do agente com aprovacao do Rodolfo)
- [ ] Horizonte distinto com linha de separacao agua/ceu
- [ ] Paleta de agua conforme tabela da secao 3b
- [ ] Animacao em loop sem saltos visiveis
- [ ] FPS cap de 30 respeitado (nao adicionar carga em idle desnecessaria)
- [ ] `bash scripts/verify.sh` sem FALHOU
- [ ] Aprovacao visual do Rodolfo

## Fora de âmbito
- Ondas de grande escala ou tempestade (evento de clima, Fase 3)
- Reflexo da lua no oceano (evento nocturno futuro)

## Prova exigida
- `docs/proof/T-708-oceano.png`: screenshot com oceano animado

## Relatorio
```

---

#### T-709: Sistema de Sombras Dinamicas

```markdown
---
id: T-709
titulo: Sistema de sombras dinamicas
fase: 7
estado: pronto
tipo: codigo
depende_de: [T-704, T-707]
---

## Objectivo
Implementar o calculo de posicao e rotacao da sombra da Palmeira Principal em funcao
da hora do sistema, conforme docs/visual-identity.md secao 3b (Sombras).

## Ler antes
- docs/visual-identity.md secao 3b (Sombras)
- game/data/day_night_palette.json (para reutilizar a logica de hora)

## Critérios de aceitação
- [ ] `update_palm_shadow(hour_float: float)` implementado conforme pseudocodigo da secao 3b
- [ ] Sombra visivel de manha (longa, para oeste), ao meio-dia (curta), a tarde (longa, para leste)
- [ ] Sombra invisivel ou muito ténue a noite (alpha < 30)
- [ ] Teste GUT: verificar angulo e scale para hora 6.0, 12.0, 18.0
- [ ] `bash scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sombras das outras arvores (complexidade nao justificada para esta fase)
- Sombra do naufrago

## Prova exigida
- `docs/proof/T-709-sombra-manha.png` e `docs/proof/T-709-sombra-tarde.png`

## Relatorio
```

---

#### T-710: Revisao Visual Completa Fase 7

```markdown
---
id: T-710
titulo: Revisao visual completa Fase 7
fase: 7
estado: pronto
tipo: docs
depende_de: [T-701, T-702, T-703, T-704, T-705, T-706, T-707, T-708, T-709]
---

## Objectivo
Validar que todos os elementos visuais da Fase 7 funcionam em conjunto, que o verify.sh
passa sem falhas, e actualizar o CHANGELOG e o roadmap.

## Ler antes
- docs/visual-identity.md (este documento)
- docs/roadmap.md

## Critérios de aceitação
- [ ] `bash scripts/verify.sh --full` sem FALHOU
- [ ] Screenshot completo da ilha em dia, ao meio-dia e a noite em `docs/proof/T-710-revisao.png`
- [ ] O naufrago e visivelmente diferente entre Fase I e Fase V (screenshots comparativos)
- [ ] As quatro estacoes sao visivelmente distintas (screenshots comparativos)
- [ ] `CHANGELOG.md` actualizado com versao 0.7.0 e lista de mudancas visuais
- [ ] `docs/roadmap.md` actualizado: Fase 7 marcada como completa
- [ ] `docs/assets-licencas.md` sem entradas "por confirmar" de assets da Fase 7
- [ ] Aprovacao do Rodolfo

## Fora de âmbito
- Novos elementos visuais alem dos definidos em T-701 a T-709
- Performance profiling (tarefa separada se necessaria)

## Prova exigida
- `docs/proof/T-710-revisao.png`: screenshot panoramico da ilha completa
- Comparativo de fases e estacoes em `docs/proof/T-710-comparativo.png`

## Relatorio
```

---

## 8. Catalogo Completo de Sprites a Criar

Inventario exhaustivo de todos os sprites necessarios para o Insulano, derivado da analise
do Johnny Castaway e das decisoes de produto. Ordenado por categoria. A coluna Fase indica
em que fase do backlog o sprite entra (6 = Polimento actual, 7 = Redesenho visual, 8+ = futuro).

### 8.1 Personagem Principal: O Naufrago

| ID | Animacao | Frames est. | Direccoes | Prioridade | Fase | Notas |
|---|---|---|---|---|---|---|
| `idle` | Repouso em pe, respiracao visivel | 4-8 | 1 (frontal) | Alta | 7 (T-701) | Variante longa para Fases IV-V |
| `idle_boring` | Parado com ar de tolo, olhar sem destino | 6 | 1 (frontal) | Media | 7 | Trigger: TEDIO alto; inspirado em `sttoll.bmp` |
| `idle_contemplate` | Poses contemplativas solitarias, olhar ao longe | 8 | 1 (frontal) | Media | 7 | Fases III a V; inspirado em `gjwsol.bmp` |
| `walk_down` | Caminhada para baixo (frontal) | 8 | 1 | Alta | 7 (T-701) | Conforme `gjwalk.bmp`: 8 frames por direccao |
| `walk_up` | Caminhada para cima (costas) | 8 | 1 | Alta | 7 (T-701) | |
| `walk_left` | Caminhada para a esquerda | 8 | 1 | Alta | 7 (T-701) | |
| `walk_right` | Caminhada para a direita | 8 | 1 | Alta | 7 (T-701) | Pode ser flip de walk_left se simetrico |
| `fish` | Pescar com cana, lancamento e espera | 10 | 1 (lateral) | Alta | 7 (T-701) | Animacao completa com cana separada |
| `fish_special` | Tecnica especial de pesca com bastao | 8 | 1 (lateral) | Baixa | 8 | Evento raro; inspirado em `sjrftik.bmp` |
| `sleep` | Deitado a dormir, respiracao, ronco | 6 | 1 (deitado) | Alta | 7 (T-701) | Zzz como sprite separado; inspirado em `sleep.bmp` |
| `sunbathe` | Deitado a apanhar sol, poses relaxadas | 4 | 1 (deitado) | Media | 7 | Verao; inspirado em `gjhot.bmp` |
| `wave` | Acenar para o horizonte | 6 | 1 (frontal) | Alta | 7 (T-701) | |
| `startle` | Susto com salto e pouso | 4 | 1 (frontal) | Alta | 7 (T-701) | Rapido (12 fps) |
| `startle_fall` | Susto com queda dramatica | 6 | 1 (frontal) | Media | 7 | Variante exagerada; inspirado em `sjrjop.bmp` |
| `look_up` | Olhar para o ceu, ver navios | 4 | 1 (frontal) | Alta | 7 (T-701) | Cabeca inclinada; inspirado em `mjtele.bmp` |
| `look_horizon` | Olhar para o horizonte com mao na testa | 4 | 1 (lateral) | Media | 7 | Variante de look_up |
| `eat` | Comer peixe | 6 | 1 (frontal) | Alta | 7 (T-701) | |
| `sit` | Sentar no chao ou na palmeira inclinada | 6 | 1 (lateral) | Alta | 7 (T-701) | Transicao sentar/levantar incluida |
| `dig` | Cavar com pa improvisada | 8 | 1 (lateral) | Media | 7 | Arco da Jangada e sinalizacao; inspirado em `sjwork.bmp` |
| `build` | Construir, colocar madeira, martelar | 8 | 1 (lateral) | Media | 7 | Arcos de construcao |
| `eureka` | Momento eureka, lampada acima da cabeca | 4 | 1 (frontal) | Media | 7 | Sprite de lampada separado (`fx_lightbulb.png`); inspirado em `litebulb.bmp` |
| `celebrate` | Danar, saltar de alegria | 8 | 1 (frontal) | Media | 7 | Arco da Jangada lancada, Olimpiadas |
| `hula` | Dancar hula com saia de palha improvisada | 10 | 1 (frontal) | Baixa | 8 | Evento comico raro; inspirado em `gjhula.bmp` |
| `tornado` | Rodar em tornado de frustacao | 6 | 1 | Baixa | 8 | Evento comico raro; inspirado em `gjhunt.bmp` |
| `swim` | Nado (ciclo de bracada) | 6 | 1 (lateral) | Media | 8 | Evento de mergulho |
| `dive` | Mergulho em varios angulos | 8 | 1 | Media | 8 | Inspirado em `gjdive.bmp` |
| `surf` | Surf com prancha improvisada | 8 | 1 (lateral) | Baixa | 8 | Evento raro; inspirado em `sjsur.bmp` |
| `bath_rain` | A "tomar banho" na chuva com os brazos abertos | 4 | 1 (frontal) | Baixa | 8 | Evento comico; inspirado em `mjbath.bmp` |
| `charge` | A correr para algo com entusiasmo | 6 | 1 (lateral) | Baixa | 8 | Evento de energia; inspirado em `jcharge.bmp` |
| `roll_ball` | A rolar em bola (queda comica) | 6 | 1 | Baixa | 8 | Evento de queda; inspirado em `gjdive.bmp` |

**Variantes por fase (multiplicador):**
As animacoes `idle`, `walk_*`, `fish`, `sleep`, `sit` e `look_up` precisam de 5 variantes (uma
por fase visual). As restantes animacoes de evento sao desenhadas apenas para a fase da primeira
aparicao e reutilizadas. Total estimado com variantes: ~420 a 500 frames.

**Variantes sazonais:** resolvidas por shader (Opcao C, secao 2c). Sem multiplicador de sprites.

---

### 8.2 Personagens Secundarios

#### A Sereia (Amor Imaginario)

Correspondencia directa com o arco "O Amor Imaginario" do `docs/narrative-design.md`. A sereia
nunca e interactiva: aparece ao longe, e sempre ambigua.

| ID | Descricao | Frames | Dimensoes | Prioridade | Fase |
|---|---|---|---|---|---|
| `sereia_boiar` | Sereia deitada a boiar na superficie da agua | 4 | 48x32px | Media | 8 |
| `sereia_relaxar` | Sereia a relaxar, cotovelo no recife imaginario | 4 | 48x40px | Media | 8 |
| `sereia_emergir` | Sereia a emergir do mar ate a cintura | 6 | 32x64px | Media | 8 |
| `sereia_desaparecer` | Sereia a submergir e desaparecer | 6 | 32x48px | Media | 8 |
| `sereia_sombra_fundo` | Sombra/silhueta no fundo do mar | 4 | 48x24px | Baixa | 8 |

Nota: a sereia e uma silhueta ou forma vaga, nunca detalhada. O utilizador ve-a; o naufrago
pode ou nao reparar. Inspirado directamente nas poses da folha gjdive.bmp do Johnny Castaway.

---

#### A Gaivota

Presente no catalogo actual como `anim_seagull` (Fase 6). Expandir com comportamentos especificos.

| ID | Descricao | Frames | Dimensoes | Prioridade | Fase |
|---|---|---|---|---|---|
| `gaivota_pe` | Gaivota de pe na areia | 2 | 24x16px | Alta | 6 (T-607) |
| `gaivota_voar` | Ciclo de voo (batida de asas) | 6 | 32x20px | Alta | 6 (T-607) |
| `gaivota_pousar` | Transicao voo para pouso | 4 | 28x18px | Media | 7 |
| `gaivota_roubar` | Gaivota a voar com peixe no bico | 6 | 32x20px | Media | 7 |
| `gaivota_ler` | Gaivota de pe "a ler" algo (evento comico) | 4 | 24x20px | Baixa | 8 |

Evento "roubo do peixe": quando o naufrago esta em `fish` e tem peixe, probabilidade de 2% por
minuto de a gaivota aparecer, voar sobre o peixe, e levar o peixe. Naufrago reage com `startle`
seguido de `tornado` ou `look_up` resignado.

---

#### O Companheiro Imaginario

O companheiro do Insulano nao e um macaco como o Mojo: e um objecto com cara (coco, tabua, garrafa,
etc.). A diferenca conceptual e importante. O que se aprende do Mojo e a variedade de poses do
companheiro em cena com o naufrago, nao a forma.

| ID | Descricao | Frames | Dimensoes | Prioridade | Fase |
|---|---|---|---|---|---|
| `companheiro_estatico` | Objecto em repouso na areia | 2 | 16x24px | Alta | 6 (T-605/606) |
| `companheiro_conversa` | Objecto inclinado (como se a ouvir) | 2 | 16x24px | Alta | 6 |
| `companheiro_cena_dupla` | Naufrago sentado ao lado do objecto | 4 | 80x40px | Media | 7 |
| `companheiro_desaparecer` | Objecto a ser levado pela mare | 4 | 16x24px | Media | 7 |
| `companheiro_garrafa_mar` | Garrafa a boiar (variante especifica) | 4 | 20x16px | Media | 7 |

---

### 8.3 Animais Visitantes

Expandido a partir do catalogo da Fase 6 (`docs/grafico-polimento.md` secao 3.1).

| ID | Nome | Frames | Dimensoes | Prioridade | Fase | Notas |
|---|---|---|---|---|---|---|
| `anim_seagull` | Gaivota (ver secao 8.2) | ver acima | ver acima | Alta | 6 | |
| `anim_dolphin` | Golfinho (arco de salto) | 6 | 32x16px | Media | 6 (T-607) | |
| `anim_turtle` | Tartaruga (vista de cima) | 4 | 16x16px | Media | 6 (T-607) | |
| `anim_crab` | Caranguejo (pincas levantadas) | 4 | 16x12px | Media | 6 (T-607) | |
| `anim_crow` | Corvo (ver secao 3a, Arvore Morta) | 6 | 16x12px | Media | 7 (T-705) | Pousado nos galhos |
| `anim_fish_school` | Cardume visivel sob a superficie | 6 | 48x16px | Baixa | 8 | Evento de agua |
| `anim_whale` | Baleia a respigar ao longe | 8 | 64x32px | Baixa | 8 | Evento lendario raro |

---

### 8.4 Efeitos Visuais

| ID | Descricao | Frames | Dimensoes | Blend | Prioridade | Fase |
|---|---|---|---|---|---|---|
| `fx_splash_small` | Splash de agua pequeno | 5 | 16x16px | alpha | Alta | 8 |
| `fx_splash_large` | Splash de agua grande (explosao) | 8 | 32x32px | alpha | Alta | 8 |
| `fx_splash_arc` | Splash em arco lateral | 5 | 24x20px | alpha | Media | 8 |
| `fx_wave_ring` | Ondulacao de superficie circular | 4 | 24x8px | alpha | Media | 8 |
| `fx_zzz` | ZZZ do sono (3 z's em escala crescente) | 4 | 16x20px | alpha | Alta | 7 |
| `fx_lightbulb` | Lampada de ideia acima da cabeca | 4 | 12x16px | alpha | Media | 7 |
| `fx_star_hit` | Estrelas de pancada (queda, susto) | 4 | 24x8px | additive | Media | 7 |
| `fx_dust_walk` | Poeira de caminhada (puff de areia) | 3 | 12x8px | alpha | Media | 7 |
| `fx_sweat` | Gota de suor (verao, calor) | 2 | 4x8px | alpha | Baixa | 7 |
| `fx_rain` | Gota de chuva individual | 2 | 2x8px | alpha | Alta | 6 (T-613) |
| `fx_star_night` | Estrela cintilante nocturna | 3 | 8x8px | additive | Alta | 6 (T-613) |
| `fx_biolum` | Bioluminescencia nocturna | 4 | 16x16px | additive | Alta | 6 (T-613) |
| `fx_sparkle` | Faiscas de fogueira | 3 | 4x4px | additive | Alta | 6 (T-613) |
| `fx_cloud_personal` | Nuvem de tempestade pessoal sobre o naufrago | 6 | 32x20px | alpha | Baixa | 8 |
| `fx_mist` | Nevoa de evento lendario | 6 | 64x32px | alpha | Baixa | 8 |
| `fx_leaf_fall` | Folha de outono a cair | 4 | 8x6px | alpha | Media | 7 (T-702) |
| `fx_flower` | Flor de primavera | 2 | 8x8px | alpha | Media | 7 (T-702) |
| `fx_snow_particle` | Flocos de neve individuais | 3 | 4x4px | alpha | Baixa | 8 |
| `fx_dive_shadow` | Sombra de queda no chao | 4 | 16x8px | alpha | Baixa | 8 |

---

### 8.5 Objectos de Cena e Aderecos

| ID | Descricao | Frames | Dimensoes | Prioridade | Fase |
|---|---|---|---|---|---|
| `prop_fishing_rod` | Cana de pesca (actualizada a 64x96 escala) | 1 | 128x24px | Alta | 6 (T-602) |
| `prop_fish` | Peixe cru | 1 | 128x64px | Alta | 6 (T-602) |
| `prop_raft_frame` | Jangada em construcao (esqueleto de madeira) | 3 | 80x40px | Media | 7 |
| `prop_raft_done` | Jangada completa (arco da Jangada) | 2 | 80x48px | Media | 7 |
| `prop_signal_fire` | Fogueira de sinalizacao (chamas altas) | 6 | 32x48px | Media | 7 |
| `prop_fire_smoke` | Coluna de fumo da sinalizacao | 6 | 16x64px | alpha | Media | 7 |
| `prop_message_bottle` | Garrafa com mensagem dentro | 1 | 20x32px | Media | 7 |
| `prop_diary_stone` | Pedra com marcas de dias riscados | 1 | 32x20px | Media | 7 |
| `prop_shelter` | Abrigo improvisado (Fase II+) | 1 | 64x48px | Media | 7 |
| `prop_palmleaf_crown` | Coroa de folhas de palmeira (Fase V) | 1 | 20x10px | Baixa | 7 |
| `prop_surfboard_sand` | Prancha de surf improvisada deitada na areia | 1 | 48x12px | Baixa | 8 |
| `prop_ghost_ship` | Navio fantasma sem luzes (evento lendario) | 4 | 128x64px | Baixa | 8 |
| `prop_rope` | Corda nova na praia (apos navio fantasma) | 1 | 32x8px | Baixa | 8 |

---

### 8.6 Bote Insuflavel (Evento Raro)

Inspirado directamente no bote insuflavel vermelho observado nos sprites do Johnny Castaway.
No Insulano pode ser um evento do arco "A Jangada" ou um evento lendario independente.

| ID | Descricao | Frames | Dimensoes | Prioridade | Fase |
|---|---|---|---|---|---|
| `bote_vazio` | Bote insuflavel vazio na agua | 2 | 48x24px | Baixa | 8 |
| `bote_com_naufrago` | Naufrago dentro do bote, remos | 6 | 64x32px | Baixa | 8 |
| `bote_afundado` | Bote a afundar (fim comico do arco) | 4 | 48x24px | Baixa | 8 |

---

### 8.7 Resumo de Contagens

| Categoria | Sprites distintos | Frames totais (est.) | Fase principal |
|---|---|---|---|
| Naufrago (animacoes base x5 fases) | 30 animacoes, 5 variantes | 420-500 | 7 |
| Naufrago (animacoes de evento, 1 variante) | 12 animacoes | 70-90 | 7-8 |
| Sereia | 5 sprites | 22 | 8 |
| Gaivota (expandida) | 5 sprites | 22 | 6-7 |
| Companheiro imaginario | 5 sprites | 16 | 6-7 |
| Animais visitantes (excl. gaivota) | 6 sprites | 34 | 6-8 |
| Efeitos visuais | 19 sprites | 80-90 | 6-8 |
| Objectos de cena | 12 sprites | 20-30 | 7-8 |
| Bote insuflavel | 3 sprites | 12 | 8 |
| Arvores e background | 8 sprites | 35-45 | 7 |
| **Total** | **~105 sprites distintos** | **730-840 frames** | **6 a 8** |

A Fase 7 cobre os itens de prioridade Alta e parte dos de prioridade Media (ver roadmap, secao 6).
A Fase 8 cobre os itens de prioridade Baixa e os eventos raros.

---

*Fim do documento. Versao 1.1. Actualizacoes devem passar por `python3 scripts/check_docs.py`
antes de commit (rejeita travessoes e verifica estrutura).*
