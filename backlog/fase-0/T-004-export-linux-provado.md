---
id: T-004
titulo: Instalar export templates 4.7.2 e provar o export Linux
fase: 0
estado: pronto
tipo: infra
depende_de: [T-001]
---

## Objectivo
`scripts/export.sh` produz `dist/linux/insulano.x86_64` e o binário exportado arranca sem erros de script.

## Ler antes
- `scripts/export.sh`, `docs/runbook.md` secção "Export templates", `game/export_presets.cfg`

## Critérios de aceitação
- [ ] Templates instalados em `~/.local/share/godot/export_templates/4.7.2.stable/` a partir de
      `https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz`
      (é um zip; o conteúdo da pasta `templates/` vai para o destino)
- [ ] `scripts/export.sh` sai com 0 e imprime `PASSOU`
- [ ] `scripts/verify.sh --export` dá `export PASSOU`
- [ ] O binário exportado corre em modo janela 10 s na sessão Hyprland sem crash (comando e resultado no Relatório)
- [ ] `docs/runbook.md` secção "Export templates" tem os comandos exactos corridos e a data

## Fora de âmbito
- Export Windows e Web (T-507)
- Empacotar para distribuição (T-505)

## Prova exigida
- Saída de `scripts/export.sh` e tamanho do binário no Relatório

## Relatório
(preenchido pelo executor)
