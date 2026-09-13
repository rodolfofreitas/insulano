---
id: T-507
titulo: Build Windows exportado e provado com modo protector
fase: 5
estado: pronto
tipo: infra
depende_de: [T-501, T-004]
---

## Objectivo
Existe um executável Windows do Insulano exportado de forma reproduzível nesta máquina e provado a arrancar em Windows, incluindo o modo protector por argumento.

## Ler antes
- scripts/export.sh e a T-004 (templates e export Linux)
- game/export_presets.cfg (preset "Windows Desktop", saída ../dist/windows/insulano.exe)
- ~/.claude/CLAUDE.md secção "Docker e VMs" (VMs Windows são contentores dockurr/windows geridos com ~/VMs/docker/scripts/fleet.sh)

## Critérios de aceitação
- [ ] `scripts/export.sh` (ou um `scripts/export-windows.sh` equivalente) exporta `dist/windows/insulano.exe` em modo headless e sai com INDETERMINADO (exit 3) quando faltam os templates (prova: output dos dois casos no Relatório).
- [ ] O executável arranca em Windows (wine no Linux ou uma VM dockurr já existente, sem criar VMs novas) durante 60 s sem erros de script no log (prova: log gravado em `reports/` e excerto no Relatório).
- [ ] `insulano.exe -- --screensaver` abre em ecrã inteiro e sai ao mexer o rato (prova: screenshot da VM ou relato detalhado se só for possível em wine).
- [ ] O runbook documenta o comando de export Windows e como testar (prova: diff de docs/runbook.md).
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG em [Não lançado].

## Fora de âmbito
- Ficheiro .scr e registo como protector de ecrã oficial do Windows.
- Assinatura de código.

## Prova exigida
- Output do export, log de arranque em Windows e screenshot ou relato do modo protector.

## Relatório
(preenchido pelo executor)
