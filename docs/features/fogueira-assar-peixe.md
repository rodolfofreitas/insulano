# Feature: Fogueira e Assar Peixe

Versao 0.1 | 2026-09-15 | Estado: design aprovado, implementacao pendente (T-119, T-120, T-121)

---

## 1. Descricao e Motivacao

### Problema actual

O naufrago pesca e come o peixe **cru e imediatamente**, sem cerimonia. Isto viola a logica de
sobrevivencia e empobrece a experiencia: comer cru devia ser um sinal de desespero, nao a norma.

### Proposta

Substituir o consumo imediato por um **ritual de sobrevivencia** em cinco fases:
pesca -> recolhe lenha -> faz fogueira -> assa o peixe -> come com satisfacao.

Este ritual:
- Da ao naufrago mais personalidade e dignidade mesmo numa ilha deserta
- Cria uma sequencia de animacoes visualmente rica (fogueira de noite e especialmente bonita)
- Diferencia a recompensa: peixe assado vale o dobro do peixe cru em pontos de fome
- Abre a porta para futuros eventos relacionados com a fogueira (ver docs/events-catalogue.md)

---

## 2. Sequencia Completa de Estados do Naufrago

```
FASE 1: Pesca
  - fishing_action.gd executa como hoje
  - Em vez de chamar need.replenish() directamente, define blackboard["has_fish"] = true
  - O naufrago guarda o peixe (animacao de colocar no cinto ou inventario)

FASE 2: Recolher Lenha
  - MakeCampfireAction: sub-fase "gather_wood"
  - Animacao: naufrago agacha-se 2-3 vezes apanhando raminhos (duracao ~3s)
  - Sem recurso escasso nesta versao: a lenha esta sempre disponivel (ver §8 Fora de ambito)

FASE 3: Acender Fogueira
  - MakeCampfireAction: sub-fase "light_fire"
  - Animacao: naufrago esfraga dois paus, sopra, faiscas aparecem
  - CampfireObject.lit() e emitido -> CPUParticles2D chamas activadas, PointLight2D activado
  - SmokePuff dispara uma rafada de fumo ao acender

FASE 4: Assar o Peixe
  - CookFishAction: naufrago segura peixe sobre a fogueira (~8s)
  - SmokePuff dispara fumo fino e continuo durante a cozedura
  - Progresso visual opcional: cor do sprite do peixe muda de cinzento para dourado

FASE 5: Comer com Satisfacao
  - Animacao de comer (boca a mover, olhos fechados)
  - need.replenish(HUNGER, 60) -- o dobro dos 30pts actuais do comer cru
  - Frase do LLM: contexto "acabei de assar e comer peixe, satisfeito"
  - Fogueira arde mais 60s e extingue-se gradualmente
  - blackboard["has_fish"] = false
```

---

## 3. Arquitectura Proposta

### 3.1 CampfireObject (Node2D)

Ficheiro: `game/object/campfire_object.gd` + `game/object/campfire_object.tscn`

```
CampfireObject (Node2D)
  FlameParticles (CPUParticles2D)   # chamas laranja/amarelo, baseado no padrao de rain.gd
  EmberParticles (CPUParticles2D)   # brasas pequenas, opcional
  SmokePuff (CPUParticles2D)        # fumo ao acender e durante a cozedura
  CampfireLight (PointLight2D)      # so activo quando is_night == true via Clock
  AudioStreamPlayer2D               # ligado a CampfireAudio (T-121)
```

Sinais:
- `lit()` -- emitido quando a fogueira acende
- `extinguished()` -- emitido quando a fogueira se apaga (apos burn_duration_s)

Propriedades exportadas:
- `burn_duration_s: float = 60.0` -- quanto tempo arde apos o naufrago comer
- `light_energy_night: float = 1.2` -- intensidade da luz de noite
- `smoke_on_light: bool = true` -- activar SmokePuff ao acender

Comportamento da luz:
- Conecta ao sinal `Clock.hour_changed` (ou verifica `DayNightCycle.is_night`)
- Se is_night: `CampfireLight.enabled = true`
- Se is_day: `CampfireLight.enabled = false`
- Luz pisca ligeiramente (modulate_energy com seno suave) para simular crepitar

### 3.2 SmokePuff (CPUParticles2D reutilizavel)

Ficheiro: `game/object/smoke_puff.gd`

Pequeno componente com dois modos:
- `BURST` -- rafada unica de fumo (ao acender)
- `CONTINUOUS` -- fumo fino continuo (durante a cozedura)

Baseado nos parametros de `game/world/rain.gd` como padrao de referencia.

### 3.3 CookFishAction (BeehaveAction)

Ficheiro: `game/beehave/cook_fish_action.gd`

Extende `BeehaveAction`. Executa quando:
- `blackboard["has_fish"] == true`
- Existe um `CampfireObject` activo na cena (acesso via grupo "campfire")

Sequencia interna:
1. Move naufrago para junto da fogueira
2. Toca animacao "cook" (~8s)
3. Activa `campfire.smoke_puff.start(CONTINUOUS)`
4. Aguarda timer
5. Chama `need.replenish(Need.Type.HUNGER, 60)`
6. Define `blackboard["has_fish"] = false`
7. Retorna SUCCESS

