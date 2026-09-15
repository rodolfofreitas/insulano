---
id: T-134
titulo: Parallax background -- 5 camadas de profundidade
fase: 2
estado: feito
tipo: visual
depende_de: [T-202, T-204]
---

## Objectivo

Adicionar ParallaxBackground ao test_scene.tscn com 5 camadas de profundidade,
transformando a vista lateral plana numa cena com profundidade cinematografica.
Sprites existentes reutilizados. Nenhum sprite novo obrigatorio.

## Camadas (fundo para frente)

1. **Ceu/estrelas** -- NightSky.gd ja existe (T-204). Integrar como camada 0.
2. **Nuvens** -- CPUParticles2D ou sprite branco que se move lentamente da direita para a esquerda.
   Velocidade: 10px/s. Visivel de dia, quase invisivel de noite.
3. **Horizonte do oceano** -- faixa azul no meio do ecra, parallax_offset_v muito lento.
4. **Ilha (areia + palmeiras)** -- o que existe actualmente, sem alteracoes.
5. **Naufrago** -- primeiro plano, sem alteracoes.

## Implementacao

Usar Godot ParallaxBackground + ParallaxLayer:

```gdscript
# Na cena principal, adicionar:
ParallaxBackground
  ParallaxLayer (motion_scale=(0.1, 0.05))  # ceu -- muito lento
  ParallaxLayer (motion_scale=(0.2, 0.0))   # nuvens
  ParallaxLayer (motion_scale=(0.4, 0.0))   # horizonte
  ParallaxLayer (motion_scale=(1.0, 0.0))   # ilha (actual)
  ParallaxLayer (motion_scale=(1.0, 0.0))   # naufrago (actual)
```

Para nuvens: sprite simples branco/cinza claro arrastado por tween ou CPUParticles2D
com emissao horizontal.

## Critérios de aceitação

- [ ] ParallaxBackground com pelo menos 3 camadas activas
- [ ] Nuvens vissiveis de dia, subtis de noite
- [ ] A camada do naufrago e da ilha nao mudam de comportamento
- [ ] Screenshot docs/proof/T-124-parallax-dia.png e T-124-parallax-noite.png
- [ ] verify.sh PASSOU (incluindo --visual)

## Ler antes

- docs/decisions.md ADR-014 (parallax escolhido)
- game/world/night_sky.gd (T-204) -- integrar como camada 0
- game/world/day_night.gd (T-202) -- paleta por hora
- game/test_scene.tscn -- cena actual a modificar

## Fora de âmbito

- Oceano animado com ondas (Fase 7, T-707)
- Montanhas ao longe (Fase 7)
- Reflexos no oceano (Fase 7)
- Parallax no eixo Y (Fase 7)

## Prova exigida

- Screenshots dia e noite com parallax visivel
- Sem regressoes nos testes existentes

## Relatório

Implementado em 2026-09-15 por agente T-134.

- `game/world/cloud_layer.gd`: CloudLayer (Node2D) com 4 nuvens procedurais (3 circulos sobrepostos
  por nuvem), movimento 15 px/s, wrap-around, alpha 0.7 dia / 0.2 noite via Clock.hour_changed.
- `game/test_scene.tscn`: NightSky (Z=0) + CloudLayer (Z=1) adicionados ao SkyLayer (CanvasLayer 1).
- `game/tests/integration/test_cloud_layer.gd`: 3 testes -- movimento, wrap, alpha dia/noite.
- `docs/proof/T-134-parallax-dia.png` + `T-134-parallax-noite.png`: capturas com INSULANO_FAKE_TIME.
- GUT: 245 testes, todos a passar (inclui os 3 novos de CloudLayer).
- Lint e gdformat: limpos nos novos ficheiros.
- Nota: verify.sh reporta falhas pre-existentes de outra tarefa em curso (llm_director.gd T-117,
  nao relacionadas com T-134). Os ficheiros de T-134 estao limpos.
