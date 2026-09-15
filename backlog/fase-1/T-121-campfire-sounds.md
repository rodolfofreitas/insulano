---
id: T-121
titulo: Sons da fogueira -- crepitar, assar, comer
fase: 1
estado: humano
tipo: infra
depende_de: [T-120]
---

## Objectivo

Obter 3 sons CC0 aprovados pelo Rodolfo e integra-los na fogueira:

| Som | Tipo | Uso |
|---|---|---|
| fogueira-crepitar.ogg | loop | AmbientAudio ou CampfireAudio enquanto fogueira arde |
| peixe-assar.ogg | one-shot | CookFishAction fase 4 (durante os ~8s de cozedura) |
| comer-satisfeito.ogg | one-shot | CookFishAction fase 5 (ao comer) |

Processo de aprovacao identico ao T-504 (ver `docs/gauntlet/playbook.md`):
1. Propor fontes CC0 candidatas (freesound.org ou equivalente)
2. Aguardar aprovacao do Rodolfo para cada ficheiro antes de descarregar
3. Registar em `docs/assets-licencas.md`

## Ler antes

- `docs/features/fogueira-assar-peixe.md` §4 -- lista de sons necessarios
- `docs/gauntlet/playbook.md` -- processo de aprovacao de assets
- `docs/assets-licencas.md` -- formato de registo de licencas
- `game/audio/ambient_audio.gd` -- padrao de audio ambiente a seguir
- T-120 deve estar implementado antes (para saber onde integrar)

## Critérios de aceitação

- [ ] 3 ficheiros .ogg CC0 em `game/audio/ambient/` (ou pasta dedicada `game/audio/campfire/`)
- [ ] Aprovacao do Rodolfo registada para cada ficheiro (comentario de aprovacao ou entrada em docs/)
- [ ] Registo em `docs/assets-licencas.md`: nome, URL de origem, autor, licenca CC0, data de aprovacao
- [ ] `fogueira-crepitar.ogg` a tocar em loop enquanto `CampfireObject` esta activo (lit)
- [ ] `peixe-assar.ogg` a tocar durante a fase de cozedura em `CookFishAction`
- [ ] `comer-satisfeito.ogg` a tocar na fase de comer em `CookFishAction`
- [ ] Audio para quando a fogueira se extingue (silencio gradual do loop -- fade out)
- [ ] Sem sons de fogueira de dia quando a luz esta desligada (consistencia audio/visual)
- [ ] verify.sh PASSOU

## Notas de implementacao

Duas opcoes para a integracao:
- **Opcao A** (recomendada): adicionar `AudioStreamPlayer2D` dentro de `CampfireObject`, gerido pelo proprio node
- **Opcao B**: extender `AmbientAudio` com contexto "campfire_active"

Decidir durante a implementacao. Documentar a decisao no Relatorio.

## Fora de ambito

- Sons de recolha de lenha (fase gather_wood -- pode usar som generico existente ou silencio)
- Sons de chuva a apagar a fogueira (v2)
- Musica ambiente diferente de noite junto a fogueira (v1.x)

## Prova exigida

- Aprovacao explicita do Rodolfo para cada um dos 3 ficheiros (email, mensagem ou commit de aprovacao)
- Entradas em `docs/assets-licencas.md` para os 3 sons
- verify.sh PASSOU

## Relatorio

_A preencher pelo agente apos implementacao._
