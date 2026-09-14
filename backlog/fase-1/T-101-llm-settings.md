---
id: T-101
titulo: LLMSettings com precedência env, user://settings.cfg e ProjectSettings
fase: 1
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
Toda a configuração do LLM é lida num único sítio, com defeitos no projecto e sobreposição pelo
utilizador e por variáveis de ambiente de teste.

## Ler antes
- `agent_docs/tech_design.md` §3 e §4.1

## Critérios de aceitação
- [x] `game/project.godot` tem as chaves `insulano/llm/*` da tabela do tech design, com `insulano/llm/model="llama3.1:8b"`
- [x] `game/llm/llm_settings.gd` (`class_name LLMSettings`) com `static func load_settings(cfg_path: String = "user://settings.cfg") -> LLMSettings`
- [x] Teste GUT: sem ficheiro nem env, valores iguais aos defeitos
- [x] Teste GUT: um `.cfg` temporário em `user://` sobrepõe `model` e `timeout_s`
- [x] Teste GUT: `INSULANO_LLM_URL` sobrepõe o `.cfg` (repor a variável no `after_each`)
- [x] `python3 scripts/check_docs.py` passa a verificar o modelo (sem a linha INFO de modelo adiado)
- [x] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- UI de configuração

## Prova exigida
- Testes `game/tests/unit/test_llm_settings.gd`

## Relatório

### O que mudou
- `game/project.godot`: secção nova `[insulano]` com `llm/enabled=true`, `llm/url="http://127.0.0.1:11434"`,
  `llm/model="llama3.1:8b"`, `llm/timeout_s=8.0`, `llm/min_interval_s=30.0` (as chaves `insulano/llm/*`
  do tech_design.md §3; as restantes chaves da tabela, `insulano/debug/*`, `insulano/events/*` e
  `insulano/weather/*`, ficam fora deste ficheiro porque pertencem às tarefas T-201/T-301/T-304/T-306,
  fora do âmbito desta tarefa).
- `game/llm/llm_settings.gd` (novo): `class_name LLMSettings extends RefCounted` com os cinco campos
  do contrato (`enabled`, `url`, `model`, `timeout_s`, `min_interval_s`) e
  `static func load_settings(cfg_path: String = "user://settings.cfg") -> LLMSettings`. Precedência
  implementada exactamente como o tech_design.md §4.1 e §3 descrevem: primeiro os defeitos do
  `ProjectSettings` (`insulano/llm/*`), depois a secção `[llm]` de `cfg_path` se o `ConfigFile.load`
  devolver `OK` (chave a chave, com o valor anterior como defeito de `get_value`), e por fim
  `INSULANO_LLM_URL`, que só sobrepõe `url` (é a única variável de ambiente de teste documentada
  para o LLM no §3; `model`/`timeout_s` só têm costura via `.cfg`, não há pedido nem contrato para
  variáveis de ambiente equivalentes).
- `game/tests/unit/test_llm_settings.gd` (novo, 4 testes GUT após a 2ª ronda de correcção): um por
  critério de aceitação (defeitos, override por `.cfg`, override por env) mais
  `test_project_settings_layer_is_actually_read`, que prova que a camada `ProjectSettings` é
  efectivamente lida em runtime (ver "Ronda de correcção 2" abaixo). `before_each` guarda o estado
  anterior de `INSULANO_LLM_URL` (valor e se existia, `_env_before`/`_env_existed_before`) e de
  `insulano/llm/model` (`_project_model_before`), e desliga a variável de ambiente antes de cada
  teste correr; `after_each` repõe exactamente esse estado (variável e `ProjectSettings`) e apaga o
  `.cfg` temporário.
- `docs/architecture.md`: mapa de componentes regenerado (`check_docs.py --fix`) para incluir a
  linha do `llm/llm_settings.gd`.
- `CHANGELOG.md`: entrada em `[Não lançado] > Adicionado` para o `LLMSettings`.

### Desvios do tech design
Nenhum. O contrato do §4.1 (assinatura de `load_settings`, campos, tipos) foi seguido à letra.

### Comandos corridos e resultado
- Teste a falhar pelo motivo certo antes da implementação (GDScript ainda sem `LLMSettings`):
  `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_llm_settings.gd`
  `SCRIPT ERROR: Parse Error: Identifier "LLMSettings" not declared in the current scope.` (o
  ficheiro fica de fora da corrida por não parsear; confirmado antes de escrever a implementação).
