# Propostas de alteração ao threat model

O [`threat_model.md`](threat_model.md) só é alterado pelo Rodolfo. Os agentes registam aqui achados e
propostas, com a evidência. O Rodolfo aceita (copia para o threat model e marca `aceite`) ou recusa
(marca `recusada` com o motivo).

---

## P-01: o Ollama está publicado em todas as interfaces

Estado: proposta · Data: 2026-09-13 · Afecta: T-03

**Evidência.** `docker inspect ollama` mostra `PortBindings {"11434/tcp":[{"HostIp":"","HostPort":"11434"}]}`
e `docker ps` mostra `0.0.0.0:11434->11434/tcp`. O T-03 afirma que "o Ollama por defeito só escuta localhost"
e manda "nunca alterar o bind address para 0.0.0.0". Na prática já está exposto à rede local.

**Proposta.** Publicar a porta só no loopback (`127.0.0.1:11434:11434` no compose ou no `docker run`) e
actualizar a probabilidade do T-03 para ALTA até isso estar feito. Fica fora do repositório: acção do Rodolfo.

## P-02: clima real envia o IP e a localização ao wttr.in

Estado: proposta · Data: 2026-09-13 · Afecta: secção 3, T-05

**Evidência.** A secção 3 diz que o projecto "não envia dados para a internet (excepto wttr.in opcional e sem
dados pessoais)". Um pedido HTTP ao wttr.in revela sempre o IP público e, com `location` definida, a cidade.

**Proposta.** Reconhecer IP e localização como dados pessoais; manter o clima desligado por defeito; decidir na
T-306 se se liga por defeito e com que aviso.

## P-03: filtro de conteúdo passa a regras partilhadas e testadas

Estado: proposta · Data: 2026-09-13 · Afecta: T-02

**Evidência.** O T-02 prevê "lista de palavras proibidas no LLMBridge". O desenho actual põe a lista em
`game/data/phrase_rules.json`, usada pelo jogo (`PhraseFilter`, T-103) e pelo eval, com fixture partilhada.

**Proposta.** Actualizar a mitigação do T-02 para apontar para `phrase_rules.json` e para o eval
(`scripts/llm_eval.py`) como verificação contínua.

## P-04: texto externo nunca entra cru no prompt

Estado: proposta · Data: 2026-09-13 · Ameaça nova

**Evidência.** A partir da Fase 3, dados do wttr.in chegam ao contexto do LLM. Texto de uma fonte externa
dentro de um prompt é um vector de injecção de prompt, mesmo que improvável.

**Proposta.** Regra: só códigos numéricos do wttr.in, traduzidos por `game/data/weather_codes.json` para
rótulos fixos em pt-PT, entram no `PhraseContext`. Já está no desenho da T-304.

## P-05: o código-fonte não tem salvaguarda fora do disco

Estado: proposta · Data: 2026-09-13 · Afecta: activo "Código fonte"

**Evidência.** A tabela de activos diz "Perda de trabalho; mitigado por git". O repositório não tem remoto
(`git remote -v` vazio) e o `/home` desta máquina não tem snapshots (só a config `root` do snapper).

**Proposta.** Criar um remoto privado ou cópia periódica para `/mnt/dados`; até lá, impacto ALTO.

## P-06: assets herdados com licença não confirmada

Estado: proposta · Data: 2026-09-13 · Afecta: T-01, secção 4

**Evidência.** O README da base só credita o tileset e os sprites do personagem. `game/character/fishingrod.png`
e `game/icon.svg` não têm atribuição. Detalhe em [`assets-licencas.md`](assets-licencas.md).

**Proposta.** Confirmar a origem antes de publicar (T-505) ou substituir por assets criados pelo projecto.

## P-07: dependências vendorizadas sem verificação de integridade

Estado: proposta · Data: 2026-09-13 · Afecta: T-04

**Evidência.** GUT 9.7.1 e Beehave estão copiados em `game/addons/` a partir de releases do GitHub, sem hash
registado.

**Proposta.** Registar a versão e o SHA-256 do arquivo de cada addon em `docs/assets-licencas.md` quando é
actualizado (T-005 já o pode fazer).
