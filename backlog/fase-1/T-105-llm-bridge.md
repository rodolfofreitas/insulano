---
id: T-105
titulo: LLMBridge assíncrono com timeout, filtro e fallback garantido
fase: 1
estado: feito
tipo: codigo
depende_de: [T-101, T-102, T-103, T-104]
---

## Objectivo
Qualquer parte do jogo pede uma frase e recebe exactamente uma resposta, do LLM ou do fallback,
sem nunca bloquear um frame.

## Ler antes
- `agent_docs/tech_design.md` §4.5 (contrato de comportamento completo), `docs/api-ollama.md`

## Critérios de aceitação
- [x] `game/llm/llm_bridge.gd` registado como autoload `LLM` em `project.godot`
- [x] Teste GUT unit: `build_payload` igual ao payload documentado em `docs/api-ollama.md`
- [x] Teste GUT unit: `parse_response` com fixtures `game/tests/fixtures/ollama_ok.json`, `ollama_empty.json`, `ollama_invalid.txt` e código 500
- [x] Teste GUT integração: `INSULANO_LLM_URL=http://127.0.0.1:9` emite `phrase_ready` com `source == "fallback"` em menos de `timeout_s + 1` s
- [x] Teste GUT integração: com `enabled = false` emite fallback sem criar pedido HTTP
- [x] Teste GUT integração: dois pedidos seguidos, o segundo recebe fallback imediato; cada `request_id` recebe um e um só sinal
- [x] Teste ao vivo em `game/tests/live/test_llm_live.gd` (fora do `.gutconfig.json`), corrido pelo `scripts/verify.sh --llm` quando o Ollama responde; `verify.sh` alterado para isso
- [x] `scripts/verify.sh --llm` sem FALHOU

## Fora de âmbito
- Ligar à behavior tree (T-106)
- Streaming de tokens

## Prova exigida
- Testes listados; excerto do log `[Insulano/LLM]` com latência de uma chamada real no Relatório

## Relatório

Estado deixado em `em-curso`: implementação completa e `scripts/verify.sh --llm` a PASSOU, mas
quem julga o veredicto final é o `insulano-verifier`, não quem construiu (AGENTS.md §7).

### O que mudou

- `game/llm/llm_bridge.gd` (novo): `class_name LLMBridge extends Node`, com o contrato exacto do
  tech_design.md §4.5 (`phrase_ready`, `request_phrase`, `is_busy`, `build_payload`,
  `parse_response`). `settings`/`filter`/`fallback`/`template` são injectáveis pelos testes (nulos
  em jogo, carregados em `_ready()` a partir dos defeitos reais de `LLMSettings.load_settings()`,
  `PhraseFilter.from_rules_file()`, `FallbackPhrases.from_file()` e `PromptBuilder.load_template()`).
  O `HTTPRequest` filho só é criado no primeiro pedido REAL (nunca com `enabled = false`), o que
  torna o critério "sem criar pedido HTTP" verificável de fora (contando filhos do nó).
- `game/project.godot`: `LLM="*res://llm/llm_bridge.gd"` na secção `[autoload]`.
- `game/tests/unit/test_llm_bridge.gd` (novo): `build_payload` contra o payload exacto de
  `docs/api-ollama.md`; `parse_response` contra as 3 fixtures novas mais o caso HTTP 500 (corpo
  válido, código mau) e o caso de falha de rede (sem fixture, só `result`).
- `game/tests/fixtures/ollama_ok.json`, `ollama_empty.json`, `ollama_invalid.txt` (novas, pedidas
  pela tarefa; não existiam).
- `game/tests/integration/test_llm_bridge.gd` (novo): os 3 cenários de concorrência/timing do
  contrato, todos contra portas mortas (127.0.0.1:9), nunca contra o Ollama real.
- `game/tests/live/test_llm_live.gd` (novo): teste com o Ollama real, fora de `tests/unit` e
  `tests/integration` (por isso já fora do `.gutconfig.json`, que só lista essas duas pastas em
  `dirs`, sem precisar de alterar esse ficheiro). Marca-se `pending()` se o Ollama não responder
  (`GET /api/tags`), em vez de falhar: um Ollama parado é estado válido do jogo, não bug da ponte.
