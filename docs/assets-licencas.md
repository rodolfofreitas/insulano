# Assets e licenças

Registo obrigatório de tudo o que o Insulano distribui e não é código escrito pelo projecto. Um asset sem
linha aqui, ou com "por confirmar", bloqueia a publicação (T-505). Procedimento: skill `insulano-asset`.

Inventário feito a 2026-09-13 com
`find game -path game/.godot -prune -o -path game/addons -prune -o -type f \( -name '*.png' -o -name '*.svg' \) -print`.

## Arte

| Ficheiro (em `game/`) | Autor | Licenca | Fonte | Obrigacao | Estado |
|---|---|---|---|---|---|
| `events/seagull.gd` (visual desenhado em codigo) | Hermes/agente | CC0 | desenhada em codigo GDScript, sem assets externos (seagull_drawn: 2026-09-15) | nenhuma | confirmado |
| `world/Tiny-Islands-by-Majadroid/tilemap.png`, `tilemap-separated.png` | Maik Hoffmann (Majadroid) | CC0 | [OpenGameArt](https://opengameart.org/content/tiny-islands-16x16-tilemap), confirmado em `INFO.txt` | nenhuma (atribuicao apreciada) | confirmado |
| `world/Tiny-Islands-by-Majadroid/buttons.png`, `sample-scene.png` | Majadroid | CC0 | idem | nenhuma; não usados em jogo, candidatos a remover do export | confirmado |
| `world/Tiny-Islands-by-Majadroid/Majadroid Brand Resources/*.png` | Majadroid | logótipos da marca do autor, fora do pacote CC0 | idem | não distribuir como parte do jogo | por confirmar: excluir do export |
| `character/human_base.png` | Antifarea e Clint Bellanger, adaptado por Doubi | CC-BY 3.0 | [OpenGameArt](https://opengameart.org/content/16x18-character-base-template-collage) | crédito visível no jogo e na página de publicação | confirmado pela base, crédito pendente (T-503) |
| `character/fishingrod.png` | presumivelmente Doubi (commit `c7f71c0` da base) | presumivelmente MIT do repositório da base | base-guy-on-island | manter aviso MIT | por confirmar |
| `object/raw_fish.png` | presumivelmente Doubi | presumivelmente MIT | base-guy-on-island | manter aviso MIT | por confirmar |
| `object/dummy_object.png` | presumivelmente Doubi | presumivelmente MIT | base-guy-on-island | manter aviso MIT | por confirmar |
| `icon.svg` | logótipo Godot (Andrea Calabró) | CC BY 4.0 | ícone por defeito de projectos Godot | crédito, ou substituir por ícone próprio antes de publicar | substituir |

## Código de terceiros

| Componente | Versão | Autor | Licença | Ficheiro de licença | Integridade |
|---|---|---|---|---|---|
| Guy on Island (base) | commit `37e5f2d` | Doubi | MIT | `game/LICENSE-guy-on-island.md` | submódulo git |
| Beehave | 2.9.3 | bitbrain | MIT | `game/addons/beehave/LICENSE` | SHA-256 do conteúdo (ficheiros ordenados, sem `.uid`/`.import`): `753d8b44b326633e48e962e01151bf4ea7cbb26c23250421b4b07a4283702a71` |
| GUT | 9.7.1 | Tom "Butch" Wesley | MIT | `game/addons/gut/LICENSE.md` | SHA-256 do tar.gz da release: `6da99c4e9228d9bec3fb4bd1730a487770a989f0f511dac82a2897a964613385` |

## Créditos obrigatórios (texto para o ecrã de créditos e para a página de publicação)

```
Personagem: Antifarea e Clint Bellanger, OpenGameArt.org (CC-BY 3.0)
Tileset Tiny Islands: Majadroid (CC0)
Código base Guy on Island: Doubi (MIT)
Beehave: bitbrain (MIT) · GUT: Tom "Butch" Wesley (MIT)
Feito com Godot Engine (MIT)
```

## Pendentes de aprovação

Nenhum. Propostas de assets de terceiros entram aqui com autor, URL, licença exacta e alternativa sem terceiros,
e esperam pelo Rodolfo.

## Proibido

Assets da Sierra On-Line ou Activision (incluindo `RESOURCE.001`, `RESOURCE.MAP` e sprites do Johnny Castaway),
qualquer licença NC ou ND, "free for personal use", e tudo sem licença identificada.
