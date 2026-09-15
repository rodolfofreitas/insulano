# Catalogo de Accoes do Naufrago - Insulano
> Painel de 3 especialistas em game design indie (Stardew Valley, The Sims, Animal Crossing)
> Versao 1.1 | 95 accoes | Godot 4 + Beehave + CPUParticles2D
> Actualizado: campo "Sprites necessarios" em todas as accoes + seccao final de estimativas

---

## PRINCIPIO DE DESIGN FUNDAMENTAL

> **"Screensaver = entretenimento eterno, nao jogo de sobrevivencia. O naufrago sobrevive sempre. As necessidades dirigem o comportamento e criam drama emocional, nao punem o utilizador."**

### O Naufrago NUNCA Morre

Esta decisao e CRITICA e nao e negociavel. O Insulano e um protetor de ecra, nao um roguelike.

| O que as necessidades SAO | O que as necessidades NAO SAO |
|---|---|
| Motivadores de comportamento autonomo | Ameacas de morte ou game over |
| Fontes de drama emocional e humor | Mecanicas de pericao |
| Razoes para o naufrago agir de forma expressiva | Condicoes de falha |
| Textura psicologica que torna o personagem real | Sistemas de punir o utilizador |

**FOME a 100%:** o naufrago fica irritado, desesperado, esfomeado de forma expressiva e comicamente dramatica. Vai pescar com urgencia. Xinga o oceano. Reclama em voz alta. **Nunca morre.**

**SEDE a 100%:** o naufrago fica desconfortavel, babando, com alucinacoes comicas (ve agua onde nao ha). Procura coco ou chuva urgentemente. **Nunca morre.**

**ESPERANCA a 0:** o naufrago entra na "Noite Escura da Ilha" -- um estado emocional profundo de melancolia. Comportamentos niilistas, frases filosoficas, pode chorar. **Nunca morre. Vai recuperar.**

**Consequencia de design:** Nao existe "crise = morte". O campo `crise` em todas as necessidades descreve o comportamento mais extremo e expressivo -- nao um estado terminal. Depois do pico, o naufrago resolve a situacao (come, bebe, dorme) e o ciclo recomeça eternamente.

**Porquê importa:** O Insulano corre enquanto o utilizador nao esta a olhar. O utilizador volta ao computador e o naufrago ainda la esta -- talvez esfomeado, talvez a rezar, talvez a xingar o oceano. Nunca morto. Nunca acabado. **Ele esta sempre la.**

---

## Metodologia

Tres perspectivas de design aplicadas em conjunto:

- **Designer A (Stardew Valley):** foco em rotinas reconheciveis, charme domestico, satisfacao de loop curto
- **Designer B (The Sims):** foco em necessidades fisicas e psicologicas, urgencia visivel, hierarquia clara
- **Designer C (Animal Crossing):** foco em expressao emocional, sazonal, rituais diarios com significado

---

## Convencoes

| Campo | Valores possiveis |
|---|---|
| Raridade | ROTINA (varias vezes/dia) / OCASIONAL (1-3x/dia) / RARO (1x/dia ou menos) |
| Categoria | SOBREVIVENCIA / HIGIENE / EMOCAO / EXERCICIO / ENTRETENIMENTO / ESPIRITUAL / SOCIAL |
| Necessidade | FOME / SEDE / ENERGIA / HIGIENE / DIVERSAO / SOLIDAO / TEDIO / ESPERANCA / CALOR / FRIO / CONFORTO / ORGULHO / MOVIMENTO |
| Sprites | Animacoes novas necessarias + frames estimados (F6=upscale, F7=redesenho) |

---

## Secao 1 - SOBREVIVENCIA (22 accoes)

### A01 - Pescar a cana
- **Necessidade:** FOME
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (sentar, esperar, puxar), som `fishing_cast.ogg`, CPUParticles2D agua
- **Sprites:** REUTILIZA sit_idle existente. Novos: `fish_bite` (linha a puxar, 3 frames), `fish_reel` (bracos a puxar, 4 frames), `fish_caught` (segurar peixe no ar, 2 frames), `fish_lost` (linha caida, expressao, 2 frames). Prop: sprite cana de pesca (1 sprite estatico).
- **Notas:** ja existe - expandir com variantes de resultado

