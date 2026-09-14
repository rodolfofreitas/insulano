---
id: T-108
titulo: Afinar prompt e regras até o eval passar sem próclise brasileira nem frases sem sentido
fase: 1
estado: feito
tipo: codigo
depende_de: [T-102, T-103]
---

## Objectivo
As frases do modelo configurado soam a um náufrago português com humor seco, medidas pelo eval e
revistas por um agente que não as escreveu.

## Ler antes
- `docs/proof/llm-eval-llama3.1_8b-2026-09-13.json` (linha de base: 95,8%, p50 2,82 s)
- `game/data/prompts/phrase_prompt.txt`, `game/data/phrase_rules.json`, `evals/phrase_cases.json`

## Critérios de aceitação
- [x] Regra nova em `ptbr_patterns` para verbo modal + pronome + infinitivo (ex. observado: "pode me ajudar"), com casos novos na fixture partilhada (positivo e falso positivo: "o barco que me leve" é pt-PT válido)
- [x] Prompt revisto para evitar objectos e animais impossíveis (ex. observado: "ovo de frango", "coelho"); texto final no Relatório
- [x] `python3 scripts/llm_eval.py --proof --samples 5` com PASSOU e taxa de aceitação de pelo menos 0,9
- [x] O agente `insulano-reviewer` (nunca quem escreveu o prompt) classifica 20 frases do relatório como coerente ou incoerente; pelo menos 16 coerentes; tabela no Relatório (feito: 16/20 coerentes, cumprido sem margem; ver secção "Frases para classificação")
- [x] Testes pytest e GUT do filtro continuam em paridade (`scripts/verify.sh` sem FALHOU)

## Fora de âmbito
- Trocar de modelo ou fazer `ollama pull` (decisão do Rodolfo, ADR-006)

## Prova exigida
- Novo `docs/proof/llm-eval-*.json` e a tabela de revisão

## Relatório

**Estado: em-curso** (1.ª volta de correcção pós-revisão: o `insulano-reviewer` classificou as 20
frases, critério 4 cumprido, 16/20 coerentes, mas devolveu ALTERAÇÕES NECESSÁRIAS com 1
bloqueante, corrigido na Tentativa 1b; a decisão de fechar a tarefa continua a não ser minha).

### Linha de base (antes de qualquer mudança)

Carga no início (uptime 1min): 1.30. `python3 scripts/llm_eval.py --samples 5` (sem `--proof`,
`reports/llm-eval-20260914-230758.json`): pass_rate 0,975, p50 3,27 s, p95 5,01 s, rejeições
`too_long: 1`. Frases aceites revistas à mão: nenhuma ocorrência de "pode me"/"pode te" nem de
animais de quinta desta vez, mas a prova anterior de 2026-09-13
(`docs/proof/llm-eval-llama3.1_8b-2026-09-13.json`) tinha ambos os problemas ("ovo de frango",
"coelho", "pode me ajudar" aceite) e é o ponto de partida real da tarefa.

### Tentativa 1: regra `ptbr_patterns` para "verbo modal + pronome + infinitivo"

**Hipótese:** o filtro deixa passar próclise brasileira do tipo "pode me ajudar" (observado na
prova de 2026-09-13, caso `barco`), porque nenhum dos três padrões `ptbr_patterns` existentes
cobre modal + pronome + infinitivo; em pt-PT seria "pode ajudar-me".

**Mudança mínima:** acrescentado um quarto padrão a `ptbr_patterns` em `game/data/phrase_rules.json`:

```
(?i)(^|[^a-z])(pode|podes|podem|podemos|posso|deve|deves|devem|devemos|devo|quer|queres|querem|queremos|quero|vai|vais|vão|vamos|consegue|consegues|conseguem|conseguimos|consigo) (me|te|nos|lhe|lhes|se) [a-zà-ú]+(ar|er|ir)($|[^a-zà-ú])
```

Exige um verbo modal da lista imediatamente antes do pronome clítico, seguido de uma palavra que
termina em `ar`/`er`/`ir` (infinitivo). Não usa `(*UCP)` no próprio padrão (o `PhraseFilter` já o
prefixa ao compilar, `phrase_filter.gd:167-175`); a nota do ficheiro foi actualizada a explicar a
regra e a corrigir o `--` antigo (trocado por vírgula, sem travessão).