- `scripts/verify.sh`: a secção `--llm` passa a correr também este teste ao vivo, invocando o
  `gut_cmdln.gd` com `-gconfig=` (vazio, ignora o `.gutconfig.json` de propósito) e
  `-gdir=res://tests/live -ginclude_subdirs`, com as mesmas flags de saída
  (`-gexit -gexit_on_success -gignore_pause -ghide_orphans`) da secção GUT principal. Comentário do
  cabeçalho do script actualizado.
- `docs/architecture.md`: regenerado por `check_docs.py --fix` (linha do componente `LLMBridge`).
- `CHANGELOG.md`: entrada em `[Não lançado]` § Adicionado.

### Desvio ao processo (registado, não silencioso)

Nenhum desvio ao contrato do tech_design.md §4.5: a assinatura, os sinais e a precedência de
fallback ficaram exactamente como especificado. Um bug real foi apanhado e corrigido durante a
escrita do próprio teste ao vivo (não do código de produção): a função auxiliar
`_ollama_is_up()` em `test_llm_live.gd` usava duas variáveis locais `bool` capturadas por uma
lambda do `request_completed`; o GDScript captura variáveis locais de tipo valor por CÓPIA, não
por referência, por isso a escrita feita dentro da lambda nunca chegava ao resto da função e o
teste marcava sempre `pending()`, mesmo com o Ollama a responder (visto directamente: o mesmo
teste, corrido a seguir sem qualquer outra mudança, passou). Corrigido substituindo os dois
`bool` por um `Dictionary` (tipo referência), o mesmo padrão já usado para juntar sinais em
`_collect_phrase_ready()` nos outros ficheiros de teste desta tarefa.

### Testes e comandos corridos

- `uvx --from 'gdtoolkit==4.*' gdformat` e `gdlint` em todos os ficheiros `.gd` novos/tocados:
  limpo.
