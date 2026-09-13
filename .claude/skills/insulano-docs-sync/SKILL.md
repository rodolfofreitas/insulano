---
name: insulano-docs-sync
description: Sincroniza a documentação do Insulano com o código real em três passos (scan, generate, check), sem inventar intenção. Usar depois de mudar contratos, ficheiros .gd, comandos, versões ou dados; no fecho de cada fase; quando o check_docs falha; ou quando alguém pergunta "os docs estão actualizados?".
---

# Sincronizar documentação e código

A documentação do Insulano tem duas camadas: **harness** (AGENTS.md, `agent_docs/`, backlog: serve quem
constrói) e **artefactos** (README, `docs/`: serve humanos e o próximo agente). Esta skill mantém as duas
fiéis ao código. O mecânico está no `scripts/check_docs.py`; o resto é este procedimento.

## 1. Scan: o que mudou e onde pode haver deriva

```bash
cd ~/Programacao/Kaeto/Insulano
python3 scripts/check_docs.py                         # deriva mecânica
git log --oneline -n 20
git diff --stat HEAD~5 -- game scripts                # ajustar o intervalo ao trabalho feito
grep -rn "^class_name\|^signal\|^func [a-z]" game --include=*.gd | grep -v addons   # superfície pública real
```

Para cada componente com tarefa `feito`, compara a superfície pública real com `agent_docs/tech_design.md`:
nome da classe, funções públicas, sinais, chaves de settings, caminhos de dados, estado (`existe`/`planeado`).

Lista também:
- comandos em `README.md` e `docs/runbook.md` ainda sem data de execução;
- versões em `agent_docs/tech_stack.md` contra `mise.toml`, `plugin.cfg` dos addons e `gdlint --version`;
- modelos e medições em `docs/api-ollama.md` contra os relatórios em `docs/proof/`.

## 2. Generate: corrigir, pela ordem certa

1. `python3 scripts/check_docs.py --fix` (mapa de componentes da arquitectura).
2. `tech_design.md`: estado dos componentes e contratos que o código já cumpre. Se o código contradiz o contrato
   e a tarefa não justificou a mudança, **não** mudes o documento: cria tarefa `fix` com `/insulano-new-task`.
3. `docs/architecture.md` §4.1, §4.2 e §8 quando um bloco ou um risco mudou.
4. `README.md` "Estado", `docs/runbook.md` (correr os comandos não destrutivos e datar), `tech_stack.md`.
5. `CHANGELOG.md`: cada tarefa feita desde a última entrada tem uma linha em linguagem de utilizador.
6. `AGENTS.md` §9 e §10 se apareceu uma armadilha nova num Relatório.

Regras: o código diz o que existe, as tarefas e ADRs dizem o que devia existir; nunca copiar texto com fonte
única (prompt, regras, versões fixadas), apontar para o ficheiro; `docs/threat_model.md` não se toca
(propostas em `docs/threat_model-propostas.md`).

## 3. Check: provar que ficou fiel

```bash
python3 scripts/check_docs.py        # PASSOU
python3 scripts/backlog.py check     # PASSOU
scripts/verify.sh --quick
```

Reporta: derivas encontradas (documento, o que dizia, o que é verdade, evidência), correcções feitas, tarefas
criadas, e comandos documentados que continuam por executar.
