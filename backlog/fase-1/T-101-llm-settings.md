---
id: T-101
titulo: LLMSettings com precedência env, user://settings.cfg e ProjectSettings
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-001]
---

## Objectivo
Toda a configuração do LLM é lida num único sítio, com defeitos no projecto e sobreposição pelo
utilizador e por variáveis de ambiente de teste.

## Ler antes
- `agent_docs/tech_design.md` §3 e §4.1

## Critérios de aceitação
- [ ] `game/project.godot` tem as chaves `insulano/llm/*` da tabela do tech design, com `insulano/llm/model="llama3.1:8b"`
- [ ] `game/llm/llm_settings.gd` (`class_name LLMSettings`) com `static func load_settings(cfg_path: String = "user://settings.cfg") -> LLMSettings`
- [ ] Teste GUT: sem ficheiro nem env, valores iguais aos defeitos
- [ ] Teste GUT: um `.cfg` temporário em `user://` sobrepõe `model` e `timeout_s`
- [ ] Teste GUT: `INSULANO_LLM_URL` sobrepõe o `.cfg` (repor a variável no `after_each`)
- [ ] `python3 scripts/check_docs.py` passa a verificar o modelo (sem a linha INFO de modelo adiado)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- UI de configuração

## Prova exigida
- Testes `game/tests/unit/test_llm_settings.gd`

## Relatório
(preenchido pelo executor)