Casos novos em `game/tests/fixtures/phrase_filter_cases.json`:
- Positivo (tem de ser apanhado): `"Pode me ajudar com isto, por favor?"` -> `reason: "ptbr"`.
- Falso positivo (tem de passar, pt-PT válido): `"O barco que me leve para casa."` -> `reason: null`
  (o "que" antes de "me" não é verbo modal da lista, por isso não casa).
- Paridade em maiúsculas acentuadas (o `vão` do padrão tem `ã`): `"VÃO ME AJUDAR AMANHÃ CEDO."` ->
  `reason: "ptbr"`.

**Medir:** `uvx pytest -q scripts/tests`: 47 passed (antes: 44 passed, +3 dos casos novos). GUT
`test_phrase_filter.gd` corrido isoladamente: 2/2 passed, incluindo `test_case_matches_python_eval`
sobre os três casos novos (paridade Python/GDScript confirmada, o PCRE2 do Godot com `(*UCP)` deu o
mesmo resultado que o `re` do Python nos três, incluindo o caso com `VÃO` em maiúsculas acentuadas).

**Decisão: manter.** Sem custo de latência (é um filtro, não toca no LLM); corrige exactamente o
padrão observado e não apanha o falso positivo pedido.

### Tentativa 2: prompt revisto contra animais/objectos impossíveis na ilha

**Hipótese:** o prompt actual (4 linhas) não restringe o vocabulário do LLM a coisas plausíveis
numa ilha deserta, daí "ovo de frango" e "coelho" na prova de 2026-09-13; uma linha extra a listar
o que existe e o que nunca existiria devia reduzir isso sem penalizar muito a latência em CPU.

**Mudança mínima:** uma linha nova entre a primeira e a que pede a frase, em
`game/data/prompts/phrase_prompt.txt`:

> Só existe na ilha o que uma ilha deserta teria: peixe, coco, gaivotas, caranguejos, o mar, o
> vento, palmeiras, um barco distante; nunca animais de quinta (galinha, coelho, vaca, porco) nem
> objectos que não haveria aqui.

Texto final do prompt (5 linhas):

```
És um náufrago que vive sozinho numa pequena ilha tropical há muito tempo. Tens humor seco e ainda alguma esperança.
Só existe na ilha o que uma ilha deserta teria: peixe, coco, gaivotas, caranguejos, o mar, o vento, palmeiras, um barco distante; nunca animais de quinta (galinha, coelho, vaca, porco) nem objectos que não haveria aqui.
Diz UMA frase curta (entre 3 e 14 palavras), em português de Portugal, na primeira pessoa, em voz alta, agora.
Situação: são {hour}h ({period}); estás a {action}; fome: {hunger}; tempo: {weather}; data especial: {holiday}.
Responde só com a frase: sem aspas, sem emojis, sem explicações.
```

**Medir:** carga antes: uptime 1min 3,96 (< 8, dentro do limite).
`python3 scripts/llm_eval.py --samples 5` (`reports/llm-eval-20260914-231213.json`): pass_rate
0,975, p50 3,16 s (antes 3,27 s), p95 5,15 s (antes 5,01 s), rejeições `too_long: 1`. Nenhuma
frase aceite mencionou animal de quinta ou objecto impossível; nenhuma com "pode me"/"deve
me"/etc. (a regra da Tentativa 1 já as teria apanhado de qualquer forma).

**Decisão: manter.** pass_rate igual, p50 ligeiramente melhor, p95 dentro do limite (8,0 s) com
margem confortável; sem sinal de regressão por adicionar uma linha ao prompt.

### Tentativa 1b (correcção pós-revisão, 1.ª volta): lista de verbos incompleta em `ptbr_patterns`

**Bloqueante do `insulano-reviewer`:** o quarto padrão de `ptbr_patterns` cobre
`vai|vais|vão|vamos` mas não a primeira pessoa `vou`, nem os pretéritos imperfeitos usados como
modal (`ia`, `podia`, `devia`, `queria`); o prompt pede "na primeira pessoa" e, nas 144 frases
geradas que existem (a prova de 09-14, os dois reports e a prova de 09-13), há 35 com "vou" contra
só 4 das outras formas de "ir". Isto deixava passar "Vou me deitar cedo.", "Vou te contar uma
coisa." e "Já devia me ter habituado." (esta última forma já tinha aparecido na linha de base como
"já devia ter me habituado").

