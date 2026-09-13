---
id: T-505
titulo: Publicar no itch.io
fase: 5
estado: humano
tipo: infra
depende_de: [T-503, T-109]
---

## Objectivo
O Insulano fica disponível publicamente no itch.io com builds descarregáveis e os créditos obrigatórios na página. Publicar é externo e irreversível na prática: só o Rodolfo decide e executa.

## Ler antes
- docs/runbook.md (secção de publicação)
- docs/assets-licencas.md
- CHANGELOG.md (versão a publicar)

## Critérios de aceitação
- [ ] O agente preparou os artefactos: `dist/insulano-linux.tar.gz` (e Windows se a T-507 estiver feita), com checksums SHA-256 em `dist/SHA256SUMS` (prova: comandos e output no Relatório).
- [ ] O agente escreveu o texto da página em pt-PT e inglês com os créditos CC-BY exactos (prova: `docs/itch-pagina.md`).
- [ ] O Rodolfo criou a página, fez o upload e confirmou a URL pública (prova: URL registada no Relatório pelo Rodolfo).
- [ ] O binário descarregado da página arranca numa máquina limpa ou VM (prova: confirmação registada).

## Fora de âmbito
- Pagamentos, Steam, lojas de aplicações.

## Prova exigida
- Checksums, texto da página e URL pública confirmada.

## Relatório
(preenchido pelo executor)
