---
id: T-504
titulo: Sons ambiente CC0 aprovados pelo Rodolfo
fase: 5
estado: humano
tipo: infra
depende_de: [T-109]
---

## Objectivo
A ilha ganha som ambiente (mar, vento, gaivota), apenas com ficheiros CC0 que o Rodolfo aprovou um a um, e com volume desligável.

## Ler antes
- docs/assets-licencas.md
- docs/threat_model.md (T-01, assets; só leitura)
- agent_docs/prd.md (fora de âmbito da v0.1 e Fase 5)

## Critérios de aceitação
- [ ] O agente propõe uma lista de candidatos do freesound.org com filtro CC0: URL, autor, licença confirmada na página, duração, formato (prova: tabela em `docs/propostas-sons.md`).
- [ ] O Rodolfo aprovou cada ficheiro por escrito antes de ser descarregado para o projecto (prova: aprovação registada no Relatório).
- [ ] Cada ficheiro aprovado está registado em `docs/assets-licencas.md` com URL, autor, licença e data de download (prova: diff).
- [ ] Setting `insulano/audio/enabled` (defeito `true`) e volume em `insulano/audio/volume_db`; em modo protector o som respeita o setting (prova: teste GUT).
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG em [Não lançado].

## Fora de âmbito
- Música.
- Sons gerados por IA sem licença clara.

## Prova exigida
- Tabela de candidatos, aprovação do Rodolfo e registo de licenças.

## Relatório
(preenchido pelo executor)