- `$(mise which godot) --headless --path game --import` `DONE` (regista a `class_name` nova).
- `uvx --from 'gdtoolkit==4.*' gdformat game/llm/llm_settings.gd game/tests/unit/test_llm_settings.gd`
  `1 file reformatted, 1 file left unchanged.`
- `uvx --from 'gdtoolkit==4.*' gdlint game/llm/llm_settings.gd game/tests/unit/test_llm_settings.gd`
  `Success: no problems found`
- Mesmo comando GUT de cima, depois da implementação `2/2 passed.` seguido do resumo global; valor
  final confirmado na última corrida desta ronda (2ª correcção, ver abaixo):
  `Scripts 9, Tests 25, Passing Tests 25, Asserts 57` (era `Scripts 8, Tests 21, Asserts 35` antes
  desta tarefa). Nota corrigida na revisão: `-gtest=` não restringe a corrida aos scripts do ficheiro
  indicado; o `.gutconfig.json` tem `dirs` com todos os testes, e o comando corre sempre os 9
  scripts todos (o `2/2 passed.` ou `1/1 passed.` é só a linha de resumo do próprio script pedido,
  dentro dessa corrida completa).
- `python3 scripts/check_docs.py` `FALHA [componentes] docs/architecture.md desactualizado`
  (esperado, por causa do ficheiro novo); `python3 scripts/check_docs.py --fix` 
  `INFO [componentes] docs/architecture.md regenerado` / `check_docs: PASSOU (0 falhas)`. A linha
  `INFO [modelo] project.godot ainda sem insulano/llm/model (entra na T-101)` já não aparece: a
  chave existe agora e o modelo `llama3.1:8b` já estava citado em `docs/api-ollama.md` e
  `agent_docs/tech_stack.md`, por isso a verificação `[modelo]` passa sem alterações a esses ficheiros.
- `scripts/verify.sh --quick` `docs PASSOU`, `backlog PASSOU (53 tarefas, 0 erros)`,
  `pytest PASSOU (40 passed)`, `lint PASSOU (33 ficheiros próprios limpos)`, `VEREDICTO: PASSOU`.
- `scripts/verify.sh` (sem flags) acrescenta `import PASSOU`, `gut PASSOU (Tests 24, Passing
  Tests 24)`, `boot PASSOU (BOOT_SMOKE PASSOU: fome -30.0 pontos, deslocação máxima 461 px)`,
  `VEREDICTO: PASSOU`. Sem FALHOU em nenhuma corrida.

### Auto-adversário (Lei 6)
1. Precedência trocada por engano (ex.: `.cfg` a sobrepor `ProjectSettings` antes do defeito, ou env
   a ganhar ao `.cfg` só por acaso): os três testes exercitam cada camada isoladamente
   (`test_defaults_...`, `test_cfg_file_overrides_model_and_timeout`,
   `test_env_var_overrides_cfg_url`, este último com o `.cfg` a definir um `url` diferente do env
   para provar que o env vence de facto e não por coincidência de valores). Uma inversão da ordem
   fazia um destes três falhar.
2. Fuga de estado entre testes (env por repor, ficheiro temporário por apagar): `after_each` chamado
   sempre, mesmo em testes que não tocam no ambiente; a suite completa correu 24/24 sem intermitência
   nem dependência de ordem (o `test_main_scene.gd`, que não tem nada a ver com LLM, continuou verde
   antes e depois).
3. Chave errada no `project.godot` (secção/caminho que o `ProjectSettings.get_setting` não encontra
   e cai sempre no defeito hardcoded, escondendo um `project.godot` desalinhado). Estado real depois
   das duas rondas de correcção do reviewer (a 2ª está detalhada em "Ronda de correcção 2" abaixo):
   a suite cobre `project.godot` (as chaves `insulano/llm/*` existem e têm os valores de §3, via
   `test_defaults_without_file_or_env`, linhas 51-60) E cobre que `load_settings` lê essas chaves em
   runtime (via `test_project_settings_layer_is_actually_read`, que muda `insulano/llm/model` para
   um valor sem correspondência nos defeitos hard-coded do `.gd` e afirma que `load_settings` o
   devolve). O que ainda NÃO fica coberto por este teste, por ser fora do âmbito desta tarefa: se o
   `LLMBridge` (T-105, ainda não existe) chama de facto `LLMSettings.load_settings()` em produção.

