# Insulano -- Design Narrativo e Sistema de Progressão

*Documento de Design v1.0*

## Filosofia Central

> **"Cada vez que abandonas o ecra, o Insulano continua a viver. Cada vez que regressas, algo mudou -- e tu nao estavas la para ver."**

O Insulano nao e um jogo que se joga. E uma presenca que habita o teu computador. A tensao emocional nasce da ausencia: o utilizador sabe que aconteceram coisas enquanto nao estava. Isso cria curiosidade passiva -- o motor de retencao mais poderoso que existe.

---

## 1. Fases de Evolucao do Naufrago

As fases nao tem tutoriais nem anuncios. Simplesmente *acontecem*.

| Fase | Gatilho | O que muda visivelmente |
|------|---------|------------------------|
| **I -- O Choque** | Dias 1-7 | Move-se devagar, olha muito para o horizonte, frases curtas |
| **II -- A Rotina** | Dias 8-30 | Encontra ritmo, constroi abrigo basico, comeca a nomear coisas |
| **III -- A Adaptacao** | Dias 31-90 | Movimentos fluidos, sorri raramente mas sorri, a ilha parece *sua* |
| **IV -- O Filosofo** | Dias 91-180 | Contemplacao longa, rituais misteriosos, frases densas |
| **V -- O Lendario** | Dias 180+ | Raramente visivel, a ilha mudou a sua volta |

---

## 2. Arcos Narrativos Pre-definidos

Um arco e uma sequencia de eventos com inicio, desenvolvimento e resolucao, com duracao de horas a dias. Podem correr em paralelo. Um arco pode ser interrompido por outro e retomado depois.

### Tipos de Arco

| Tipo | Exemplos | Caracter |
|---|---|---|
| Sobrevivencia | A Jangada, O Diario | Comico/tragico |
| Relacao | O Companheiro, O Amor Imaginario | Emocional |
| Exploracao | O Naufragio, O Misterio da Ilha | Suspeito/misterioso |
| Civilizacao | A Republica da Ilha, As Leis | Absurdismo politico |
| Clima/natureza | A Tempestade, A Seca | Dramatico |
| Lendario | Avistamento inexplicavel, Mensagem que responde | Nunca se explica |
| **IA-gerado** | Qualquer combinacao nova | Emergente, unico |

### Catalogos de Arcos Base

**Arco "A Jangada"** (CICLICO)
Fases: encontra madeira -> dias a construir -> cerimonia de lancamento -> jangada afunda -> devastacao -> volta ao inicio.
Efeito: ESPERANCA +30 ao iniciar, -40 ao afundar. TEDIO -30 durante construcao.

**Arco "O Companheiro"** (CICLICO)
Fases: encontra objecto -> da-lhe nome -> constroi amizade -> companheiro desaparece -> luto -> encontra novo -> recomecar (ou nao).
Objecto aleatorio: coco, tabua, destroco, garrafa, boia, pedra...
Nome aleatorio: William, Guilherme, Tabinho, Senhor Coco, Naufrito, Boiante, Amigalhaco...

**Arco "A Sinalizacao"** (CICLICO)
Fases: decide fazer fogo de sinalizacao -> reune madeira -> acende -> fumo enorme -> barco passa sem parar -> desespero comico.

**Arco "O Naufragio"** (UNICO)
Fases: encontra destroco na praia -> investiga -> encontra pista sobre outros sobreviventes -> misterio nunca resolvido.

**Arco "A Civilizacao Propria"** (CICLICO)
Fases: constroi coisas -> nomeia lugares da ilha -> cria "leis" -> eleicoes sozinho -> discurso politico para as gaivotas.

**Arco "O Diario"** (CICLICO)
Fases: comeca a riscar dias numa pedra -> celebra aniversarios -> esquece a conta -> comeca de novo.

**Arco "O Amor Imaginario"** (RARO)
Fases: avista sombra ao longe -> tenta aproximar-se -> ilusao desfaz-se -> melancolia -> recuperacao.