- `godot --headless --path game --import`: sem `SCRIPT ERROR` nem `Parse Error`.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json`:
  49 testes (todos os de `tests/unit` e `tests/integration`, incluindo os 9 novos desta tarefa),
  49 a passar, 0 a falhar.
- `godot --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig= -gdir=res://tests/live
  -ginclude_subdirs -gprefix=test_ -gsuffix=.gd -gexit -gexit_on_success -gignore_pause
  -ghide_orphans`: corrido isoladamente várias vezes durante o desenvolvimento (uma vez apanhou o
  timeout genuíno de um pedido real que excedeu `timeout_s` = 8 s, RESULT_TIMEOUT, fonte=fallback;
  as corridas seguintes, com o modelo já carregado, ficaram entre 2,9 s e 4,4 s e passaram com
  `source == "llm"`; latência real medida, não simulada).
- `scripts/verify.sh --llm`: **PASSOU** (2 corridas seguidas, a última depois da entrada no
  CHANGELOG):

```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (53 tarefas, 0 erros)
pytest       PASSOU         44 passed in 0.05s
lint         PASSOU         44 ficheiros próprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 49;Passing Tests 49
boot         PASSOU         BOOT_SMOKE PASSOU: fome -30.0 pontos, deslocação máxima 616 px
llm          PASSOU         {"model": "llama3.1:8b", "samples": 24, "pass_rate": 0.9583, ...}
llm_live     PASSOU         Tests 1;Passing Tests 1
VEREDICTO: PASSOU
```

- `scripts/verify.sh --quick`: PASSOU (docs, backlog, pytest, lint).

### Prova exigida: excerto do log `[Insulano/LLM]` com latência de uma chamada real

Da última corrida de `scripts/verify.sh --llm` (`reports/gut-live.log`):

```
[Insulano/LLM] modelo=llama3.1:8b latencia=4.03s fonte=llm
[Insulano/LLM] teste ao vivo: modelo=llama3.1:8b source=llm latencia=4.04s texto=Vou continuar a viver nesta ilha até que alguém achar me lá.
```

### O que não ficou verificado

- Comportamento sob carga (muitos pedidos concorrentes de sistemas diferentes, ex. gaivota e barco
  ao mesmo tempo): fora de âmbito desta tarefa (T-106, T-302, T-303 ainda não existem chamadores).
- Reconexão do Ollama a meio de um pedido em curso (parar e religar o contentor durante um
  `request_phrase`): não testado; o contrato só exige fallback em timeout/erro, que está coberto.
- O `insulano-reviewer` ainda não reviu este diff; fica para o passo seguinte do loop.

### Ronda de correcção pós-revisão (2026-09-14)

O `insulano-reviewer` apanhou 1 BLOQUEANTE real: `scripts/verify.sh:167-168` gravava
`llm_live PASSOU` mesmo quando o único teste ao vivo se limitou a `pending()` (Ollama parado),
porque o GUT sai com 0 nesse caso. Isto contradizia o próprio cabeçalho do script (linhas 13-14,
"nunca é tratado como passou") e tornava o critério de aceitação "`scripts/verify.sh --llm` sem
FALHOU" satisfazível sem nunca falar com o Ollama.

Corrigido em `scripts/verify.sh`: antes de gravar o resultado do passo `llm_live`, o script extrai
agora o campo `Risky/Pending` já capturado em `$live_totals` (linha 166, antes ignorado); se for
maior que 0, grava `INDETERMINADO` em vez de `PASSOU`, com a mesma semântica do passo `llm`
imediatamente acima para o mesmo cenário (Ollama em baixo). Confirmado por ataque manual, com o
Ollama real desta máquina:

- `scripts/verify.sh --llm` com o Ollama a responder: `llm_live PASSOU Tests 1;Passing Tests 1`,
  `VEREDICTO: PASSOU`, exit 0.
- `INSULANO_LLM_URL=http://127.0.0.1:9 scripts/verify.sh --llm` (Ollama simulado parado):
  `llm_live INDETERMINADO teste ao vivo saltado (Ollama não respondeu); Tests 1;Passing Tests
  none;Risky/Pending 1`, `VEREDICTO: INDETERMINADO`, exit 3 (confirmado com `echo $?` a seguir à
  corrida, não só pela leitura do resumo).

Também corrigidos os dois pontos "a melhorar" pedidos pelo reviewer:
- `game/tests/unit/test_llm_bridge.gd:6` e `game/tests/integration/test_llm_bridge.gd:6-8`:
  citação errada "AGENTS.md §10.9" (essa secção não existe; `AGENTS.md` só tem `## 10. Armadilhas
  conhecidas`, sem subsecções numeradas) trocada pela citação correcta,
  `agent_docs/testing.md:16-17` (linha da tabela "Ao vivo", que é onde a regra "rede real só em
  game/tests/live/" está escrita).
- `README.md:70`: linha do `scripts/verify.sh --llm` actualizada de "mais eval das frases contra o
  Ollama" para "mais eval das frases e teste ao vivo contra o Ollama", a reflectir o comportamento
  desde esta tarefa.

Não tocados (fora do pedido desta ronda, deixados para os "a melhorar" do reviewer que não eram
bloqueantes): emissão síncrona de fallback antes do `request_id`, guarda de `request_completed`
sem pedido em curso, barra final na URL, log duplicado, `HTTPRequest` do teste ao vivo vs
`code_patterns.md` §6, teste de timeout que nunca exercita `RESULT_TIMEOUT`, `--quick`+`--llm`.

Verificação corrida nesta ronda: `bash -n scripts/verify.sh` (sintaxe), `gdlint`/`gdformat --check`
nos dois ficheiros `.gd` tocados (limpo), `scripts/verify.sh --quick` (PASSOU), e as duas corridas
de ataque de `scripts/verify.sh --llm` acima. Estado deixado em `em-curso`: o veredicto final
continua a ser do `insulano-verifier`/`insulano-reviewer`, não de quem corrigiu.