**Mudança mínima:** aplicado o padrão sugerido literalmente pelo revisor em
`game/data/phrase_rules.json` (quarto padrão de `ptbr_patterns`): acrescentado
`vou|ia|ias|iam|podia|devia|queria` à lista de verbos, e `(?!calhar)` a seguir ao grupo de
pronomes clíticos, para não apanhar a locução pt-PT "vai, se calhar" (que não é próclise). Padrão
final:

```
(?i)(^|[^a-z])(pode|podes|podem|podemos|posso|deve|deves|devem|devemos|devo|quer|queres|querem|queremos|quero|vou|vai|vais|vão|vamos|ia|ias|iam|podia|devia|queria|consegue|consegues|conseguem|conseguimos|consigo) (me|te|nos|lhe|lhes|se) (?!calhar)[a-zà-ú]+(ar|er|ir)($|[^a-zà-ú])
```

A nota do ficheiro foi actualizada a explicar a cobertura nova (`vou`/`ia`/`podia`/`devia`/`queria`
e a excepção `(?!calhar)`). Não repeti `(*UCP)` no padrão (o `PhraseFilter` já o prefixa ao
compilar, `phrase_filter.gd`, confirmado na Tentativa 1).

Casos novos em `game/tests/fixtures/phrase_filter_cases.json` (formato compacto uma linha por
caso reposto, conforme pedido pelo revisor: o diff desta correcção fica em 2 linhas acrescentadas,
não numa reformatação total):
- Positivo (tem de ser apanhado): `"Vou me deitar cedo."` -> `reason: "ptbr"`.
- Falso positivo (tem de passar, pt-PT válido): `"Hoje vai se calhar chover."` -> `reason: null`
  (a locução "se calhar" não é próclise, o `(?!calhar)` impede o match).

