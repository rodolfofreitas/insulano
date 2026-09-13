# 🏝️ Sistema de Necessidades Expandido - O Insulano

## Visão Geral

O Insulano deixa de ser um autómato faminto e torna-se uma *pessoa*: alguém que sente solidão, que se aborrece, que ainda tem esperança (ou não). Cada necessidade é um eixo psicológico independente, mas todas interagem, criando um espaço de comportamentos rico e imprevisível.

---

## 1. As Necessidades

### FOME (existente)
Range 0-100. Sobe passivamente. Desce ao pescar e comer. Comportamento base.

### 🫀 SOLIDÃO
> *"A ilha tem poucos metros quadrados e ele é o único habitante com nome."*

| Propriedade | Valor |
|---|---|
| **Range** | 0-100 |
| **Estado neutro** | ~40 |
| **Sobe quando…** | está sozinho em silêncio; noite cai; tentativas de comunicação falham |
| **Desce quando…** | fala com companheiro; interage com amor imaginário; escreve no diário |
| **Taxa base** | +0.8/s em idle; -5 por interacção social (real ou imaginária) |
| **Gatilho urgência** | >= 70 → comportamentos sociais forçados |
| **Crise (=100)** | Evento: *Colapso Relacional* - nasce o companheiro |
| **Êxtase (=0)** | Evento: *Amor Absoluto pelo Vazio* - paz zen |

### 😑 TÉDIO
> *"O peixe é sempre o mesmo. A praia é sempre a mesma."*

| Propriedade | Valor |
|---|---|
| **Range** | 0-100 |
| **Estado neutro** | ~30 |
| **Sobe quando…** | repete mesma actividade 3x; FOME satisfeita sem projecto activo |
| **Desce quando…** | actividade nova; inicia projecto (jangada, sinalização); evento inesperado |
| **Taxa base** | +0.5/s actividades repetidas; +1.2/s idle puro |
| **Gatilho urgência** | >= 65 → projectos absurdos e rituais |
| **Crise (=100)** | Evento: *Grande Plano Inútil* (pirâmide, constituição, olimpíadas...) |
| **Êxtase (=0)** | Evento: *Fluxo Total* - eficiência x3, fome mais lenta |

### 🌅 ESPERANÇA
> *"Hoje pode ser o dia. Sempre pode ser o dia."*

| Propriedade | Valor |
|---|---|
| **Range** | 0-100 |
| **Estado neutro** | ~55 |
| **Sobe quando…** | constrói sinalização; vê navio/avião; encontra objecto do mar |
| **Desce quando…** | jangada afunda; sinalização ignorada; chuva apaga fogueira |
| **Taxa base** | -0.2/s passivo (a esperança desgasta-se com o tempo) |
| **Gatilho urgência** | <= 25 → niilismo e comportamentos absurdos |
| **Crise (=0)** | Evento: *A Noite Escura da Ilha* |
| **Êxtase (=100)** | Evento: *Delírio do Resgate* |

---

## 2. O Companheiro Imaginário

Quando SOLIDÃO >= 70, o náufrago cria um companheiro a partir de um objecto encontrado.

### Objectos possíveis (aleatório)
coco, tábua à deriva, destroço de naufrágio, garrafa, pedaço de vela, capacete de borracha, bóia, pedra com cara pintada, fragmento de mastro, luva de boxe

### Nomes possíveis (aleatório, independente do objecto)
William, Guilherme, Tabinho, Senhor Coco, Naufrito, Boiante, Amigalhaço, Senhor Destroço, Tábua (nome próprio), Bóia (nome próprio), Pedrito, Companheiro

> **Nota legal:** Nenhum nome ou objecto é "Wilson" (Cast Away, 1999). A combinação nome+objecto é sempre aleatória e original.

### Ciclo de vida do companheiro
1. Objecto encontrado na praia → náufrago examina
2. SOLIDÃO >= 65 → desenha rosto com carvão
3. SOLIDÃO >= 70 → baptismo formal, nome anunciado em cerimónia
4. Companheiro activo: aparece nas cenas, náufrago fala com ele, apresenta-o a visitantes
5. Evento de destruição (onda, tempestade) → luto genuíno
6. Depois do luto: a) devastação prolongada, b) aceitação filosófica, c) fingir que o novo é o mesmo, d) nova amizade com entusiasmo exagerado

---

## 3. Interacções Entre Necessidades

| Condição | Efeito |
|---|---|
| TÉDIO alto + pescar | Reduz TÉDIO a dobrar; sobe ESPERANÇA ligeiramente |
| SOLIDÃO alta + falar com companheiro | Reduz SOLIDÃO -15; se TÉDIO também alto, náufrago inventa argumento com companheiro |
| ESPERANÇA baixa + SOLIDÃO alta | Ambas sobem mais depressa (+50%); espiral depressiva |
| FOME alta + TÉDIO baixo | TÉDIO sobe mais devagar (fome ocupa a mente) |
| FOME alta + SOLIDÃO alta | Consome ESPERANÇA -2/s |
| TÉDIO alto + construir jangada | TÉDIO -20 imediato; ESPERANÇA +15 |
| Jangada afunda | ESPERANÇA -30; TÉDIO -10 (foi dramático, pelo menos) |
| Todas as necessidades >= 75 | Evento raro: *Colapso Total* - náufrago olha para o nada 60 seg |

---

## 4. Prioridades do Behavior Tree

```
1  FOME >= 85             → Pescar (urgente)
2  SOLIDÃO = 100          → Evento: Colapso Relacional
3  ESPERANÇA = 0          → Evento: Noite Escura
4  TÉDIO = 100            → Evento: Grande Plano Inútil
5  SOLIDÃO >= 75          → Interagir com companheiro / criar companheiro
6  TÉDIO >= 70            → Projecto ambicioso
7  ESPERANÇA >= 85        → Evento: Delírio do Resgate
8  FOME >= 60             → Pescar (normal)
9  ESPERANÇA <= 20        → Comportamento niilista
10 TÉDIO >= 50            → Actividade variada / explorar
11 SOLIDÃO >= 50          → Falar sozinho / monólogo
12 default                → Passear / olhar para o oceano
```

---

## 5. Contexto Expandido para o LLM

```gdscript
func build_llm_context(actor) -> Dictionary:
    return {
        "hora": Time.get_time_string_from_system(),
        "dia_ilha": actor.day_count,
        "fome": actor.needs["FOME"].get_level_label(),
        "solidao": actor.needs["SOLIDAO"].get_level_label(),
        "tedio": actor.needs["TEDIO"].get_level_label(),
        "esperanca": actor.needs["ESPERANCA"].get_level_label(),
        "actividade_actual": actor.current_activity,
        "companheiro_nome": actor.companion_name if actor.has_companion else null,
        "companheiro_objecto": actor.companion_object if actor.has_companion else null,
        "arco_activo": actor.active_arc_id if actor.has_active_arc else null,
        "eventos_hoje": actor.events_today,
        "dias_sobrevividos": actor.day_count,
    }
```