**Arco "O Clima Extremo"** (CICLICO)
Fases: nuvens escuras -> tempestade -> danos na ilha -> reconstrucao -> calma -> gratidao exagerada.

**Arco "A Expedição Cientifica"** (RARO)
Fases: decide cartografar a ilha -> inventa nomes latinos para tudo -> escreve "tratado" em folhas -> perde o tratado -> refaz de memoria (diferente).

**Arco "A Olimpiada"** (RARO, UNICO)
Fases: organiza olimpiadas solitarias -> 6 provas inventadas -> faz podio de conchas -> discurso de encerramento -> chora de emocao.

---

## 3. Arcos Gerados pela IA -- Co-autoria com Memoria

### Conceito Central

A IA (Ollama) nao e apenas geradora de frases -- e **co-autora com memoria**. O que ela inventa hoje alimenta amanha. Os arcos que ela cria ficam registados no loop e influenciam o comportamento futuro do naufrago.

O naufrago **sabe o que viveu** e **faz referencias ao passado**. A IA **sabe o que ela propria criou** e nao repete.

### Estrutura de Dados -- arc_history.json

```json
{
  "active_arcs": [
    {
      "id": "arc_ia_001",
      "type": "ia_generated",
      "titulo": "A Teoria do Cozinheiro",
      "origem": "llm",
      "fase_actual": 2,
      "fases": [
        "Naufrago encontra conchas dispostas em padrao estranho",
        "Decide que sao sinais de um cozinheiro naufragado antes dele",
        "Comeca a cozinhar de forma elaborada para impressionar o predecessor",
        "Percebe que foi ele proprio quem dispos as conchas -- nao se lembra"
      ],
      "finalizado": false,
      "criado_em_dia": 23,
      "estado_emocional_origem": {"solidao": 72, "tedio": 81},
      "necessidade_que_sobe": "ESPERANCA"
    }
  ],
  "completed_arcs": [
    {
      "id": "arc_jangada_1",
      "titulo": "A Jangada",
      "tipo": "predefinido",
      "resultado": "afundou",
      "completado_em_dia": 14
    }
  ],
  "ia_arc_count": 3,
  "ia_arc_seeds_used": ["conchas_padrao", "predecessor_misterioso", "teoria_navegacao"]
}
```

### Quando a IA Gera um Novo Arco

Gatilho: TEDIO >= 65 E nenhum arco activo E dia_desde_ultimo_arco >= 1.

O EventDirector envia ao Ollama um prompt de geracao com contexto completo:
- Dia actual, necessidades actuais
- Titulos de todos os arcos ja completados (para nao repetir)
- Objectos actualmente na ilha
- Ultimo evento e arco
- Estacao do ano
- Nome do companheiro actual (se existir)

O Ollama responde com JSON: titulo, tipo, fases (array), como_termina, necessidade_que_sobe.

### Validacao Antes de Entrar no Loop

O arco gerado e validado:
1. Tem pelo menos 2 fases?
2. O titulo nao repete nenhum arco anterior?
3. As fases nao contem palavras proibidas (phrase_rules.json)?
4. Se falhar: usar arco base aleatorio em vez de descartar silenciosamente.

### Como a Memoria Funciona nas Frases

O Ollama recebe SEMPRE no contexto:
- Titulos dos ultimos 5 arcos completados
- Arco activo actual e fase actual
- Flag: arco foi gerado pela propria IA ou era predefinido

Isso permite frases com memoria real:

Apos arco "A Jangada": "Nunca mais vou tentar. A fisica nao colabora."
Apos arco IA "A Teoria do Cozinheiro": "As conchas estavam dispostas de forma deliberada. Tenho a certeza."
Durante novo arco: "Desta vez e diferente da jangada. Desta vez tenho um plano."

### Arcos IA com 4a Parede Suave (Fase IV+)

Em Fase IV+, a IA pode gerar arcos onde o naufrago *quase* repara que esta a ser observado:

