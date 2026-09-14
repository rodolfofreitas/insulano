# Testes: Insulano

Um protector de ecrã tem muita lógica testável (quando falar, o que dizer, que cor tem o céu às 19h,
quando é a Páscoa) e uma parte que só se vê. Os dois lados são verificados; nenhum é "subjectivo demais
para testar" sem que isso fique escrito e com revisão definida.

## 1. Pirâmide

| Nível | Ferramenta | Onde | Prova | Corre em |
|---|---|---|---|---|
| Scripts do harness | pytest | `scripts/tests/` | que o próprio portão não mente | `verify.sh --quick` |
| Unitário | GUT | `game/tests/unit/` | lógica pura: filtro, prompt, cores, datas | `verify.sh` |
| Integração | GUT | `game/tests/integration/` | cenas instanciam, sinais, fallback com rede inacessível | `verify.sh` |
| Smoke de arranque | `game/tools/boot_smoke.gd` | headless, 90 s simulados | o jogo vive: fome desce, personagem mexe-se, sem SCRIPT ERROR, e (desde a T-106) o personagem diz pelo menos uma frase de `phrases_fallback.json` com `INSULANO_LLM_URL` numa porta morta | `verify.sh` |
| Visual | `game/tools/capture.gd` | PNG 1280x720 | o que um humano veria; o agente abre a imagem | `verify.sh --visual` |
| LLM | `scripts/llm_eval.py` | contra o Ollama | latência, pt-PT, comprimento, conteúdo | `verify.sh --llm` |
| Ao vivo | GUT | `game/tests/live/` | ponte real contra o Ollama (a partir da T-105) | `verify.sh --llm` |
| Export | `scripts/export.sh` | `dist/linux/` | o binário real arranca | `verify.sh --export` |
| Documentação | `scripts/check_docs.py` | todo o repositório | links, travessões, docstrings, mapa de componentes | `verify.sh --quick` |

**Buraco conhecido:** nenhum destes portões exercita a árvore de comportamento inteira a falar
contra um Ollama real ao mesmo tempo ("árvore mais HTTP real"). O `llm_live` (linha "Ao vivo") só
testa a ponte (`LLMBridge`) isolada; o boot smoke fala com uma porta morta de propósito
(determinístico, sempre fallback); e o `llm_eval.py` testa o `PromptBuilder`/`PhraseFilter` fora da
árvore. A verificação de que a `SayGeneratedAction` na árvore real fala coerentemente com um Ollama
a responder é manual (captura visual + inspecção, T-106).

## 2. Comandos

```bash
scripts/verify.sh --quick                      # antes de cada commit (pre-commit)
scripts/verify.sh                              # antes de marcar uma tarefa feita
scripts/verify.sh --visual                     # tarefas visuais
scripts/verify.sh --llm                        # tarefas que tocam prompt, regras ou ponte
scripts/verify.sh --full                       # fecho de fase

# Um só ficheiro GUT
$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd \
  -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_need.gd

# Um só teste GUT
... -gtest=res://tests/unit/test_need.gd -gunit_test_name=test_percentage_is_relative_to_max_value

# Captura a uma hora concreta (a partir da T-201)
INSULANO_FAKE_TIME=2026-12-25T21:30 $(mise which godot) --rendering-driver opengl3 --fixed-fps 60 \
  --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/natal.png --frames=300
```

Relatórios em `reports/` (ignorado pelo git): `verify-last.txt`, `gut.log`, `gut-junit.xml`, `boot.log`,
`verify-latest.png`, `llm-eval-*.json`.

## 3. Como escrever um teste GUT

```gdscript
extends GutTest
## Testes do PhraseFilter contra a fixture partilhada com o eval em Python.

var _filter: PhraseFilter


func before_each() -> void:
	_filter = PhraseFilter.from_rules_file()


func test_rejects_brazilian_voce() -> void:
	assert_eq(_filter.rejection_reason("Você viu o barco?"), "ptbr")
```

- Asserções mais usadas: `assert_eq`, `assert_ne`, `assert_true`, `assert_null`, `assert_not_null`,
  `assert_almost_eq`, `assert_signal_emitted`, `watch_signals`.
- Esperar por um sinal: `await wait_for_signal(obj.sinal, 10)`.
- Nós criados no teste: `add_child_autofree(no)`.
- Variáveis de ambiente mudadas no teste (`OS.set_environment`) repõem-se em `after_each`.

## 4. Regras

1. **Teste primeiro, a falhar pelo motivo certo.** Um teste que passa antes da implementação não prova nada.
2. **Sem rede** em unit e integration. Respostas gravadas em `game/tests/fixtures/`.
3. **Determinismo.** `seed()` fixa, `INSULANO_FAKE_TIME`, `--fixed-fps 60`. Um teste intermitente é um bug:
   corrige-se a causa, nunca se repete até passar.
4. **Paridade.** Regras usadas pelo jogo e pelo eval testam-se contra a mesma fixture nos dois lados.
5. **O Godot sai com 0 com erros de script.** Nunca confiar só no código de saída: o `verify.sh` lê os logs.
6. **Regressão.** Cada defeito corrigido ganha `test_regression_<bug>`.

## 5. O que não é automático, e quem decide

| Aspecto | Porque não é automático | Como se verifica |
|---|---|---|
| Graça e coerência das frases | juízo humano | revisão amostral de 20 frases por um agente que não escreveu o prompt (T-108); o Rodolfo no fecho de fase |
| Beleza da paleta e dos efeitos | juízo visual | screenshots em `docs/proof/` inspeccionados; o Rodolfo aprova no fecho de fase |
| Uso prolongado (horas) | custo de tempo | corrida de 10 minutos no fecho de fase (T-109); horas de uso real pelo Rodolfo (Fase 5) |
| Integração com o hypridle | vive fora do repositório | T-502, manual |