### A02 - Comer peixe assado
- **Necessidade:** FOME (-60pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (sentar junto fogueira, comer), som `eating_satisfied.ogg`, emote "+60" flutuante
- **Sprites:** Novos: `eat_sit` (sentar no chao, 2 frames), `eat_chew` (mastigar com prazer, 4 frames ciclicos), `eat_done` (limpar boca, satisfeito, 2 frames). Prop: sprite peixe-no-pau (1 sprite estatico).
- **Notas:** requer fogueira activa (T-119); sem fogueira come cru (reutiliza `eat_chew` com expressao diferente)

### A03 - Beber agua de coco
- **Necessidade:** SEDE (-30pts), FOME (-10pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (partir coco com pedra, beber), som `coconut_crack.ogg` + `drinking.ogg`
- **Sprites:** Novos: `coconut_crack` (levantar pedra, bater, 4 frames), `coconut_drink` (beber com o coco levantado, 3 frames), `coconut_done` (largar casca, limpar boca, 2 frames). Prop: sprite coco fechado, sprite coco aberto (2 sprites estaticos).
- **Notas:** cooldown 4h de jogo; cocos disponiveis na palmeira principal

### A04 - Apanhar coco da palmeira
- **Necessidade:** FOME (recurso), SEDE (recurso)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (sacudir palmeira, coco cai, apanhar), som `coconut_fall.ogg`, CPUParticles2D folhas
- **Sprites:** Novos: `shake_tree` (abracar tronco, sacudir, 4 frames), `pick_up` (agachar, apanhar, levantar, 3 frames). Prop: sprite coco a cair (animacao queda 3 frames). REUTILIZA walk existente para aproximar.
- **Notas:** max 3 cocos por arvore por dia de jogo

### A05 - Destilar agua do mar
- **Necessidade:** SEDE (-50pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (fogueira + concha sobre vapor), timer 120s, som `water_dripping.ogg`
- **Sprites:** Novos: `crouch_tend` (agachado a monitorizar algo, 2 frames ciclicos - reutilizavel em varios contextos), `wait_patient` (sentar ao lado, olhar, 3 frames). Prop: sprite concha-sobre-pedra (1 sprite composto). REUTILIZA CPUParticles2D vapour da fogueira.
- **Notas:** ESPERANCA +5; requer fogueira + 2 conchas

### A06 - Apanhar algas na praia
- **Necessidade:** FOME (-20pts, baixa qualidade)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (agachar, recolher), sprite alga flutuante, som `seaweed_collect.ogg`
- **Sprites:** REUTILIZA `pick_up` (de A04). Novos: `eat_disgusted` (comer com expressao de nojo, 4 frames - util em varios contextos). Prop: sprite alga (1 sprite).
- **Notas:** TEDIO -5; frase: "Cheira a oceano. Sabe a oceano. Decidi que gosto de oceano."

### A07 - Comer lula crua
- **Necessidade:** FOME (-25pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (apanhar da agua, hesitar, comer), CPUParticles2D tinta (humor), som `squelch.ogg`
- **Sprites:** Novos: `hesitate` (segurar objecto, olhar para ele, expressao duvida, 4 frames - MUITO REUTILIZAVEL). REUTILIZA `eat_disgusted` (A06). Prop: sprite lula (1 sprite).
- **Notas:** HIGIENE -10; CPUParticles2D tinta roxa = efeito comico unico

### A08 - Recolher agua da chuva
- **Necessidade:** SEDE (-40pts)
- **Raridade:** OCASIONAL (condicional chuva)
- **Godot:** AnimationPlayer (correr com concha, abrir boca ao ceu), CPUParticles2D chuva, som `rain_collect.ogg`
- **Sprites:** Novos: `mouth_open_sky` (cabeca para cima, boca aberta, expressao extase, 2 frames), `run_urgency` (correr rapido com objecto nas maos, 6 frames - variante de run). REUTILIZA CPUParticles2D chuva existente.
- **Notas:** WeatherService=rain/storm; SEDE >= 70 activa automaticamente

### A09 - Acender fogueira
- **Necessidade:** CALOR (-20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (esfregar paus, soprar), CPUParticles2D chamas (T-119), som `campfire_crackling.ogg`
- **Sprites:** Novos: `rub_sticks` (ajoelhado, esfregar paus, 4 frames ciclicos), `blow_fire` (soprar para o chao, bochechas inchadas, 3 frames), `fire_success` (levantar, punho, expressao Prometeu, 3 frames). REUTILIZA CPUParticles2D fogueira (T-119).
- **Notas:** falha ocasionalmente; ESPERANCA -5 se falha

### A10 - Recolher lenha
- **Necessidade:** ENERGIA (recurso fogueira)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (agachar, apanhar ramos), inventario visual, som `stick_collect.ogg`
- **Sprites:** REUTILIZA `pick_up` (A04). REUTILIZA walk para deslocacao. Prop: sprite pilha de lenha no HUD (variantes: vazia, cheia, 3 estados).
- **Notas:** limite 10 unidades; TEDIO -3

### A11 - Construir abrigo de folhas
- **Necessidade:** ENERGIA (repouso), FRIO
- **Raridade:** RARO
- **Godot:** AnimationPlayer (empilhar folhas), sprite cabana, som `leaves_rustle.ogg`
- **Sprites:** Novos: `build_overhead` (levantar e empilhar algo sobre a cabeca, 4 frames), `build_inspect` (recuar, inclinar cabeca, avaliar, 3 frames). Prop: sprite abrigo-folhas (3 estados: construcao, completo, danificado).
- **Notas:** ORGULHO +20; dura 3 dias de jogo

### A12 - Reparar abrigo
- **Necessidade:** FRIO, CONFORTO
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (martelar/empilhar), som `wood_tap.ogg`, sprite abrigo muda visual
- **Sprites:** REUTILIZA `build_overhead` (A11). Prop: sprite abrigo-danificado para sprite abrigo-completo (transicao).
- **Notas:** so disponivel se abrigo existe e esta danificado; ORGULHO +5

### A13 - Construir cama de folhas
- **Necessidade:** ENERGIA, CONFORTO
- **Raridade:** RARO
- **Godot:** AnimationPlayer (arranjar folhas no chao), sprite cama emerge, som `leaves_rustle.ogg`
- **Sprites:** Novos: `arrange_floor` (ajoelhar, arrumar no chao, 4 frames). Prop: sprite cama-folhas (2 estados: a fazer, completa).
- **Notas:** dormir na cama +10 ENERGIA extra; ORGULHO +15

### A14 - Fazer sinal na areia
- **Necessidade:** ESPERANCA (+15pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (ajoelhar, escrever na areia com pau), texto "SOCORRO"/"HELP"/"SOS", som `sand_write.ogg`
- **Sprites:** Novos: `write_floor` (ajoelhado a escrever com pau, 4 frames ciclicos). Prop: sprites de texto na areia ("SOCORRO", "HELP", "SOS", "AU SECOURS", "AJUDA" - 5 sprites estaticos). REUTILIZA prop pau (stick).
- **Notas:** onda apaga (evento tragiccomico); varias linguas por TEDIO alto

### A15 - Construir sinaleiro de pedras
- **Necessidade:** ESPERANCA (+25pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (empilhar pedras), sprite pilha permanente, som `stone_stack.ogg`
- **Sprites:** Novos: `stack_crouch` (agachado, pegar e empilhar pedra, 5 frames). REUTILIZA `build_inspect` (A11). Prop: sprite sinaleiro-pedras (4 estados de altura: 0, 1/3, 2/3, completo).
- **Notas:** ORGULHO +25; TEDIO -20; tempestade pode derrubar

### A16 - Fazer anzol de osso
- **Necessidade:** FOME (ferramenta)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (afiar, dobrar), sprite anzol no inventario, som `bone_scratch.ogg`
- **Sprites:** Novos: `craft_small` (sentar, trabalhar com maos, olhar de perto, 5 frames - reutilizavel para qualquer craft). Prop: sprite anzol-osso (1 sprite inventario).
- **Notas:** ORGULHO +30; melhora chance de pesca bem sucedida

### A17 - Apanhar caranguejo
- **Necessidade:** FOME (-20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (agachar, apanhar rapido), CPUParticles2D areia, som `crab_scuttle.ogg`
- **Sprites:** Novos: `lunge_grab` (agachar rapido, estender mao, 3 frames rapidos). Prop: sprite caranguejo (idle 2 frames + walk 4 frames - reutilizavel como "amigo caranguejo").
- **Notas:** pode soltar por amizade (SOLIDAO -5)

### A18 - Comer fruta desconhecida
- **Necessidade:** FOME (-15pts) + risco
- **Raridade:** RARO
- **Godot:** AnimationPlayer (cheirar, hesitar muito, comer), CPUParticles2D ponto interrogacao
- **Sprites:** REUTILIZA `hesitate` (A07). REUTILIZA `eat_disgusted` (A06) ou `eat_chew` (A02) conforme resultado. Prop: sprite fruta-desconhecida (1 sprite, cor ambigua).
- **Notas:** 70% ok; 20% nojo; 10% atordoado

### A19 - Guardar peixe para mais tarde
- **Necessidade:** FOME (gestao recurso)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (pendurar peixe na palmeira), sprite peixe pendurado, som `drip.ogg`
- **Sprites:** Novos: `hang_object` (levantar para cima, prender em algo, 3 frames). Prop: sprite peixe-pendurado (1 sprite que aparece na palmeira).
- **Notas:** peixe estraga apos 1 dia; ORGULHO +10

### A20 - Apanhar agua de folha de palmeira
- **Necessidade:** SEDE (-15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (dobrar folha, beber gota a gota), som `water_drip_small.ogg`
- **Sprites:** REUTILIZA `crouch_tend` (A05) para dobrar folha. REUTILIZA `coconut_drink` (A03) para beber. Prop: sprite folha-calha (1 sprite).
- **Notas:** so de manha (orvalho); TEDIO -5

### A21 - Assar coco no lume
- **Necessidade:** FOME (-30pts), DIVERSAO (+5)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (colocar coco na fogueira, esperar), som `sizzle.ogg`, CPUParticles2D vapor
- **Sprites:** REUTILIZA `crouch_tend` (A05) para vigiar. REUTILIZA prop coco. Prop: sprite coco-assado (variante visual do coco normal, tons castanho).
- **Notas:** requer fogueira; frase sobre gastronomia tropical

### A22 - Montar armadilha de agua
- **Necessidade:** SEDE (recurso passivo)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (construir), sprite armadilha permanente, som `drip_fill.ogg`
- **Sprites:** REUTILIZA `arrange_floor` (A13). Prop: sprite armadilha-folhas (3 estados: vazia, a encher, cheia).
- **Notas:** ORGULHO +20; ESPERANCA +10

---

## Secao 2 - HIGIENE (12 accoes)

### B01 - Tomar banho no mar
- **Necessidade:** HIGIENE (+40pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (entrar na agua, esfregar, sair), CPUParticles2D espuma, som `splash_bathing.ogg`
- **Sprites:** Novos: `wade_enter` (entrar na agua, levantar pes, 4 frames), `bathe_scrub` (na agua ate cintura, esfregar bracos/cabeca, 4 frames ciclicos), `wade_exit` (sair, sacudir agua, 3 frames). Nota: requer sprite com "estar na agua" - parte inferior transparente/ondulada.
- **Notas:** CALOR -10; frase sobre termas tropicais

### B02 - Lavar a roupa no mar
- **Necessidade:** HIGIENE (+20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (ajoelhar na beira, esfregar roupa na pedra), CPUParticles2D bolhas, som `washing.ogg`
- **Sprites:** Novos: `wash_kneel` (ajoelhar, movimento de esfregar para baixo, 4 frames). Prop: sprite roupa-pendurada (na palmeira, a secar, 1 sprite com animacao vento 2 frames).
- **Notas:** sprite roupa pendente visivel no ecra por 1h de jogo

### B03 - Fazer xixi atras da palmeira
- **Necessidade:** HIGIENE (urgencia biologica), CONFORTO
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (olhar em volta, ir atras da arvore, desaparecer, reaparecer satisfeito), som `relieve.ogg`
- **Sprites:** Novos: `look_around_guilty` (olhar esquerda-direita nervosamente, 3 frames), `relief_exit` (sair de atras da arvore com expressao aliviada, 2 frames). O momento "atras da arvore" e ocultado - naufrago desaparece atras do sprite da palmeira.
- **Notas:** CONFORTO +10; gaivota pode pousar ao lado (evento especial)

### B04 - Fazer coco atras das pedras
- **Necessidade:** HIGIENE, CONFORTO
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (andar rapido para pedras, ficar atras, sair aliviado), emote nuvem alivio
- **Sprites:** REUTILIZA `look_around_guilty` (B03). REUTILIZA `relief_exit` (B03). Prop: sprite rochas-cobertura (ja existente ou novo elemento de cenario).
- **Notas:** gaivota pousa - reaccao de panico comico (3 frames expressao horror)

### B05 - Lavar as maos no mar
- **Necessidade:** HIGIENE (+15pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (agachar na agua, esfregar maos), som `water_hands.ogg`
- **Sprites:** Novos: `wash_hands` (agachar, maos na agua, movimento circular, 3 frames). REUTILIZA pos de agachamento existente.
- **Notas:** faz apos comer e tarefas sujas

### B06 - Limpar os dentes com ramo
- **Necessidade:** HIGIENE (+10pts), ORGULHO
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (pegar ramo, escovar, examinar na agua), som `brushing.ogg`
- **Sprites:** Novos: `brush_teeth` (ramo a ir e vir na boca, 3 frames ciclicos), `examine_smile` (abrir boca para "espelho" agua, 2 frames). Prop: sprite ramo-escova (pequeno, na mao).
- **Notas:** ORGULHO +5; faz de manha

### B07 - Pentear o cabelo com concha
- **Necessidade:** HIGIENE (+5pts), ORGULHO (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (pentear com concha), som `hair_comb.ogg`
- **Sprites:** Novos: `comb_hair` (mao com concha a puxar pelo cabelo de baixo para cima, 3 frames). Prop: sprite concha-pente (na mao, orientacao especifica).
- **Notas:** resultado visual questionavel; DIVERSAO +5

### B08 - Remover areia das orelhas
- **Necessidade:** HIGIENE (+5pts), CONFORTO (+10pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (inclinar cabeca, bater lateral), CPUParticles2D areia cai, som `shake_head.ogg`
- **Sprites:** Novos: `tilt_shake` (cabeca inclinada para o lado, bater, 3 frames). REUTILIZA CPUParticles2D areia.
- **Notas:** acontece automaticamente apos acordar

### B09 - Tirar espinhos dos pes
- **Necessidade:** HIGIENE (+5pts), CONFORTO (+15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar, segurar pe, puxar espinho), som `ouch.ogg`, emote estrelas dor
- **Sprites:** Novos: `sit_foot_examine` (sentar, dobrar pe sobre o joelho, olhar de perto, 3 frames), `pull_thorn` (gesto de puxar com expressao dor, 2 frames). Prop: sprite espinho (micro-sprite 2x2px na planta do pe).
- **Notas:** MOVIMENTO sobe depois; frase sobre medicina tropical

### B10 - Corar ao sol (secar)
- **Necessidade:** HIGIENE (+10pts), CALOR (-5pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (estender bracos ao sol, rodar), efeito brilho sprite, som `sigh_content.ogg`
- **Sprites:** Novos: `arms_out_sun` (pose estrela com bracos abertos, expressao satisfeita, 2 frames "respiracao"). REUTILIZA shader de brilho (Fase 7: shader de bronzeado por estacao).
- **Notas:** apos banho; CONFORTO +10

### B11 - Espremer ferida
- **Necessidade:** HIGIENE (+15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (olhar para o braco, apertar, soprar), emote dor, som `ouch_small.ogg`
- **Sprites:** Novos: `examine_arm` (segurar o proprio braco, olhar de perto, 3 frames), `blow_on_wound` (soprar para o braco, expressao dor/alivio, 2 frames). Prop: sprite marca-ferida no braco (overlay temporal).
- **Notas:** so activa se HIGIENE muito baixa

### B12 - Fazer mascara de lama no rosto
- **Necessidade:** HIGIENE (comico), DIVERSAO (+15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (apanhar lama, aplicar no rosto), sprite rosto com lama, som `mud_apply.ogg`
- **Sprites:** Novos: `apply_face` (mao a espalhar no rosto, 3 frames), sprite lama-no-rosto como overlay no sprite base (1 overlay que dura ate banho). Prop: overlay lama (manchas castanhas no rosto, 1 sprite de overlay).
- **Notas:** TEDIO -15; frase sobre spa de luxo

---

## Secao 3 - EMOCAO (17 accoes)

### C01 - Chorar de saudade
- **Necessidade:** SOLIDAO (crise >= 80)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar, cabeca baixa, ombros a tremer), CPUParticles2D lagrimas, som `crying_soft.ogg`
- **Sprites:** Novos: `cry_sit` (sentar com cabeca baixa, ombros levemente subindo/descendo, 4 frames ciclicos). CPUParticles2D lagrimas: 2 emissores nos olhos (configurados sobre os olhos do sprite). IMPORTANTE: frame de expressao especifico.
- **Notas:** SOLIDAO -20 depois; ESPERANCA -10; a cena mais emocional do jogo

### C02 - Xingar o oceano
- **Necessidade:** TEDIO (crise >= 70), SOLIDAO
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (agitar punho ao oceano, gritar), CPUParticles2D raiva, som `shout_frustrated.ogg`
- **Sprites:** Novos: `shout_fist` (de pe na beira da agua, punho levantado, boca aberta, 4 frames com "vibrato" de raiva). CPUParticles2D: pequenas particulas vermelhas/laranjas a sair da cabeca.
- **Notas:** TEDIO -20; depois expressao envergonhada (2 frames `shame_look`)

### C03 - Rir sozinho sem razao
- **Necessidade:** TEDIO (crise), DIVERSAO
- **Raridade:** RARO
- **Godot:** AnimationPlayer (rir com a barriga, dobrar-se), CPUParticles2D notas, som `laughter.ogg`
- **Sprites:** Novos: `laugh_belly` (dobrar-se a rir, maos na barriga, 5 frames com movimento exagerado). CPUParticles2D notas musicais + pequenas estrelas. Expressao: "ha ha" com boca bem aberta.
- **Notas:** TEDIO -25; SOLIDAO -10; olha em volta depois preocupado

### C04 - Ficar entediado visivelmente
- **Necessidade:** TEDIO (estado passivo alto)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (bocejar exagerado, olhar unhas, balancas os pes), emote ZZZ
- **Sprites:** Novos: `yawn` (boca bem aberta, bracos esticados, 4 frames), `inspect_nails` (olhar para as maos com tedio total, 2 frames), `sit_swing_feet` (sentado numa pedra a balancear os pes, 4 frames ciclicos - MUITO REUTILIZAVEL como idle de espera).
- **Notas:** trigger automatico TEDIO >= 50

### C05 - Expressar gratidao ao sol
- **Necessidade:** ESPERANCA (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (olhar para cima, sorrir, acenar), som `sigh_happy.ogg`
- **Sprites:** Novos: `look_up_smile` (cabeca levantada, olhos fechados, sorriso, 2 frames "respiracao"). REUTILIZA como base para outras expressoes contemplativas.
- **Notas:** SOLIDAO -5; frase filosofica sobre luz

### C06 - Ficar feliz com pequenas coisas
- **Necessidade:** DIVERSAO (+15pts), ESPERANCA (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (pular de alegria, punho ar), CPUParticles2D estrelas, som `happy_jingle.ogg`
- **Sprites:** Novos: `jump_joy` (salto pequeno com punho no ar, 4 frames: prepare, up, peak, land). CPUParticles2D: estrelinhas douradas. EXPRESSAO: enorme sorriso, olhos semi-fechados de felicidade.
- **Notas:** trigger: encontrar concha bonita, peixe grande, coco perfeito

### C07 - Ter ataque de angustia
- **Necessidade:** ESPERANCA (crise <= 15)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar abracar joelhos, balancando), CPUParticles2D escuro, som `heartbeat_fast.ogg`
- **Sprites:** Novos: `hug_knees_rock` (sentar abracar joelhos, balanco lento para frente e para tras, 6 frames ciclicos). CPUParticles2D: particulas escuras/cinzentas a circular. Esta animacao e das mais expressivas - merece frames extras.
- **Notas:** ESPERANCA sobe 30pts depois; companheiro reage se existir

### C08 - Ficar contente sem motivo
- **Necessidade:** DIVERSAO, ESPERANCA
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (assobiar, dar saltitos ao andar), tom musical contente
- **Sprites:** Novos: `skip_walk` (andar com saltinhos felizes, 6 frames - variante de walk com bounce extra). REUTILIZA som `whistling.ogg`. O melhor estado visual do personagem.
- **Notas:** todas as necessidades baixas trigger

### C09 - Lamentar algo do passado
- **Necessidade:** SOLIDAO, ESPERANCA
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar, olhar a mao como se visse foto), som `melancholy_hum.ogg`
- **Sprites:** Novos: `sit_memory` (sentar, olhar para a palma da mao vazia, expressao nostalgica, 3 frames lentos). Expressao: a mais complexa do jogo - misto de tristeza e ternura.
- **Notas:** gera frase LLM profunda; SOLIDAO -15 (processar e bom)

### C10 - Ter momento de clareza filosofica
- **Necessidade:** TEDIO (-20pts), ESPERANCA (+15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (parar tudo, olhar horizonte, assentir devagar), som `insight_chime.ogg`
- **Sprites:** Novos: `nod_slow` (assentir muito devagar, expressao de quem percebeu algo, 3 frames lentos). REUTILIZA a postura de "olhar para o horizonte" existente (C06 dos eventos).
- **Notas:** gera frase LLM filosofica; DIVERSAO +10

### C11 - Sentir-se orgulhoso de si mesmo
- **Necessidade:** ORGULHO (pos construcao/pesca)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (por maos na cintura, olhar para criacao propria), som `proud_hum.ogg`
- **Sprites:** Novos: `hands_hips_proud` (pos heroi: maos nas ancas, peito para fora, expressao satisfeita, 2 frames "respiracao"). Muito util como pos de sucesso geral.
- **Notas:** ESPERANCA +10; SOLIDAO -5

### C12 - Ter saudades de comida especifica
- **Necessidade:** FOME (psicologica), SOLIDAO
- **Raridade:** RARO
- **Godot:** AnimationPlayer (olhar nada, baba imaginaria, acordar), CPUParticles2D imagem comida estilizada
- **Sprites:** Novos: `daydream_drool` (olhar vazio, baba a escorrer da boca, expressao sonhadora, 4 frames). CPUParticles2D: icone comida estilizada (pizza/bifana como sprite simples a flutuar).
- **Notas:** gera frase LLM sobre prato especifico

### C13 - Entrar em negacao
- **Necessidade:** TEDIO (-10pts ilusorio)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (cruzar bracos, abanecar cabeca vigorosamente), emote "nao" vermelho
- **Sprites:** Novos: `arms_cross_denial` (bracos cruzados, abanecar cabeca rapidamente, 4 frames). CPUParticles2D: X vermelho. Expressao de quem nao aceita a realidade.
- **Notas:** ESPERANCA <= 20; TEDIO >= 80 trigger

### C14 - Sentir frio pela primeira vez na noite
- **Necessidade:** FRIO
- **Raridade:** ROTINA (noite/chuva)
- **Godot:** AnimationPlayer (abracar-se, tremer ligeiramente), CPUParticles2D baforadas, tons azuis
- **Sprites:** Novos: `hug_self_shiver` (abracar o proprio corpo, tremer de frio, 4 frames ciclicos com dentes a bater). CPUParticles2D: small puffs brancos saindo da boca. SHADER: tinge azul o sprite quando FRIO alto.
- **Notas:** ENERGIA decai mais rapido no frio

### C15 - Sentir calor excessivo ao meio-dia
- **Necessidade:** CALOR
- **Raridade:** ROTINA (verao, meio-dia)
- **Godot:** AnimationPlayer (abanar com folha, vaguear lentamente), CPUParticles2D ondas calor, sprite sudorese
- **Sprites:** Novos: `fan_self` (abanar folha na cara, expressao exausta, 4 frames), `walk_exhausted` (andar muito devagar, cabecanedo, 4 frames - variante lenta de walk). CPUParticles2D: ondas de calor distorcao (shader heat shimmer). Overlay: gotas de suor no sprite.
- **Notas:** vai para sombra automaticamente CALOR >= 70

### C16 - Ter nostalgia de musica
- **Necessidade:** SOLIDAO, DIVERSAO
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar, fechar olhos, balancando levemente), som `humming_nostalgic.ogg`
- **Sprites:** Novos: `sway_memory` (sentado, olhos fechados, ligeiro balanco lateral ao ritmo, 4 frames ciclicos). Muito similar a `cry_sit` mas com expressao feliz-triste.
- **Notas:** gera frase LLM sobre musica que lembra

### C17 - Ter momento de paz absoluta
- **Necessidade:** CONFORTO, ENERGIA
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar beira mar, fechar olhos, sorrir minimo), efeito brilho, som `peace_ambient.ogg`
- **Sprites:** Novos: `sit_peace` (sentar na beira da agua de pernas cruzadas, olhos fechados, sorriso sereno, 3 frames muito lentos). Efeito: shader brilho suave em todo o sprite. O frame mais bonito do jogo.
- **Notas:** TODAS as necessidades melhoram 5pts; o melhor evento emocional

---

## Secao 4 - EXERCICIO (11 accoes)

### D01 - Correr pela praia
- **Necessidade:** MOVIMENTO (+20pts), TEDIO (-20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (correr 4 frames), CPUParticles2D areia, som `running_sand.ogg`
- **Sprites:** Novos: `run` (animacao correr 6 frames completa - muito diferente de walk, com mais bounce e inclinacao para a frente). CPUParticles2D: areia a levantar atras dos pes. Rastro de pegadas como sprite temporario.
- **Notas:** velocidade dobrada vs walk; para ofegante; frase sobre running

### D02 - Nadar livremente no mar
- **Necessidade:** MOVIMENTO (+25pts), TEDIO (-25pts), CALOR (-20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (sprint para agua, nadar), CPUParticles2D espuma, som `swimming.ogg`
- **Sprites:** Novos: `swim_stroke` (deitado na horizontal na agua, bracadas alternadas, 4 frames), `swim_float` (flutuar de costas, expressao satisfeita, 2 frames). Sprite especial: naufrago em modo horizontal (diferente de todos os outros sprites verticais). Mascarar a metade inferior com onda.
- **Notas:** HIGIENE +15; ESPERANCA +10

### D03 - Saltar de arvore para o mar
- **Necessidade:** DIVERSAO (+30pts), MOVIMENTO (+20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (escalar, equilibrar, saltar), CPUParticles2D splash grande, som `big_splash.ogg`
- **Sprites:** Novos: `climb_tree` (abracar tronco, subir frame a frame, 6 frames), `perch_top` (equilibrar no alto com expressao determinada, 2 frames), `jump_arc` (corpo em arco de salto, 4 frames com rotacao), `surface_swim` (reemergir da agua, expressao euforia, 2 frames). O evento mais espetacular visualmente.
- **Notas:** requer palmeira inclinada (F7); ESPERANCA +20 do topo

### D04 - Fazer flexoes
- **Necessidade:** MOVIMENTO (+10pts), ORGULHO (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (3 flexoes, para ofegante, polegar), som `effort_grunt.ogg`
- **Sprites:** Novos: `pushup` (deitado face-down, flexao completa, 4 frames: down, up, down, up), `pushup_done` (levantar, ofegar, polegar acima, 2 frames).
- **Notas:** ao 7o dia seguido faz 5 flexoes com frase de atleta

### D05 - Fazer abdominais
- **Necessidade:** MOVIMENTO (+10pts), ORGULHO (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (deitar, levantar torso, 3x), som `effort_grunt.ogg`
- **Sprites:** Novos: `situp` (deitado, torso a levantar, 3 frames: down, up, strain). REUTILIZA `pushup_done` para o final. Contar em voz alta: emote numerico (1, 2, 3).
- **Notas:** numero varia com humor

### D06 - Fazer alongamentos matinais
- **Necessidade:** ENERGIA (+15pts), MOVIMENTO
- **Raridade:** ROTINA (de manha)
- **Godot:** AnimationPlayer (esticar bracos, dobrar, rodar pescoco), som `stretch_pop.ogg`
- **Sprites:** Novos: `stretch_arms` (bracos esticados para cima, bocejo simultaneo, 3 frames), `stretch_bend` (dobrar para tocar os pes, 3 frames), `neck_roll` (rodar o pescoco, 2 frames). Sequencia de 3 exercicios = 1 animacao composta.
- **Notas:** faz logo apos acordar; CONFORTO +10

### D07 - Dancar sozinho na praia
- **Necessidade:** DIVERSAO (+30pts), SOLIDAO (-20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (movimentos danca varios), CPUParticles2D notas, som `humming_dance.ogg`
- **Sprites:** Novos: `dance_happy` (danca alegre, 8 frames ciclicos com movimento de bracos e pes), `dance_sad` (danca lenta e melancolica, 6 frames). Dois estilos de danca conforme humor. A animacao mais longa e mais divertida do jogo.
- **Notas:** danca diferente por nivel de SOLIDAO

### D08 - Andar a toa pela ilha
- **Necessidade:** TEDIO (-15pts), MOVIMENTO (+10pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (andar devagar, parar, olhar, continuar)
- **Sprites:** REUTILIZA walk existente mas com velocidade reduzida. Novos: `idle_look_around` (parar, virar a cabeca esquerda-direita devagar, 4 frames). SHADER leve de "pensar" (balao de pensamento).
- **Notas:** versao expressiva da caminhada existente

### D09 - Nadar debaixo de agua (mergulho)
- **Necessidade:** DIVERSAO (+20pts), FOME (-10pts recurso)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (mergulhar, desaparecer, reemerger com peixe/concha), som `underwater_bubbles.ogg`
- **Sprites:** Novos: `dive_under` (mergulho para baixo, pernas no ar, 3 frames), `emerge_prize` (sair da agua com algo levantado, expressao triunfo, 3 frames). O naufrago desaparece do ecra por 3-5s (so bolhas visiveis).
- **Notas:** pode encontrar objectos especiais; TEDIO -30

### D10 - Trepar a palmeira
- **Necessidade:** MOVIMENTO (+20pts), DIVERSAO (+15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (abracar arvore, subir, chegar ao topo), CPUParticles2D cocos caem, som `tree_climb.ogg`
- **Sprites:** REUTILIZA `climb_tree` (D03) - esta e a razao para ter esse sprite. Novos: `top_survey` (no topo da arvore, mao em pala, olhar ao longe, 2 frames). Prop: cocos a cair (ja em A04).
- **Notas:** ESPERANCA +20 do topo; 20% chance de cair

### D11 - Fazer corrida de obstaculos imaginaria
- **Necessidade:** DIVERSAO (+25pts), MOVIMENTO (+20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (correr, saltar pedras, rastejar, festejar), CPUParticles2D pista imaginaria
- **Sprites:** REUTILIZA `run` (D01). Novos: `hurdle_jump` (salto sobre obstaculo, 4 frames), `crawl` (rastejar no chao, 4 frames). `celebrate_finish` (cruzar linha imaginaria com bracos levantados, 3 frames).
- **Notas:** TEDIO = 100 trigger; frase de locutor imaginario

---

## Secao 5 - ENTRETENIMENTO (15 accoes)

### E01 - Cantar em voz alta
- **Necessidade:** DIVERSAO (+20pts), SOLIDAO (-15pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (abrir boca, gesticular), CPUParticles2D notas, som `singing_humming.ogg`
- **Sprites:** Novos: `sing_conduct` (de pe, gesticular como se regendo uma orquestra, boca aberta, 6 frames). CPUParticles2D: notas musicais coloridas a sair da boca. Expressao: olhos fechados de prazer.
- **Notas:** qualidade melhora com dias (ORGULHO); canta diferente por hora

### E02 - Assobiar uma melodia
- **Necessidade:** DIVERSAO (+10pts), TEDIO (-15pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (assobiar com bochechas), som `whistling.ogg`
- **Sprites:** Novos: `whistle_walk` (andar com bochechas inchadas, assobio, 4 frames - overlay sobre walk). Pode ser usado como layer adicional sobre qualquer accao de deslocamento.
- **Notas:** melodias varias com randomizacao de pitch

### E03 - Cantarolar enquanto trabalha
- **Necessidade:** DIVERSAO (+5pts), TEDIO (-10pts)
- **Raridade:** ROTINA
- **Godot:** Overlay sobre outras animacoes, nota musical flutuante, som `humming_work.ogg`
- **Sprites:** Prop overlay: nota musical flutuante sobre a cabeca (1 sprite animado 2 frames, loop). Nao precisa de animacao propria - e um overlay sobre qualquer accao de trabalho.
- **Notas:** layer adicional de personalidade; sem sprites dedicados no corpo

### E04 - Contar historia para o companheiro
- **Necessidade:** SOLIDAO (-25pts), DIVERSAO (+15pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (gesticular para o companheiro, encenacao), CPUParticles2D balao de fala
- **Sprites:** Novos: `storytell_gesture` (de pe, gesticulos exagerados de narrador, 6 frames com poses variadas). REUTILIZA sprite companheiro existente. CPUParticles2D: balao de pensamento estilizado com mini-icones da historia.
- **Notas:** requer companheiro imaginario; gera frase LLM

### E05 - Jogar sozinho com pedras
- **Necessidade:** DIVERSAO (+20pts), TEDIO (-25pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (organizar pedras, "jogar" com elas), som `stone_clink.ogg`
- **Sprites:** Novos: `play_floor` (sentado no chao a manipular objectos na frente, 4 frames). REUTILIZA `arrange_floor` (A13) como base mas com expressao mais playful. Prop: pedras-jogo (pequenos sprites coloridos).
- **Notas:** inventa jogos proprios com regras aleatorias

### E06 - Fazer teatro de sombras
- **Necessidade:** DIVERSAO (+25pts), TEDIO (-25pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (noite, maos a fazer sombras), CPUParticles2D sombras, som `laughter_soft.ogg`
- **Sprites:** Novos: `shadow_puppet` (de pe contra a parede/cabana, maos levantadas em poses de sombra, 6 frames com poses diferentes - animal, pessoa, barco). Efeito: sombras projectadas (CPUParticles2D ou shader).
- **Notas:** so disponivel a noite com fogueira; ORGULHO +15

### E07 - Inventar jogo de arremesso
- **Necessidade:** DIVERSAO (+25pts), MOVIMENTO (+10pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (marcar alvo, atirar pedras), CPUParticles2D impacto, som `stone_throw.ogg`
- **Sprites:** Novos: `throw_overhand` (pose de arremesso - preparar, lancar, follow-through, 4 frames). Prop: sprite pedra-em-voo (1 pixel ou sprite minusculo a voar em arco).
- **Notas:** "recorde pessoal" cada vez que ganha; ORGULHO +10

### E08 - Ler em voz alta (livro imaginario)
- **Necessidade:** DIVERSAO (+15pts), SOLIDAO (-15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentar, segurar algo imaginario, folhear, ler), som `page_turn.ogg`
- **Sprites:** Novos: `read_book` (sentar, segurar livro imaginario no ar como se existisse, olhos a "seguir linhas", 4 frames). Expressao muda com o "conteudo". O livro e invisivel - o humor vem de segurar o nada com seriedade total.
- **Notas:** ORGULHO +10; gera frases LLM de "livro"

### E09 - Brincar com a marisma
- **Necessidade:** DIVERSAO (+15pts), TEDIO (-15pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (observar caranguejos, seguir um), CPUParticles2D caranguejos
- **Sprites:** REUTILIZA `crouch_tend` (A05) para observar. Prop: sprite caranguejo (de A17). Novos: `follow_crouch` (caminhar agachado a seguir algo pequeno no chao, 4 frames - muito expressivo e comico).
- **Notas:** pode dar nome ao caranguejo (evento especial)

### E10 - Construir castelo de areia
- **Necessidade:** DIVERSAO (+30pts), ORGULHO (+20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (construir, recuar para admirar), sprite castelo, som `sand_sculpt.ogg`
- **Sprites:** Novos: `sculpt_kneel` (de joelhos a construir com maos na areia, 5 frames - o mais elaborado dos "construir"). REUTILIZA `build_inspect` (A11) para admirar. Prop: sprite castelo-areia (4 estados de construcao, progressivos).
- **Notas:** onda destroi (tragiccomico); TEDIO -30

### E11 - Imitar sons de animais
- **Necessidade:** DIVERSAO (+20pts), SOLIDAO (-10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (varias expressoes), sons de imitacao comicos
- **Sprites:** Novos: `imitate_bird` (bracos como asas, expressao caricata, 4 frames), `imitate_fish` (cara de peixe com boca a abrir-fechar, 3 frames). Dois estilos distintos de imitacao. CPUParticles2D: icone do animal sendo imitado.
- **Notas:** gaivota responde ocasionalmente

### E12 - Fazer barulho de instrumentos com boca
- **Necessidade:** DIVERSAO (+20pts), TEDIO (-20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (beatbox, expressoes), som `beatbox.ogg`
- **Sprites:** REUTILIZA `sing_conduct` (E01) como base. Novos: `beatbox_face` (expressoes extremas de beatbox com bochechas, 5 frames - muito mais exagerado que cantar normal). CPUParticles2D: zig-zags sonoros.
- **Notas:** melhora com nivel de TEDIO

### E13 - Inventar competicao de salto de pedras
- **Necessidade:** DIVERSAO (+25pts), MOVIMENTO (+10pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (atirar pedra, contar ressaltos, celebrar), CPUParticles2D agua, som `splash_skip.ogg`
- **Sprites:** REUTILIZA `throw_overhand` (E07). Novos: `commentate` (de pe, mao na boca como microfone, expressao de locutor desportivo, 3 frames). Prop: pedra-a-ressaltar (sprite minusculo a saltar na agua com CPUParticles2D).
- **Notas:** "recorde" aumenta com dias; ORGULHO +15

### E14 - Olhar para as estrelas e inventar constelacoees
- **Necessidade:** DIVERSAO (+20pts), ESPERANCA (+15pts)
- **Raridade:** RARO (noite limpa)
- **Godot:** AnimationPlayer (deitar, apontar estrelas), CPUParticles2D linhas entre estrelas, som `stars_wonder.ogg`
- **Sprites:** Novos: `lie_stargaze` (deitado de costas na areia, um braco levantado a apontar, 2 frames lento). REUTILIZA NightSky existente. CPUParticles2D: linhas que ligam estrelas no ceu conforme aponta.
- **Notas:** gera frases LLM com nomes de constelacoees inventadas; TEDIO -20

### E15 - Fazer obra de arte na areia
- **Necessidade:** DIVERSAO (+25pts), ORGULHO (+20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (ajoelhar, desenhar com pau), sprite obra na areia, CPUParticles2D arte
- **Sprites:** REUTILIZA `write_floor` (A14). Novos: `art_admire` (levantar, recuar 2 passos, inclinar cabeca, expressao critico de arte, 3 frames). Prop: sprite arte-na-areia (5 designs diferentes: rosto, barco, casa, arvore, sol).
- **Notas:** ESPERANCA +5; onda apaga eventualmente

---

## Secao 6 - ESPIRITUAL (10 accoes)

### F01 - Rezar de manha
- **Necessidade:** ESPERANCA (+15pts), SOLIDAO (-10pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (ajoelhar, juntar maos, cabeca baixa), emote luz suave, som `prayer_ambient.ogg`
- **Sprites:** Novos: `pray_kneel` (de joelhos, maos juntas, cabeca inclinada, 3 frames muito lentos com "respiracao"). Efeito: glow suave em volta das maos. A pose mais serena do personagem.
- **Notas:** CONFORTO +10; multi-religioso; pode ser ritual laico

### F02 - Dar gracias pela refeicao
- **Necessidade:** ESPERANCA (+5pts)
- **Raridade:** ROTINA
- **Godot:** AnimationPlayer (pausa antes de comer, olhar para cima brevemente), som `gratitude_hum.ogg`
- **Sprites:** Novos: `look_up_brief` (cabeca a levantar ligeiramente, expressao de agradecimento, 2 frames). Overlay sobre animacao de comer existente. Muito curto - apenas 0.5s de duracao.
- **Notas:** overlay sobre `eat_chew`; subtil mas consistente; CONFORTO +5

### F03 - Fazer ritual de madrugada
- **Necessidade:** ESPERANCA (+20pts), SOLIDAO (-15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (acordar de madrugada, ir a beira mar, ritual proprio), estrelas brilham, som `ritual_chime.ogg`
- **Sprites:** Novos: `ritual_arms` (bracos levantados para o ceu numa pose ritual propria, 4 frames com movimento lento). REUTILIZA NightSky. Efeito: estrelas mais brilhantes (shader).
- **Notas:** so 2h-5h de jogo; gera LLM para o ritual especifico

### F04 - Rezar pelo resgate
- **Necessidade:** ESPERANCA (+20pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (rezar intensamente, olhar para o ceu), som `prayer_desperate.ogg`, CPUParticles2D luz
- **Sprites:** REUTILIZA `pray_kneel` (F01) mas com animacao mais intensa/urgente (maior velocidade, maos mais juntas). Novos: `pray_desperate` (versao urgente de `pray_kneel`, 4 frames mais rapidos). CPUParticles2D: luz dourada a subir.
- **Notas:** SOLIDAO -15; frase especifica sobre querer ir para casa

### F05 - Fazer ritual de protecao contra tempestade
- **Necessidade:** ESPERANCA (+15pts), FRIO (-10pts)
- **Raridade:** RARO (condicional tempestade)
- **Godot:** AnimationPlayer (circular maos, murmurar, virar costas a tempestade), CPUParticles2D tempestade
- **Sprites:** Novos: `ward_off` (maos em gesto de afastar, voltado para o lado, expressao concentrada, 5 frames). REUTILIZA CPUParticles2D chuva/tempestade existente. Sempre falha mas ESPERANCA sobe.
- **Notas:** gatilho WeatherService=storm

### F06 - Criar altar de pedras e conchas
- **Necessidade:** ESPERANCA (+25pts), SOLIDAO (-15pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (construir altar), sprite altar permanente, som `stone_place.ogg`, luz nocturna
- **Sprites:** REUTILIZA `stack_crouch` (A15). Novos: `reverence_bow` (inclinar-se ligeiramente para o altar com respeito, 3 frames). Prop: sprite altar-pedras-conchas (1 sprite detalhado permanente no ecra).
- **Notas:** ORGULHO +25; referencia ao altar diariamente

### F07 - Meditar profundamente
- **Necessidade:** ENERGIA (+20pts), SOLIDAO (-20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (sentado, imavel, aura), som `deep_breath.ogg` loop, CPUParticles2D aura
- **Sprites:** Novos: `meditate_lotus` (sentado de pernas cruzadas, costas direitas, maos nos joelhos, olhos fechados, 2 frames "respiracao" - quase imavel). CPUParticles2D: aura suave colorida a circular. A pose mais estavel do jogo.
- **Notas:** dura 60s de jogo; CONFORTO +20

### F08 - Falar com o mar como entidade
- **Necessidade:** SOLIDAO (-20pts), ESPERANCA (+10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (andar ate beira, falar, ouvir), CPUParticles2D resposta ondas, som `wave_response.ogg`
- **Sprites:** Novos: `speak_to_sea` (de pe na beira da agua, maos abertas para o oceano, expressao de quem faz uma pergunta importante, 4 frames). CPUParticles2D: ondas "respondem" (spray dirigido).
- **Notas:** gera frase LLM poetica; o mar "responde"

### F09 - Cantar para o sol que nasce
- **Necessidade:** ESPERANCA (+20pts), DIVERSAO (+15pts)
- **Raridade:** RARO (so ao nascer do sol)
- **Godot:** AnimationPlayer (virar para este, bracos abertos, cantar), CPUParticles2D luz aurora, som `morning_song.ogg`
- **Sprites:** Novos: `arms_open_sky` (de pe, bracos bem abertos para o sol, cabeca ligeiramente para cima, expressao de abertura total, 3 frames lentos). Efeito: luz aurora no fundo (CPUParticles2D ou shader de gradiente).
- **Notas:** janela 5h-7h de jogo; o melhor inicio de dia

### F10 - Fazer paz com a propria situacao
- **Necessidade:** ESPERANCA (+30pts), SOLIDAO (-25pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (parar tudo, respirar fundo, assentir), efeito luz suave, som `acceptance.ogg`
- **Sprites:** Novos: `breath_deep` (de pe, fechar olhos, inspirar fundo com o peito a subir, expirar devagar, 5 frames - o mais lento de todos). Efeito: luz suave em TODA a cena (nao so no personagem). Gera frase LLM profunda.
- **Notas:** o maior boost positivo disponivel; CONFORTO +25

---

## Secao 7 - SOCIAL (8 accoes)

### G01 - Falar com o companheiro imaginario
- **Necessidade:** SOLIDAO (-25pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (virar para companheiro, falar, ouvir), som `conversation_mutter.ogg`
- **Sprites:** REUTILIZA `storytell_gesture` (E04) para falar. Novos: `listen_companion` (virar a cabeca ligeiramente, expressao de ouvir com atencao, 2 frames). Sprite companheiro: vibrar levemente quando "fala". 4 variantes: contar novidades, pedir conselho, brigar, reconciliar.
- **Notas:** expandir com sub-tipos de conversa

### G02 - Apresentar o companheiro ao sol
- **Necessidade:** SOLIDAO (-10pts), DIVERSAO (+10pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (pegar companheiro, levantar para o ceu, falar), som `introduction_fanfare.ogg`
- **Sprites:** Novos: `lift_present` (levantar objecto acima da cabeca com expressao cerimoniosa, 3 frames - estilo "Simba no Lion King"). A pose mais absurda e encantadora do jogo.
- **Notas:** cerimonia absurda; TEDIO -15

### G03 - Discutir com o companheiro
- **Necessidade:** SOLIDAO (-10pts), TEDIO (-20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (gesticular, apontar, virar costas), emote exclamacao, som `argue_mutter.ogg`
- **Sprites:** Novos: `argue_point` (dedo apontado para o companheiro, expressao indignada, 4 frames), `turn_away` (virar costas dramaticamente, bracos cruzados, 2 frames). REUTILIZA `arms_cross_denial` (C13).
- **Notas:** reconciliacao apos 60s; DIVERSAO +15 depois

### G04 - Acenar para gaivota
- **Necessidade:** SOLIDAO (-10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (acenar entusiasmado), gaivota existente reage, som `wave_hello.ogg`
- **Sprites:** Novos: `wave_big` (acenar com o braco inteiro acima da cabeca, expressao entusiasmada, 4 frames). REUTILIZA sprite gaivota existente (F3). A gaivota pode ignorar ou reagir.
- **Notas:** liga ao sistema de gaivota existente

### G05 - Tentar comunicar com barco distante
- **Necessidade:** ESPERANCA (+20pts), SOLIDAO (-15pts)
- **Raridade:** RARO (condicional barco presente)
- **Godot:** AnimationPlayer (acenar freneticamente, saltar, gritar), CPUParticles2D desespero, som `shout_help.ogg`
- **Sprites:** Novos: `wave_frantic` (acenar com AMBOS os bracos freneticamente, saltos, expressao desespero, 6 frames rapidos). REUTILIZA sprite barco existente (F3). CPUParticles2D: ondas de som saindo da boca.
- **Notas:** barco passa sempre sem parar; ESPERANCA cai depois

### G06 - Contar as novidades ao companheiro
- **Necessidade:** SOLIDAO (-20pts), TEDIO (-10pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (sentar ao lado do companheiro, gesticular), som `storytelling_short.ogg`
- **Sprites:** REUTILIZA `storytell_gesture` (E04). Novos: `sit_companion_side` (sentar ao lado do companheiro, levemente virado para ele, 2 frames). As "novidades" sao que nao aconteceu nada - e o humor.
- **Notas:** gera frase LLM das "novidades do dia"

### G07 - Fazer foto imaginaria com o companheiro
- **Necessidade:** DIVERSAO (+20pts), SOLIDAO (-20pts)
- **Raridade:** RARO
- **Godot:** AnimationPlayer (aproximar companheiro, sorrir, click imaginario), flash branco, som `camera_click.ogg`
- **Sprites:** Novos: `selfie_pose` (pose de selfie - inclinado para o lado, sorriso forcado de foto, 2 frames). Flash branco: shader que pisco o ecra todo por 0.2s. Prop: sprite camera-imaginaria na mao (apenas visivel por 1s).
- **Notas:** ORGULHO +10; TEDIO -20

### G08 - Monologar para a propria sombra
- **Necessidade:** SOLIDAO (-15pts), TEDIO (-15pts)
- **Raridade:** OCASIONAL
- **Godot:** AnimationPlayer (olhar sombra, falar com ela, ela "responde"), efeito sombra anima, som `shadow_talk.ogg`
- **Sprites:** REUTILIZA `speak_to_sea` (F08) adaptado para olhar para baixo. Novos: `look_down_talk` (olhar para o chao/sombra, falar com gestos para baixo, 4 frames). Efeito: sombra tem animacao ligeiramente diferente do personagem.
- **Notas:** so com sol (sombra visivel); DIVERSAO +15

---

## Novas Necessidades Propostas

> **Lembrete:** em nenhuma destas necessidades "crise" significa morte ou fim de jogo.
> Crise = comportamento mais expressivo e dramatico. O naufrago resolve e continua eternamente.

### SEDE (FISICA - PRIORITARIA)
- **Range:** 0-100 | **Neutro:** 40 | **Taxa base:** +1.5/s calor, +0.5/s normal
- **Urgencia >= 75:** boceja, move-se com esforco, reclama em voz alta da secura
- **Pico = 100:** alucinacoes comicas (ve fontes, piscinas, lagos imaginarios), persegue-as. ESPERANCA sobe paradoxalmente ("vi agua!"). Resolve-se assim que bebe qualquer coisa. **NAO morre.**

### HIGIENE (FISICA - PRIORITARIA)
- **Range:** 0-100 | **Neutro:** 60 | **Taxa base:** -0.3/s passivo, -2/s actividades sujas
- **Urgencia <= 20:** expressao nojenta consigo proprio, olha para as maos com horror, SOLIDAO sobe (ate o companheiro imaginario se afasta dramaticamente)
- **Pico = 0:** evento "auto-rejeicao comica" -- ele proprio se afasta de si mesmo em circulos. Resolve-se com banho. **NAO morre.**

### CALOR / FRIO (FISICA - IMPORTANTE)
- **CALOR sobe:** sol directo, actividade fisica, verao | **Desce:** sombra, banho, brisa
- **FRIO sobe:** noite, chuva, tempestade, inverno | **Desce:** fogueira, abrigo, exercicio
- **Pico CALOR:** deita-se imavel na sombra com expressao de "nao consigo mais". Recupera sozinho na sombra. **NAO morre.**
- **Pico FRIO:** tremores exagerados, dentes a bater audivelmente, corre para a fogueira. **NAO morre.**

### CONFORTO (PSICOLOGICA - MEDIA)
- **Sobe:** dormir bem, banho, alongamentos | **Desce:** dormir na areia, espinhos, frio
- **Pico baixo:** manca ao andar, expressao de dor cronica, mas continua todas as actividades. **NAO morre.**

### ORGULHO (PSICOLOGICA - MEDIA)
- **Sobe:** construir, pesca bem sucedida, superar record | **Desce:** falhas acumuladas
- **Pico baixo:** recusa iniciar actividades por propria vontade (fica parado), precisa de trigger externo (evento, gaivota, barco). Nunca e permanente. **NAO morre.**

### MOVIMENTO (FISICA - BAIXA)
- **Sobe:** inactividade longa | **Desce:** correr, nadar, saltar, dancar
- **Pico alto:** nao consegue ficar parado, anda em circulos acelerados, eventualmente corre ou salta para a agua. E comico, nao perigoso. **NAO morre.**

---

## Prioridade de Implementacao

As 20 accoes mais impactantes, ordenadas por impacto/custo de sprites:

| # | ID | Nome | Sprites novos | Motivo |
|---|---|---|---|---|
| 1 | B03 | Fazer xixi atras da palmeira | 2 frames | Humaniza imediatamente; trivial |
| 2 | D01 | Correr pela praia | 6 frames | Visual dinamico; resolve MOVIMENTO |
| 3 | A03 | Beber agua de coco | 7 frames + 2 props | Introduz SEDE; rotina natural |
| 4 | B01 | Tomar banho no mar | 11 frames | Introduz HIGIENE; visual apelativo |
| 5 | E01 | Cantar em voz alta | 6 frames | Sons + emocao; muito caracter |
| 6 | C02 | Xingar o oceano | 4 frames | Humor; TEDIO; muito Stardew Valley |
| 7 | D02 | Nadar livremente | 6 frames | Animacao horizontal unica; varios efeitos |
| 8 | C15 | Sentir calor ao meio-dia | 8 frames + shader | Introduce CALOR; reaccao ao clima |
| 9 | C14 | Sentir frio na noite | 4 frames + shader | Introduce FRIO; fogueira mais importante |
| 10 | E02 | Assobiar uma melodia | 4 frames overlay | Sons; overlay sobre walk; trivial |
| 11 | F01 | Rezar de manha | 3 frames | Rotina expressiva; muito caracter |
| 12 | D06 | Alongamentos matinais | 8 frames sequencia | Rotina acordar; ENERGIA; CONFORTO |
| 13 | C01 | Chorar de saudade | 4 frames + CPUParticles | Cena mais emocional; unica |
| 14 | C17 | Momento de paz absoluta | 3 frames + shader | Culminacao emocional; impacto maximo |
| 15 | E10 | Construir castelo de areia | 5 frames + 4 props | Visual memoravel; TEDIO e DIVERSAO |
| 16 | D07 | Dancar sozinho na praia | 14 frames (2 estilos) | O mais divertido visualmente |
| 17 | C07 | Ataque de angustia | 6 frames | Tensao dramatica; cena importante |
| 18 | G02 | Apresentar companheiro ao sol | 3 frames | Iconica; absurda; memoravel |
| 19 | D03 | Saltar de arvore para o mar | 15 frames | Espetacular; requer palmeira (F7) |
| 20 | F10 | Fazer paz com a situacao | 5 frames + shader | Maior boost positivo; cena final |

---

## Sons CC0 Necessarios

### Sons de Agua e Mar
- `splash_bathing.ogg` - splash de entrar na agua (banho)
- `big_splash.ogg` - splash grande (salto da arvore)
- `swimming.ogg` - nadar (loop suave)
- `water_hands.ogg` - lavar as maos
- `underwater_bubbles.ogg` - mergulho
- `rain_collect.ogg` - apanhar agua da chuva
- `water_drip_small.ogg` - gotas de orvalho
- `water_dripping.ogg` - destilar agua

### Sons de Corpo e Higiene
- `relieve.ogg` - alivio biologico (discreto)
- `brushing.ogg` - limpar dentes
- `hair_comb.ogg` - pentear
- `stretch_pop.ogg` - alongamentos (estalo suave)
- `shake_head.ogg` - sacudir areia

### Sons Fisicos e Esforco
- `effort_grunt.ogg` - flexoes / esforco fisico
- `running_sand.ogg` - correr na areia (passos)
- `ouch.ogg` - dor (espinho)
- `ouch_small.ogg` - dor leve

### Sons Emocionais e Vocais
- `crying_soft.ogg` - choro suave
- `laughter.ogg` - gargalhada sozinho
- `shout_frustrated.ogg` - xingar
- `singing_humming.ogg` - cantarolar
- `whistling.ogg` - assobiar (loop curto)
- `humming_work.ogg` - cantarolar enquanto trabalha
- `humming_nostalgic.ogg` - cantarolar com saudade
- `humming_dance.ogg` - cantar a dancar
- `morning_song.ogg` - cantar ao nascer do sol
- `beatbox.ogg` - beatbox improvisado
- `laughter_soft.ogg` - riso suave

### Sons de Construcao e Objectos
- `coconut_crack.ogg` - partir coco
- `coconut_fall.ogg` - coco a cair
- `stone_stack.ogg` - empilhar pedras
- `stone_place.ogg` - colocar pedra
- `stone_clink.ogg` - pedras a bater
- `stone_throw.ogg` - atirar pedra
- `splash_skip.ogg` - pedra a ressaltar na agua
- `stick_collect.ogg` - apanhar ramos
- `leaves_rustle.ogg` - folhas a rusgar
- `sand_write.ogg` - escrever na areia
- `sand_sculpt.ogg` - esculpir na areia

### Sons Espirituais e Ambientes
- `prayer_ambient.ogg` - oracao suave
- `prayer_desperate.ogg` - oracao urgente
- `chant_protective.ogg` - canto ritual
- `ritual_chime.ogg` - sino ritual
- `acceptance.ogg` - suspiro de aceitacao
- `deep_breath.ogg` - respiracao profunda (loop)
- `peace_ambient.ogg` - silencio com vida (loop suave)
- `insight_chime.ogg` - momento de clareza

### Sons Sociais
- `wave_hello.ogg` - acenar (suave)
- `shout_help.ogg` - gritar por socorro
- `conversation_mutter.ogg` - murmuro de conversa
- `argue_mutter.ogg` - murmuro de discussao
- `storytelling.ogg` - narrar historia
- `storytelling_short.ogg` - contar novidade
- `introduction_fanfare.ogg` - apresentacao formal (comico)
- `shadow_talk.ogg` - murmuro introspectivo
- `camera_click.ogg` - click de camera imaginaria

### Sons de Animais
- `crab_scuttle.ogg` - caranguejo a andar
- `seagull_imitate.ogg` - imitar gaivota (comico)
- `seaweed_collect.ogg` - apanhar algas
- `wave_response.ogg` - onda "a responder" (ambiente)

---

## Sprites e Animacoes por Accao

Tabela completa de todos os sprites novos necessarios para Fase 6 (upscale + novos) e Fase 7 (redesenho).
Sprite base actual: 16x24px -> F6: 64x96px (nearest-neighbour). F7: redesenho a ~32x48px original.

### Animacoes do Naufrago (corpo inteiro)

| ID Sprite | Nome | Frames | Dimensao F6 | Dimensao F7 | Usado em | Notas |
|---|---|---|---|---|---|---|
| ANIM-01 | `walk` | 4 | 64x96 | 128x192 | D08, multiplas | ja existe; upscale F6 |
| ANIM-02 | `idle_stand` | 2 | 64x96 | 128x192 | base | ja existe; upscale F6 |
| ANIM-03 | `fish_cast` | 3 | 64x96 | 128x192 | A01 | ja existe; upscale F6 |
| ANIM-04 | `fish_wait` | 2 | 64x96 | 128x192 | A01 | ja existe; upscale F6 |
| ANIM-05 | `sleep` | 2 | 64x96 | 128x192 | base | ja existe; upscale F6 |
| ANIM-06 | `fish_bite` | 3 | 64x96 | 128x192 | A01 | NOVO F6 |
| ANIM-07 | `fish_reel` | 4 | 64x96 | 128x192 | A01 | NOVO F6 |
| ANIM-08 | `fish_caught` | 2 | 64x96 | 128x192 | A01 | NOVO F6 |
| ANIM-09 | `fish_lost` | 2 | 64x96 | 128x192 | A01 | NOVO F6 |
| ANIM-10 | `eat_sit` | 2 | 64x96 | 128x192 | A02, A06 | NOVO F6 |
| ANIM-11 | `eat_chew` | 4 | 64x96 | 128x192 | A02, A03, A21 | NOVO F6; ciclico |
| ANIM-12 | `eat_done` | 2 | 64x96 | 128x192 | A02 | NOVO F6 |
| ANIM-13 | `coconut_crack` | 4 | 64x96 | 128x192 | A03, A04 | NOVO F6 |
| ANIM-14 | `coconut_drink` | 3 | 64x96 | 128x192 | A03, A20 | NOVO F6 |
| ANIM-15 | `shake_tree` | 4 | 64x96 | 128x192 | A04 | NOVO F6 |
| ANIM-16 | `pick_up` | 3 | 64x96 | 128x192 | A04, A06, A10 | NOVO F6; muito reutilizavel |
| ANIM-17 | `crouch_tend` | 2 | 64x96 | 128x192 | A05, A21, E09 | NOVO F6; ciclico |
| ANIM-18 | `wait_patient` | 3 | 64x96 | 128x192 | A05 | NOVO F6 |
| ANIM-19 | `eat_disgusted` | 4 | 64x96 | 128x192 | A06, A07 | NOVO F6 |
| ANIM-20 | `hesitate` | 4 | 64x96 | 128x192 | A07, A18 | NOVO F6; muito reutilizavel |
| ANIM-21 | `mouth_open_sky` | 2 | 64x96 | 128x192 | A08 | NOVO F6 |
| ANIM-22 | `run_urgency` | 6 | 64x96 | 128x192 | A08 | NOVO F6; variante run |
| ANIM-23 | `rub_sticks` | 4 | 64x96 | 128x192 | A09 | NOVO F6; ciclico |
| ANIM-24 | `blow_fire` | 3 | 64x96 | 128x192 | A09 | NOVO F6 |
| ANIM-25 | `fire_success` | 3 | 64x96 | 128x192 | A09 | NOVO F6 |
| ANIM-26 | `build_overhead` | 4 | 64x96 | 128x192 | A11, A12 | NOVO F6 |
| ANIM-27 | `build_inspect` | 3 | 64x96 | 128x192 | A11, A15, E10 | NOVO F6 |
| ANIM-28 | `arrange_floor` | 4 | 64x96 | 128x192 | A13, A22 | NOVO F6 |
| ANIM-29 | `write_floor` | 4 | 64x96 | 128x192 | A14, E15 | NOVO F6; ciclico |
| ANIM-30 | `stack_crouch` | 5 | 64x96 | 128x192 | A15, F06 | NOVO F6 |
| ANIM-31 | `craft_small` | 5 | 64x96 | 128x192 | A16 | NOVO F6; muito reutilizavel |
| ANIM-32 | `lunge_grab` | 3 | 64x96 | 128x192 | A17 | NOVO F6; rapido |
| ANIM-33 | `hang_object` | 3 | 64x96 | 128x192 | A19 | NOVO F6 |
| ANIM-34 | `wade_enter` | 4 | 64x96 | 128x192 | B01, D02 | NOVO F6; sprite agua especial |
| ANIM-35 | `bathe_scrub` | 4 | 64x96 | 128x192 | B01 | NOVO F6; ciclico; na agua |
| ANIM-36 | `wade_exit` | 3 | 64x96 | 128x192 | B01, D02 | NOVO F6 |
| ANIM-37 | `wash_kneel` | 4 | 64x96 | 128x192 | B02 | NOVO F6 |
| ANIM-38 | `look_around_guilty` | 3 | 64x96 | 128x192 | B03, B04 | NOVO F6 |
| ANIM-39 | `relief_exit` | 2 | 64x96 | 128x192 | B03, B04 | NOVO F6 |
| ANIM-40 | `wash_hands` | 3 | 64x96 | 128x192 | B05 | NOVO F6 |
| ANIM-41 | `brush_teeth` | 3 | 64x96 | 128x192 | B06 | NOVO F6; ciclico |
| ANIM-42 | `examine_smile` | 2 | 64x96 | 128x192 | B06 | NOVO F6 |
| ANIM-43 | `comb_hair` | 3 | 64x96 | 128x192 | B07 | NOVO F6 |
| ANIM-44 | `tilt_shake` | 3 | 64x96 | 128x192 | B08 | NOVO F6 |
| ANIM-45 | `sit_foot_examine` | 3 | 64x96 | 128x192 | B09 | NOVO F6 |
| ANIM-46 | `pull_thorn` | 2 | 64x96 | 128x192 | B09 | NOVO F6 |
| ANIM-47 | `arms_out_sun` | 2 | 64x96 | 128x192 | B10 | NOVO F6 |
| ANIM-48 | `examine_arm` | 3 | 64x96 | 128x192 | B11 | NOVO F6 |
| ANIM-49 | `blow_on_wound` | 2 | 64x96 | 128x192 | B11 | NOVO F6 |
| ANIM-50 | `apply_face` | 3 | 64x96 | 128x192 | B12 | NOVO F6 |
| ANIM-51 | `cry_sit` | 4 | 64x96 | 128x192 | C01 | NOVO F6; ciclico; muito expressivo |
| ANIM-52 | `shout_fist` | 4 | 64x96 | 128x192 | C02 | NOVO F6 |
| ANIM-53 | `shame_look` | 2 | 64x96 | 128x192 | C02 | NOVO F6 |
| ANIM-54 | `laugh_belly` | 5 | 64x96 | 128x192 | C03 | NOVO F6 |
| ANIM-55 | `yawn` | 4 | 64x96 | 128x192 | C04 | NOVO F6 |
| ANIM-56 | `inspect_nails` | 2 | 64x96 | 128x192 | C04 | NOVO F6 |
| ANIM-57 | `sit_swing_feet` | 4 | 64x96 | 128x192 | C04, multiplas | NOVO F6; ciclico; muito reutilizavel |
| ANIM-58 | `look_up_smile` | 2 | 64x96 | 128x192 | C05, F09 | NOVO F6 |
| ANIM-59 | `jump_joy` | 4 | 64x96 | 128x192 | C06 | NOVO F6 |
| ANIM-60 | `hug_knees_rock` | 6 | 64x96 | 128x192 | C07 | NOVO F6; ciclico; muito expressivo |
| ANIM-61 | `skip_walk` | 6 | 64x96 | 128x192 | C08 | NOVO F6; variante walk feliz |
| ANIM-62 | `sit_memory` | 3 | 64x96 | 128x192 | C09 | NOVO F6; muito lento |
| ANIM-63 | `nod_slow` | 3 | 64x96 | 128x192 | C10 | NOVO F6 |
| ANIM-64 | `hands_hips_proud` | 2 | 64x96 | 128x192 | C11, multiplas | NOVO F6 |
| ANIM-65 | `daydream_drool` | 4 | 64x96 | 128x192 | C12 | NOVO F6; comico |
| ANIM-66 | `arms_cross_denial` | 4 | 64x96 | 128x192 | C13, G03 | NOVO F6 |
| ANIM-67 | `hug_self_shiver` | 4 | 64x96 | 128x192 | C14 | NOVO F6; ciclico; frio |
| ANIM-68 | `fan_self` | 4 | 64x96 | 128x192 | C15 | NOVO F6; ciclico |
| ANIM-69 | `walk_exhausted` | 4 | 64x96 | 128x192 | C15 | NOVO F6; variante walk lenta |
| ANIM-70 | `sway_memory` | 4 | 64x96 | 128x192 | C16 | NOVO F6 |
| ANIM-71 | `sit_peace` | 3 | 64x96 | 128x192 | C17, F07 | NOVO F6; muito lento |
| ANIM-72 | `run` | 6 | 64x96 | 128x192 | D01, D11 | NOVO F6; muito diferente de walk |
| ANIM-73 | `swim_stroke` | 4 | 64x96 | 128x192 | D02 | NOVO F6; horizontal - unico |
| ANIM-74 | `swim_float` | 2 | 64x96 | 128x192 | D02 | NOVO F6 |
| ANIM-75 | `climb_tree` | 6 | 64x96 | 128x192 | D03, D10 | NOVO F7 (requer palmeira F7) |
| ANIM-76 | `perch_top` | 2 | 64x96 | 128x192 | D03, D10 | NOVO F7 |
| ANIM-77 | `jump_arc` | 4 | 64x96 | 128x192 | D03 | NOVO F7; corpo em arco |
| ANIM-78 | `surface_swim` | 2 | 64x96 | 128x192 | D03, D09 | NOVO F7 |
| ANIM-79 | `pushup` | 4 | 64x96 | 128x192 | D04 | NOVO F6; deitado |
| ANIM-80 | `pushup_done` | 2 | 64x96 | 128x192 | D04, D05 | NOVO F6 |
| ANIM-81 | `situp` | 3 | 64x96 | 128x192 | D05 | NOVO F6; deitado |
| ANIM-82 | `stretch_arms` | 3 | 64x96 | 128x192 | D06 | NOVO F6 |
| ANIM-83 | `stretch_bend` | 3 | 64x96 | 128x192 | D06 | NOVO F6 |
| ANIM-84 | `neck_roll` | 2 | 64x96 | 128x192 | D06 | NOVO F6 |
| ANIM-85 | `dance_happy` | 8 | 64x96 | 128x192 | D07 | NOVO F7; animacao longa |
| ANIM-86 | `dance_sad` | 6 | 64x96 | 128x192 | D07 | NOVO F7; animacao longa |
| ANIM-87 | `idle_look_around` | 4 | 64x96 | 128x192 | D08 | NOVO F6 |
| ANIM-88 | `dive_under` | 3 | 64x96 | 128x192 | D09 | NOVO F6 |
| ANIM-89 | `emerge_prize` | 3 | 64x96 | 128x192 | D09 | NOVO F6 |
| ANIM-90 | `top_survey` | 2 | 64x96 | 128x192 | D10 | NOVO F7 |
| ANIM-91 | `hurdle_jump` | 4 | 64x96 | 128x192 | D11 | NOVO F7 |
| ANIM-92 | `crawl` | 4 | 64x96 | 128x192 | D11 | NOVO F7 |
| ANIM-93 | `celebrate_finish` | 3 | 64x96 | 128x192 | D11 | NOVO F6 |
| ANIM-94 | `sing_conduct` | 6 | 64x96 | 128x192 | E01, E12 | NOVO F6 |
| ANIM-95 | `whistle_walk` | 4 | 64x96 | 128x192 | E02 | NOVO F6; overlay |
| ANIM-96 | `storytell_gesture` | 6 | 64x96 | 128x192 | E04, G01, G06 | NOVO F6 |
| ANIM-97 | `play_floor` | 4 | 64x96 | 128x192 | E05 | NOVO F6 |
| ANIM-98 | `shadow_puppet` | 6 | 64x96 | 128x192 | E06 | NOVO F7 |
| ANIM-99 | `throw_overhand` | 4 | 64x96 | 128x192 | E07, E13 | NOVO F6 |
| ANIM-100 | `read_book` | 4 | 64x96 | 128x192 | E08 | NOVO F6; segurar nada |
| ANIM-101 | `follow_crouch` | 4 | 64x96 | 128x192 | E09 | NOVO F6; comico |
| ANIM-102 | `sculpt_kneel` | 5 | 64x96 | 128x192 | E10 | NOVO F6 |
| ANIM-103 | `imitate_bird` | 4 | 64x96 | 128x192 | E11 | NOVO F6 |
| ANIM-104 | `imitate_fish` | 3 | 64x96 | 128x192 | E11 | NOVO F6 |
| ANIM-105 | `beatbox_face` | 5 | 64x96 | 128x192 | E12 | NOVO F6; muito exagerado |
| ANIM-106 | `commentate` | 3 | 64x96 | 128x192 | E13 | NOVO F6 |
| ANIM-107 | `lie_stargaze` | 2 | 64x96 | 128x192 | E14 | NOVO F6; deitado a apontar |
| ANIM-108 | `art_admire` | 3 | 64x96 | 128x192 | E15 | NOVO F6 |
| ANIM-109 | `pray_kneel` | 3 | 64x96 | 128x192 | F01, F04 | NOVO F6 |
| ANIM-110 | `look_up_brief` | 2 | 64x96 | 128x192 | F02 | NOVO F6 |
| ANIM-111 | `ritual_arms` | 4 | 64x96 | 128x192 | F03 | NOVO F7 |
| ANIM-112 | `pray_desperate` | 4 | 64x96 | 128x192 | F04 | NOVO F6 |
| ANIM-113 | `ward_off` | 5 | 64x96 | 128x192 | F05 | NOVO F6 |
| ANIM-114 | `reverence_bow` | 3 | 64x96 | 128x192 | F06 | NOVO F6 |
| ANIM-115 | `meditate_lotus` | 2 | 64x96 | 128x192 | F07 | NOVO F6 |
| ANIM-116 | `speak_to_sea` | 4 | 64x96 | 128x192 | F08, G08 | NOVO F6 |
| ANIM-117 | `arms_open_sky` | 3 | 64x96 | 128x192 | F09 | NOVO F6 |
| ANIM-118 | `breath_deep` | 5 | 64x96 | 128x192 | F10 | NOVO F7; o mais lento |
| ANIM-119 | `listen_companion` | 2 | 64x96 | 128x192 | G01 | NOVO F6 |
| ANIM-120 | `lift_present` | 3 | 64x96 | 128x192 | G02 | NOVO F7; estilo Simba |
| ANIM-121 | `argue_point` | 4 | 64x96 | 128x192 | G03 | NOVO F6 |
| ANIM-122 | `turn_away` | 2 | 64x96 | 128x192 | G03 | NOVO F6 |
| ANIM-123 | `wave_big` | 4 | 64x96 | 128x192 | G04 | NOVO F6 |
| ANIM-124 | `wave_frantic` | 6 | 64x96 | 128x192 | G05 | NOVO F6 |
| ANIM-125 | `sit_companion_side` | 2 | 64x96 | 128x192 | G06 | NOVO F6 |
| ANIM-126 | `selfie_pose` | 2 | 64x96 | 128x192 | G07 | NOVO F6 |
| ANIM-127 | `look_down_talk` | 4 | 64x96 | 128x192 | G08 | NOVO F6 |

### Props e Sprites de Cenario

| ID Prop | Nome | Frames | Usado em | Fase | Notas |
|---|---|---|---|---|---|
| PROP-01 | `cana_pesca` | 1 | A01 | F6 | estatico, na mao |
| PROP-02 | `coco_fechado` | 1 | A03, A04 | F6 | estatico |
| PROP-03 | `coco_aberto` | 1 | A03, A21 | F6 | estatico |
| PROP-04 | `coco_a_cair` | 3 | A04 | F6 | queda animada |
| PROP-05 | `coco_assado` | 1 | A21 | F6 | variante castanho |
| PROP-06 | `alga` | 1 | A06 | F6 | flutuante na beira |
| PROP-07 | `lula` | 1 | A07 | F6 | estatico |
| PROP-08 | `fruta_desconhecida` | 1 | A18 | F6 | cor ambigua |
| PROP-09 | `peixe_pendurado` | 1 | A19 | F6 | na palmeira |
| PROP-10 | `folha_calha` | 1 | A20 | F6 | dobrada para calha |
| PROP-11 | `concha_pente` | 1 | B07 | F6 | na mao |
| PROP-12 | `ramo_escova` | 1 | B06 | F6 | na mao |
| PROP-13 | `overlay_lama_rosto` | 1 | B12 | F6 | overlay sobre sprite |
| PROP-14 | `overlay_suor` | 1 | C15 | F6 | gotas no sprite |
| PROP-15 | `abrigo_folhas_build` | 1 | A11 | F6 | 3 estados |
| PROP-16 | `abrigo_folhas_done` | 1 | A11 | F6 | completo |
| PROP-17 | `abrigo_folhas_broken` | 1 | A12 | F6 | danificado |
| PROP-18 | `cama_folhas` | 2 | A13 | F6 | a fazer / completa |
| PROP-19 | `texto_socorro` | 5 | A14 | F6 | 5 idiomas |
| PROP-20 | `sinaleiro_pedras` | 4 | A15 | F6 | 4 alturas |
| PROP-21 | `anzol_osso` | 1 | A16 | F6 | inventario |
| PROP-22 | `caranguejo` | 6 | A17, E09 | F6 | idle 2 + walk 4 |
| PROP-23 | `armadilha_agua` | 3 | A22 | F6 | vazia/encher/cheia |
| PROP-24 | `lenha_hud` | 3 | A10 | F6 | 3 estados UI |
| PROP-25 | `roupa_secando` | 2 | B02 | F6 | na palmeira, vento |
| PROP-26 | `castelo_areia` | 4 | E10 | F6 | 4 estados progressivos |
| PROP-27 | `arte_areia` | 5 | E15 | F6 | 5 designs diferentes |
| PROP-28 | `altar_pedras_conchas` | 1 | F06 | F7 | detalhado, permanente |
| PROP-29 | `nota_musical_overlay` | 2 | E03 | F6 | overlay ciclico |
| PROP-30 | `overlay_espinho_pe` | 1 | B09 | F6 | micro-sprite no pe |
| PROP-31 | `pedra_em_voo` | 3 | E07, E13 | F6 | mini-sprite arco |

### Overlays / Shaders

| ID | Nome | Tipo | Usado em | Fase |
|---|---|---|---|---|
| FX-01 | `shader_frio` | Shader cor azul | C14 | F6 |
| FX-02 | `shader_calor` | Shader heat shimmer | C15 | F6 |
| FX-03 | `shader_brilho_corpo` | Shader glow | B10, C17 | F6 |
| FX-04 | `shader_bronzeado` | Shader cor estacional | F7 (dinamico) | F7 |
| FX-05 | `shader_luz_cena` | Shader fullscreen glow | F10 | F7 |
| FX-06 | `flash_branco` | Shader fullscreen flash | G07 | F6 |

### Resumo por Fase

| Fase | Animacoes | Frames totais | Props novos | Prioridade |
|---|---|---|---|---|
| F6 (upscale + novos) | 127 animacoes | ~490 frames | 31 props + 6 shaders | Fazer primeiro |
| F7 (redesenho) | 127 animacoes redesenhadas | ~490 frames a 128x192 | Todos os props redesenhados | Depois de F6 |

**Nota:** F6 pode comecar com as 20 animacoes da "Prioridade de Implementacao". Estimativa de trabalho: 1 animacao simples (2-3 frames) = 30min de pixel art; 1 animacao complexa (6-8 frames) = 2h. Total estimado F6: ~100-120h de sprite work.

---

## Notas de Implementacao para o Beehave

```gdscript
# Novas necessidades a adicionar em needs_manager.gd
const NEW_NEEDS = {
    "SEDE": {"neutro": 40, "urgencia": 75, "crise": 100, "taxa_base": 1.2},
    "HIGIENE": {"neutro": 60, "urgencia": 20, "crise": 0, "taxa_base": -0.3},
    "CALOR": {"neutro": 40, "urgencia": 70, "crise": 90, "taxa_base": 0.5},
    "FRIO": {"neutro": 20, "urgencia": 65, "crise": 90, "taxa_base": 0.2},
    "CONFORTO": {"neutro": 50, "urgencia": 20, "crise": 0, "taxa_base": -0.2},
    "ORGULHO": {"neutro": 50, "urgencia": 15, "crise": 0, "taxa_base": -0.1},
    "MOVIMENTO": {"neutro": 30, "urgencia": 70, "crise": 100, "taxa_base": 0.4},
}
```

Prioridade sugerida no behavior tree:

```
1  FOME >= 85            -> Pescar (urgente)
2  SEDE >= 80            -> Beber agua (urgente)
3  FRIO >= 75            -> Acender fogueira
4  SOLIDAO = 100         -> Colapso Relacional
5  ESPERANCA = 0         -> Noite Escura
6  TEDIO = 100           -> Grande Plano Inutil
7  HIGIENE <= 15         -> Tomar banho
8  CALOR >= 80           -> Ir para a sombra
9  SEDE >= 65            -> Beber qualquer coisa
10 SOLIDAO >= 75         -> Companheiro
11 MOVIMENTO >= 75       -> Correr / nadar
12 TEDIO >= 70           -> Projecto ambicioso
13 ESPERANCA >= 85       -> Delirio do Resgate
14 FOME >= 60            -> Pescar normal
15 ESPERANCA <= 20       -> Niilismo
16 ORGULHO <= 15         -> Auto-deprecacao
17 TEDIO >= 50           -> Actividade variada
18 SOLIDAO >= 50         -> Monologar
19 default               -> Passear / olhar oceano
```