**Medir (offline; instrução explícita de não correr o eval contra o Ollama nesta correcção):**
- Confirmação isolada em `re.search` (Python) antes de tocar no repositório: os 9 casos citados
  pelo revisor batem certo, incluindo os 3 negativos que ele já tinha testado em Godot ("Vou-me
  deitar cedo.", "Hoje vai se calhar chover.", "O barco que me leve para casa." continuam a passar).
- Fixture inteira recomputada contra o padrão novo antes de a editar: as 19 casos pré-existentes
  mantêm o `reason` esperado (0 regressões), confirmado por script isolado.
- `uvx pytest -q scripts/tests`: 49 passed (antes da correcção: 47; +2 dos casos novos da fixture).
- `scripts/verify.sh` sem flags (carga no início, `uptime` 1min: 6,25 a 6,62, mais alta que o
  costume mas sem afectar esta corrida porque não toca no Ollama): `VEREDICTO: PASSOU` nas 7
  fases (docs, backlog, pytest, lint, import, gut, boot). GUT deu `Tests 76;Passing Tests 76`, o
  mesmo total de antes da correcção: os 2 casos novos entram como asserções dentro do mesmo
  `test_case_matches_python_eval` (percorre a fixture inteira num único teste GUT, não cria teste
  novo por caso), confirmado sem falhas no `reports/gut.log`. Paridade Python/GDScript mantida.
- As 40 frases aceites de `docs/proof/llm-eval-llama3.1_8b-2026-09-14.json` recomputadas contra o
  padrão novo, por script isolado, sem chamar o Ollama: 40/40 continuam com `reason: null`, zero
  mudanças de veredicto (nenhuma das 40 tem "vou"/"ia"/"podia"/"devia"/"queria" + pronome +
  infinitivo). A prova de 09-14 continua válida sem repetir o eval.

**Decisão: manter.** Corrige exactamente o bloqueante apontado, sem apanhar o falso positivo
pedido, sem regressão na fixture nem nas 40 frases da prova já aceite, sem custo de latência (é um
filtro offline, não toca no LLM).

### Prova final exigida (critério 3)

Carga antes: uptime 1min 12,15 -> à espera (loop de 10 s) -> 7,76 (< 8). Comando:
`python3 scripts/llm_eval.py --proof --samples 5`.

Resultado (`docs/proof/llm-eval-llama3.1_8b-2026-09-14.json`, ficheiro de trabalho
`reports/llm-eval-20260914-231512.json`):
- `pass_rate`: 1,0 (40/40, exigido >= 0,9)
- `latency_p50_s`: 3,03 s (limite 4,0 s)
- `latency_p95_s`: 4,74 s (limite 8,0 s)
- `rejections`: {} (nenhuma)
- `verdict`: PASSOU

### Efeito em cascata mecânico (fora dos 4 ficheiros, documentado por transparência)

Ao mudar `phrase_prompt.txt`, o teste GUT `test_prompt_builder.gd`
(`test_build_matches_python_render_for_tarde_pescar`) falhou porque compara `PromptBuilder.build`
contra um snapshot fixo, `game/tests/fixtures/prompt_tarde_pescar.txt`, gerado byte a byte a partir
do template. O próprio ficheiro de teste documenta o comando exacto de regeneração (comentário de
cabeçalho). Corri esse comando para regenerar o snapshot; não escrevi nada à mão, é uma
consequência mecânica e inevitável de mudar o prompt (o ficheiro não tem conteúdo próprio, é uma
cópia literal do template com um contexto fixo). Sinalizado aqui por transparência, já que não
está na lista dos 4 ficheiros com que a tarefa contava.

### `scripts/verify.sh --llm` (critério 5)

Primeira corrida (antes de regenerar o snapshot): `gut FALHOU` (1 teste, exactamente o
`test_prompt_builder.gd` acima), resto PASSOU, veredicto FALHOU.

Segunda corrida, depois de regenerar `game/tests/fixtures/prompt_tarde_pescar.txt` (carga antes:
uptime 1min 6,71, < 8):

```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (53 tarefas, 0 erros)
pytest       PASSOU         47 passed in 0.05s
lint         PASSOU         51 ficheiros próprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 76;Passing Tests 76
boot         PASSOU         BOOT_SMOKE PASSOU: fome -57.9 pontos, deslocação máxima 635 px
llm          PASSOU         pass_rate 1.0, p50 3.69s, p95 5.04s, rejections {}
llm_live     PASSOU         Tests 1;Passing Tests 1
VEREDICTO: PASSOU
```

### Resumo das tentativas

| # | Hipótese | Mudança | pass_rate antes -> depois | p50 antes -> depois | p95 antes -> depois | Decisão |
|---|---|---|---|---|---|---|
| 0 | (baseline) | nenhuma | - | - | - | referência: 0,975 / 3,27 s / 5,01 s |
| 1 | filtro não apanha "modal + pronome + infinitivo" | regra nova em `ptbr_patterns` + 3 casos na fixture | n/a (regra offline, não usa o LLM) | n/a | n/a | manter |
| 2 | prompt não restringe fauna/objectos da ilha | linha nova no prompt | 0,975 -> 0,975 | 3,27 s -> 3,16 s | 5,01 s -> 5,15 s | manter |
| final | (prova exigida) | mesma config da tentativa 2 | -> 1,0 | -> 3,03 s | -> 4,74 s | PASSOU |
| 1b | lista de verbos de `ptbr_patterns` sem `vou`/`ia`/`podia`/`devia`/`queria` (bloqueante do `insulano-reviewer`) | acrescentados os verbos em falta + `(?!calhar)` ao padrão 4 de `ptbr_patterns`, 2 casos novos na fixture | offline: 40/40 da prova continuam aceites, 0 regressões na fixture | n/a (não corre o LLM) | n/a (não corre o LLM) | manter |

Convergiu na tentativa 2 para o corpo principal da tarefa (2 tentativas, dentro do limite de 6); a
tentativa 1b é a 1.ª volta de correcção pós-revisão, sobre o mesmo padrão da tentativa 1.

### Critério 1 (regra nova + fixture): cumprido
Ver Tentativa 1 e a correcção da Tentativa 1b (lista de verbos incompleta, apontada pelo
`insulano-reviewer` como bloqueante). Ficheiros: `game/data/phrase_rules.json` (padrão em
`ptbr_patterns`, nota actualizada duas vezes), `game/tests/fixtures/phrase_filter_cases.json`
(3 casos da Tentativa 1 + 2 casos da Tentativa 1b, 5 no total).

### Critério 2 (prompt revisto): cumprido
Texto final acima, em `game/data/prompts/phrase_prompt.txt`.

### Critério 3 (`--proof --samples 5`, pass_rate >= 0,9): cumprido
`docs/proof/llm-eval-llama3.1_8b-2026-09-14.json`, pass_rate 1,0, PASSOU.

### Critério 4 (revisão do `insulano-reviewer`, >= 16/20 coerentes): cumprido
O `insulano-reviewer` classificou as 20 frases da secção abaixo: 16 coerentes em 20, cumpre o
limiar sem margem (o limiar é >= 16). O veredicto geral da volta de revisão foi ALTERAÇÕES
NECESSÁRIAS, com 1 bloqueante (a lista de verbos incompleta em `ptbr_patterns`, corrigida na
Tentativa 1b); a contagem de coerência do critério 4 em si não depende desse bloqueante e já está
satisfeita.

### Critério 5 (`scripts/verify.sh --llm` sem FALHOU): cumprido
Ver acima (segunda corrida, `VEREDICTO: PASSOU`). A primeira corrida tinha um FALHOU mecânico
(snapshot desactualizado, corrigido por regeneração, ver secção de efeito em cascata).

### Frases para classificação (classificação do `insulano-reviewer`, 16 coerentes em 20, critério cumprido sem margem)

As 20 frases vêm literalmente do JSON de `docs/proof/llm-eval-llama3.1_8b-2026-09-14.json`
(`--proof --samples 5`, o último eval, pass_rate 1,0), com o caso de origem de cada uma
(`evals/phrase_cases.json`). Classificação e motivos são do `insulano-reviewer`, colados aqui
literalmente (eu não classifico as minhas próprias frases).

| n.º | caso | frase | veredicto | motivo curto |
|---|---|---|---|---|
| 1 | manha-passear | Vou ver se consigo mais alguns peixes para a refeição do meio-dia. | coerente | |
| 2 | manha-passear | Ainda há um pedaço de coco no barril da praia para o almoço. | coerente | barril de destroço é plausível num náufrago |
| 3 | manha-passear | Vou pescar hoje, acho que não vou morrer de fome. | coerente | |
| 4 | tarde-pescar | Ainda não morro de fome, mas vou ter que comer peixe a jantar. | coerente | deslize de preposição ("ao jantar"), sentido intacto |
| 5 | tarde-pescar | Agora que peguei um peixe, para que é que eu vou fazer com ele? | incoerente | "peguei" é brasileiro (pt-PT "apanhei"); "para que é que vou fazer com ele" é agramatical |
| 6 | tarde-pescar | Fico aqui a pescar para comer no fim do dia. | coerente | |
| 7 | comer | Estou a comer este peixe porque a fome não é minha amiga. | coerente | |
| 8 | comer | Estou a comer o meu 15º peixe na semana. | coerente | |
| 9 | noite-dormir | Vou dormir com a sensação de ter vivido um dia completo em minha ilha. | incoerente | gramática brasileira: "em minha ilha" (pt-PT "na minha ilha") |
| 10 | noite-dormir | Vou ter de enfrentar mais uma noite de sono sem sonhos. | coerente | |
| 11 | chuva | A chuva é o meu único amigo de conversa hoje. | coerente | |
| 12 | chuva | Vou comer um peixe e esperar que a chuva passe logo. | coerente | |
| 13 | natal | Acho que o Natal é para quem tem alguém para o celebrar. | coerente | |
| 14 | natal | Vou dar umas voltas no barco distante e ver se tem algum Natal para mim. | incoerente | objecto impossível: não tem barco e usa o "barco distante" do prompt; "se tem" brasileiro (pt-PT "se há") |
| 15 | natal | Neste Natal, ainda estou aqui, sem um bom Natal para contar. | coerente | repetitiva, mas com sentido |
| 16 | gaivota | Só peixe para o almoço de novo hoje. | coerente | |
| 17 | gaivota | Estou com fome de novo. | coerente | |
| 18 | gaivota | Estou a ver uma gaivota a passar, com fome, sozinho aqui. | coerente | |
| 19 | barco | Espero que aquele barco seja o meu passaporte para sair desta ilha. | coerente | |
| 20 | barco | Aquele barco lá fora não veio me salvar ontem. | incoerente | gramática brasileira: próclise "veio me salvar" (pt-PT "não me veio salvar") |

**Critério usado para escolher estas 20 frases das 40 da prova:** não fui eu que escolhi (é o
`insulano-reviewer`, propositadamente, para não julgar as minhas próprias frases) e não há um
ficheiro dele no repositório com o critério explícito; o que tenho é a lista de índices que ele
devolveu (posições 1 a 40 na ordem de `docs/proof/llm-eval-llama3.1_8b-2026-09-14.json`): 1, 2, 4,
6, 9, 10, 11, 14, 16, 19, 21, 24, 26, 27, 30, 31, 33, 35, 38 e 39. A única leitura que consigo tirar
da distribuição, sem inventar uma regra que ele não me deu: cobre as 8 categorias do eval
(manha-passear, tarde-pescar, comer, noite-dormir, chuva, natal, gaivota, barco, 5 frases cada),
com 2 a 3 escolhidas por categoria. Fica registado como leitura minha da distribuição, não como
citação do critério real dele.

**Nota do revisor sobre as 40:** nas 40 frases da prova há 33 coerentes (82,5%), acima do limiar de
16/20 da amostra pedida pelo critério de aceitação.

### Revisão completa da linha de base

O report `reports/llm-eval-20260914-230758.json` (linha de base, antes de qualquer mudança desta
tarefa, pass_rate 0,975) tinha, além do que já ficou registado, mais quatro frases aceites dignas
de nota: "comer um ovo cozido", "sem saber se amanhã vou ter pão", "já devia ter me habituado" e
"coquinhos". Depois da Tentativa 2 (linha nova no prompt), o report `reports/llm-eval-20260914-231213.json`
teve mais duas: "tão ruim assim" e "um navio me levar".

O `pass_rate` de 1,0 na prova final (`docs/proof/llm-eval-llama3.1_8b-2026-09-14.json`) é variação
entre corridas do LLM face ao 0,975 da linha de base, não uma prova estatisticamente robusta de
melhoria: com 40 amostras e um LLM em CPU, uma diferença de 1 rejeição (`too_long: 1` na linha de
base) para zero cabe dentro do ruído normal de corrida a corrida. O efeito real da linha nova do
prompt (Tentativa 2, contra fauna/objectos impossíveis) não ficou medido isoladamente: a Tentativa
2 correu com `--samples 5` sem `--proof` (`reports/llm-eval-20260914-231213.json`, pass_rate 0,975,
igual à linha de base) e a prova final juntou essa mudança de prompt com o total de 40 amostras
`--proof`, sem uma corrida de controlo só com a regra do filtro e sem a linha nova do prompt para
isolar o efeito de cada mudança.

### Pontos em aberto (não tratar agora, fora do âmbito desta correcção)

- O prompt nomeia "barco distante" e o modelo copia-o literalmente na frase 14 ("Vou dar umas
  voltas no barco distante..."), que descreve uma acção impossível para um náufrago sem barco.
  Proposta do revisor: mudar a linha do prompt para algo como "um barco que às vezes passa ao
  longe e nunca pára" e tirar a lista de animais entre parênteses.
- Próclise fora da lista fechada de verbos modais desta tarefa (ex. "veio me salvar", "um navio me
  levar", ambos com um verbo pleno no passado, não um modal da lista `pode/deve/quer/vai/consegue`
  etc.) precisa de tarefa própria, com casos novos na fixture; a regra desta tarefa não cobre este
  padrão por desenho, não por lapso.
- "Levo a faca consigo se quiser pescar." é um falso positivo raro identificado pelo revisor,
  citado aqui só para registo, sem acção nesta correcção.

### Não verificado
- Não corri o eval contra o Ollama nesta correcção (instrução explícita da tarefa: a validação das
  40 frases da prova de 09-14 contra as regras novas foi feita offline, por script, sem chamar o
  Ollama).
- Não corri `scripts/verify.sh --full` (com `--visual`/`--export`) nesta correcção; corri sem flags
  (docs, backlog, pytest, lint, import, gut, boot), que é o que a mudança de `phrase_rules.json` e
  da fixture exige. `--full` não foi pedido pelos critérios de aceitação nem por esta correcção.
- O veredicto final da volta de revisão (ALTERAÇÕES NECESSÁRIAS -> aprovado ou nova volta) não é
  meu: depende de o `insulano-reviewer` confirmar que o bloqueante ficou corrigido.