### 3.4 MakeCampfireAction (BeehaveAction)

Ficheiro: `game/beehave/make_campfire_action.gd`

Extende `BeehaveAction`. Executa quando:
- `blackboard["has_fish"] == true`
- Nao existe CampfireObject activo

Sub-fases (estado interno):
1. `GATHER_WOOD` (~3s de animacao)
2. `LIGHT_FIRE` (~2s de animacao, SmokePuff BURST)
3. Instancia `CampfireObject` na posicao actual
4. Emite `campfire.lit()`
5. Retorna SUCCESS (CookFishAction entra a seguir no behaviour tree)

### 3.5 Modificacao em fishing_action.gd

Ficheiro existente: `game/character/fishing_action.gd`

Mudanca minima:
```gdscript
# ANTES:
need.replenish(Need.Type.HUNGER, 30)

# DEPOIS:
blackboard["has_fish"] = true
# (a fome e reposta pelo CookFishAction apos assar)
```

Variante (sem lenha -- se for implementada futuramente):
- Se `blackboard["no_wood_available"] == true`, consumir cru com -20pts e frase de resignacao
- Esta variante esta FORA DE AMBITO em v0.x (ver §8)

### 3.6 Integracao no Behaviour Tree

Adicionar ao selector de "satisfy_hunger":

```
Selector [satisfy_hunger]
  Sequence [cook_fish_ritual]           # prioridade maxima
    Condition: has_fish == true
    MakeCampfireAction                  # recolhe lenha + acende
    CookFishAction                      # assa + come
  Sequence [fish_and_cook]              # fluxo normal
    FishingAction                       # pesca (define has_fish=true)
    MakeCampfireAction
    CookFishAction
```

### 3.7 Recompensa

| Metodo | Pontos de Fome | Notas |
|---|---|---|
| Comer cru (comportamento actual, a remover) | -30pts | Substituido pelo ritual |
| Comer assado (novo comportamento) | -60pts | Ritual completo obrigatorio |
| Comer cru por desespero (variante futura) | -20pts | Frase de resignacao, Fora de ambito v0.x |

---

## 4. Sons Necessarios (Aprovacao do Rodolfo)

Ver processo de aprovacao em `docs/gauntlet/playbook.md` -- mesmo fluxo que T-504.

NAO descarregar antes da aprovacao. Propor apenas fontes CC0 verificadas.

| Som | Duracao | Uso | Fonte sugerida |
|---|---|---|---|
| fogueira-crepitar.ogg | loop ~10s | AmbientAudio enquanto fogueira arde | freesound.org (filtrar CC0) |
| peixe-assar.ogg | one-shot ~4s | CookFishAction fase 4 | freesound.org (filtrar CC0) |
| comer-satisfeito.ogg | one-shot ~1s | CookFishAction fase 5 (comer) | freesound.org (filtrar CC0) |

O som de lancamento da cana de pesca (mwchristian95/725425 CC0) ja foi aprovado e esta fora do
ambito desta feature.

---

## 5. Gauntlet: Barra de Referencia para a Animacao da Fogueira

Ver `docs/gauntlet/bars.md` -- seccao "Dimensao Visual -- Fogueira".

Barras definidas:
- Stardew Valley fogueira de acampamento (https://stardewvalleywiki.com/Campfire) -- para as particulas
- Graveyard Keeper fogueira -- para o estilo e atmosfera nocturna

O gauntlet para CampfireObject deve correr apos T-119 estar implementado.
Instrucao: "Gauntlet: Visual Fogueira -- CampfireObject nocturno contra Stardew Valley Campfire"

---

## 6. Criterios de Sucesso

- [ ] O naufrago NUNCA come peixe cru (FishingAction nao repoe fome directamente)
- [ ] A fogueira e visivel de noite (PointLight2D activo, partículas laranja)
- [ ] O fumo sobe ao acender e durante a cozedura (SmokePuff)
- [ ] A recompensa e 60pts de fome (o dobro do anterior)
- [ ] Testes GUT passam: test_cook_fish_reduces_hunger_60pts e test_raw_fish_never_eaten_directly
- [ ] verify.sh PASSOU apos T-119 + T-120 + T-121

---

## 7. Dependencias

| Dependencia | Tipo | Notas |
|---|---|---|
| T-113 (ArcHistory) | tecnica | base do behaviour tree estabilizada |
| T-203 (energia/sleep) | funcional | DayNightCycle.is_night necessario para a luz |
| game/character/fishing_action.gd | modificacao | definir has_fish em vez de replenish() |
| game/world/rain.gd | referencia | padrao CPUParticles2D a seguir |
| game/audio/ambient_audio.gd | integracao | padrao de audio ambiente a seguir |

---

## 8. Fora de Ambito (v0.x)

- Madeira como recurso escasso (requer inventario de recursos -- v1.x)
- Fogueira que apaga com chuva (requer integracao rain.gd -> campfire -- v2)
- Comer cru por falta de lenha (variante de desespero -- v1.x)
- Multiplas fogueiras simultaneas
- O naufrago partilhar a fogueira com um companheiro imaginario (arco narrativo futuro)
- Fogueira como sinal de socorro (ver events-catalogue.md Arco "A Sinalizacao")