Exemplo gerado possivelmente pela IA:
```
Arco "O Publico":
  Fase 1: Naufrago comeca a ensaiar "monologos" sem razao aparente
  Fase 2: Organiza "recita" para audiencia imaginaria
  Fase 3: Fica a olhar para a camara no fim. Pausa. Sorri.
  Fase 4: Continua a vida. Nunca mais menciona.
```

---

## 4. Memoria Persistente Entre Sessoes

### Ficheiros em user://

```
user://save.json          -- estado principal (fase, dias, metricas)
user://memory.json        -- memoria emocional e referencias
user://events_log.json    -- lista de eventos ocorridos com timestamps
user://arc_history.json   -- arcos completados, activos, gerados pela IA
user://discovered.json    -- lendas ja vistas (garantir unicidade)
user://fragments.json     -- objectos encontrados e respectivas frases
```

### Comportamento por Tempo Decorrido Desde Ultima Sessao

| Ausencia | Comportamento ao regresso |
|----------|--------------------------|
| < 1 hora | Nada especial. A vida continua. |
| 1-6 horas | Naufrago esta noutra parte da ilha |
| 6-24 horas | Acorda do abrigo, espreguica-se, comeca rotina |
| 1-3 dias | Mais cansado. Fogueira apagada. Reacende devagar. |
| 3-7 dias | Visivelmente diferente. Primeira frase com peso emocional maximo. |
| 7-30 dias | Ilha mudou. Construcoes deterioradas. Resignado mas estavel. |
| 30+ dias | Silencio 60s. Naufrago vira-se: "Ah. Estas aqui. Continuei a contar os dias." |

---

## 5. Eventos Lendarios (Cada um Ocorre Uma Vez)

| ID | Condicao | Descricao |
|----|----------|-----------|
| `outra_ilha` | Dia 45+, madrugada | Silhueta de outra ilha na nevoa. Desaparece. Mencionada uma vez semanas depois. |
| `reflexo` | Dia 90+, Fase IV | O reflexo na agua tem delay de 0.5s. Naufrago recua, olha para as maos, vai embora rapido. |
| `sinal_radio` | Dia 120+ | Radio partida liga-se 3 segundos. Voz humana incompreensivel. Radio fica no abrigo para sempre. |
| `navio_fantasma` | Dia 180+, noite | Navio antigo sem luzes atravessa a baia. Naufrago dorme, nao ve. So o utilizador ve. Corda nova na praia de manha. |
| `a_resposta` | Dia 200+ | Semanas apos lancar garrafa, garrafa diferente chega. Naufrago le, dobra, guarda. Frase da noite: "Alguem recebeu." |

---

## 6. Momentos de 4a Parede Suave

O naufrago nunca quebra directamente a 4a parede. Apenas *repara em coisas*.

- **"A Sombra"**: Para a pescar. Vira-se para a camara. 10-15s imovel. Volta a pescar. Sem frase.
- **"O Comentario do Entardecer"**: "As vezes tenho a sensacao de que este por-do-sol e especialmente bonito. Como se alguem o estivesse a ver."
- **"A Hora Exacta"**: Para, calcula a hora pelo sol, diz a hora certa. E a hora do sistema. (P=0.05 quando relogio bate hora exacta)
- **"A Noite Mais Longa"**: Se sessao activa entre 02:00-04:00: "Tu nao devias estar acordado a esta hora. Nem eu."
- **"A Pergunta"**: (Dia 120+) Vira-se 3/4 para a camara: "Ainda estas ai?" Pausa 5s. "Bom." Continua.

---

## 7. A Tensao Narrativa Permanente

A tensao central nunca se resolve:

> **O naufrago quer ser resgatado?**

Em certos momentos trabalha para isso (sinais de fumo, garrafa ao mar).
Noutros, parece ter feito as pazes com a ilha (nomeia arvores, cuida de rituais, sorri sozinho).

O utilizador que o observa durante meses forma a sua propria resposta.
Essa resposta diz mais sobre o utilizador do que sobre o naufrago.

Esta ambiguidade e **intencional e permanente**.