Pergunta de bolso: se a precedência estivesse trocada, a verificação apanhava? Sim: o teste
`test_env_var_overrides_cfg_url` define um `url` diferente no `.cfg` e outro no env e afirma o valor
do env; se o código aplicasse a ordem errada (ex.: `.cfg` depois do env), o `assert_eq` falharia com
o valor do `.cfg` em vez do env, e o `gut` do `verify.sh` reportaria FALHOU.

### Ronda de correcção (revisor, 2026-09-14)
O `insulano-reviewer` apontou 2 bloqueantes reais nos testes, confirmados por mutação:
1. `test_defaults_without_file_or_env` não provava nada sobre `project.godot` (só comparava contra
   os defeitos hard-coded do próprio `.gd`). Corrigido: o teste afirma agora, chave a chave, contra
   `ProjectSettings` (`has_setting` + `get_setting` com os valores de §3), antes da comparação contra
   o objecto. Reproduzi a mutação do reviewer (apagar a secção `[insulano]` do `project.godot`): antes
   da correcção, `Tests 24, Passing Tests 24` (não apanhava); depois da correcção, `Failing Tests 1`
   (apanha). Corrigi também o texto falso do auto-adversário #3 acima.
2. Faltava `before_each`: o teste de defeitos não limpava `INSULANO_LLM_URL` antes de correr e o
   `after_each` fazia `unset_environment` incondicional. Corrigido: `before_each` guarda o valor
   anterior (`_env_before`) e desliga a variável; `after_each` repõe esse valor se existia, ou
   desliga se não existia. Reproduzi a falha do reviewer
   (`INSULANO_LLM_URL=http://127.0.0.1:9` no ambiente antes do `gut_cmdln.gd`): antes da correcção
   falhava; com a correcção aplicada, `Tests 24, Passing Tests 24` (o valor pré-existente do
   ambiente já não interfere).

Também corrigido, dos "a melhorar" pedidos: a afirmação errada em `backlog/fase-1/T-101-llm-settings.md`
sobre `-gtest=` restringir a corrida (confirmado por comando real: corre sempre os 9 scripts / 24
testes, `-gtest=` não filtra scripts). O ponto sobre `DirAccess.remove_absolute` já usava
`globalize_path` no ficheiro entregue; não havia nada para corrigir aí.

Depois da correcção: `scripts/verify.sh --llm` `VEREDICTO: PASSOU` (docs, backlog, pytest, lint,
import, `gut PASSOU Tests 24;Passing Tests 24`, boot, `llm PASSOU pass_rate 0.9167`). Sem commit,
como pedido.

### Ronda de correcção 2 (revisor, 2026-09-14)
O `insulano-reviewer` deu BLOQUEANTE de novo, confirmado por mutação: a camada `ProjectSettings` do
contrato §4.1 continuava sem cobertura efectiva, apesar do Relatório dizer o contrário no ponto #3
acima. `test_defaults_without_file_or_env` (linhas 51-60) prova que as chaves existem no motor com
os valores certos, mas isso é uma afirmação sobre `project.godot`, não sobre `load_settings`: como
os defeitos hard-coded de `llm_settings.gd:11-19` são iguais aos valores de §3, apagar a leitura de
`ProjectSettings` em `load_settings` (as 7 linhas 32-38) ou trocar os caminhos de chave
(`insulano/llm/model` -> `.../modelo`, `.../url` -> `.../endpoint`) não fazia nenhum teste falhar: o
objecto continuava a devolver os mesmos valores, só que vindos do `.gd`, não do motor.

Correcção: teste novo `test_project_settings_layer_is_actually_read`
(`game/tests/unit/test_llm_settings.gd:93-102`), que muda `insulano/llm/model` para
`"modelo-de-prova"` (valor que os defeitos hard-coded não têm) e afirma que `load_settings` o
devolve. `before_each`/`after_each` guardam e repõem `insulano/llm/model` (`_project_model_before`)
para não sujar o `ProjectSettings` global entre testes; confirmado pela corrida completa da suite a
seguir (nenhum outro teste, incluindo os que já existiam, ficou afectado pela mudança e reposição).

Sequência de verificação (Lei 4/5, prova por mutação, nunca só leitura de código):
1. Teste escrito, corrido HOJE no repositório real, sem qualquer mutação: PASSOU
   (`Scripts 9, Tests 25, Passing Tests 25, Asserts 57`), porque a leitura de `ProjectSettings` já
   existia em `load_settings` desde a 1ª ronda.
2. Mutação 1 (apagar as 7 linhas de leitura de `ProjectSettings` em `load_settings`, linhas 32-38),
   aplicada numa CÓPIA de `game/` em `/tmp/.../scratchpad/game-mutation` (nunca no repositório
   real): a suite passou a dar `Passing Tests 24, Failing Tests 1`, com
   `test_project_settings_layer_is_actually_read` a falhar
   (`["llama3.1:8b"] expected to equal ["modelo-de-prova"]`). Apanha.
3. Mutação 2 (trocar os caminhos de chave, `insulano/llm/model` -> `.../modelo`,
   `insulano/llm/url` -> `.../endpoint`), na mesma cópia: mesmo resultado,
   `Passing Tests 24, Failing Tests 1`, mesma falha. Apanha.
4. Cópia de mutação apagada depois de confirmar as duas mutações; nenhuma delas tocou o repositório
   real.

Pergunta de bolso: se a leitura de `ProjectSettings` fosse removida de `load_settings` (ou lesse a
chave errada), a verificação apanhava? Sim, confirmado pelas duas mutações acima, não só por
raciocínio: `test_project_settings_layer_is_actually_read` falha nos dois casos porque o valor
`"modelo-de-prova"` só chega a `settings.model` se o código ler mesmo `ProjectSettings` com o
caminho de chave certo; os defeitos hard-coded do `.gd` nunca produzem esse valor.

Também corrigidos, dos "a melhorar" mais baratos apontados nesta ronda:
- `_env_before` agora vem acompanhado de `_env_existed_before` (`OS.has_environment`), para
  distinguir "a variável não existia" de "existia com valor vazio"; sem isto, `after_each` apagaria
  por engano uma `INSULANO_LLM_URL=""` pré-existente em vez de a repor.
- O número de Asserts no ponto "Comandos corridos e resultado" foi actualizado de `46` (valor
  desactualizado, de uma corrida anterior a esta ronda) para `57`, o valor real da corrida final
  depois desta correcção.
- A secção "O que mudou" passa a mencionar o `before_each` (guarda de estado) e não só o
  `after_each` (reposição), que é o par completo do padrão save/restore usado nos dois casos
  (ambiente e `ProjectSettings`).

Depois desta correcção: `scripts/verify.sh --llm` `VEREDICTO: PASSOU` (docs, backlog, pytest, lint,
import, `gut PASSOU Tests 25;Passing Tests 25`, boot, `llm PASSOU pass_rate 0.9167`). Uma corrida
intermédia do `llm` deu `FALHOU` com `pass_rate 0.5417` e 9 timeouts; investigado antes de repetir
(Lei 5, nunca reportar sem causa): a máquina tinha, na mesma janela, um segundo `llama-server` do
Ollama a arrancar (modelo de embeddings, processo separado) e uma VM QEMU (`dockurr/windows`) a
subir, com `load average` de ~14 num CPU de 16 threads (memória `ollama-docker-exposto-cpu.md`:
Ollama corre em CPU, sem GPU, já é conhecido como sensível a contenção). Confirmado ambiental e não
uma regressão desta tarefa: correr só `python3 scripts/llm_eval.py` a seguir, sem mais nada a
competir por CPU, deu `pass_rate 1.0`; o `verify.sh --llm` completo a seguir deu `pass_rate 0.9167`,
igual à 1ª ronda. Sem commit, como pedido.

### Não verificado
- Não foi preciso `--visual` (tarefa `codigo`, sem UI).
- Não corri `scripts/verify.sh --full` (inclui export, fora do âmbito desta tarefa; a T-109 fecha a
  fase). O comportamento do `LLMBridge` a consumir `LLMSettings` fica para a T-105, que ainda não
  existe: esta tarefa só prova a leitura de configuração isolada.

### Estado final

Estado: **feito**. Confirmado pelo `insulano-verifier` (PASSOU) e pelo `insulano-reviewer`
(APROVADO, sem bloqueantes) na terceira e última volta, depois de duas rondas de correcção
(teste de defeitos sem cobertura real do `project.godot`; falta de isolamento de estado entre
testes; cobertura da camada `ProjectSettings` provada só para uma mutação). Ponto "a melhorar"
deixado para trás (não bloqueante): a camada `ProjectSettings` só está provada por mutação para a
chave `model`; as outras quatro (`enabled`, `url`, `timeout_s`, `min_interval_s`) partilham o
mesmo defeito hard-coded em `llm_settings.gd` e `project.godot`, por isso uma troca de caminho só
nessas chaves passaria despercebida. Fica registado para uma tarefa de higiene futura ou para
quando a T-105 (`LLMBridge`) as usar directamente.
