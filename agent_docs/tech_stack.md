# Tech Stack: Insulano

Versões verificadas nesta máquina a 2026-09-13. Mudar uma versão exige correr `scripts/verify.sh --full`
e actualizar esta tabela no mesmo commit.

## Tabela de versões

| Componente | Versão | Onde está fixada | Como se obtém |
|---|---|---|---|
| Godot Engine | 4.7.2 stable | `mise.toml` | `mise install` |
| GDScript | 2.0 (Godot 4) | - | - |
| Renderer | Compatibility (OpenGL 3.3) | `game/project.godot` | ADR-007 |
| Beehave (behavior trees) | 2.8.3 (2.9.3 na T-005) | `game/addons/beehave/plugin.cfg` | vendorizado da base |
| GUT (testes) | 9.7.1 | `game/addons/gut/` | `gh release download v9.7.1 -R bitwes/Gut` |
| gdtoolkit (gdlint, gdformat) | 4.5.0 | `scripts/verify.sh` (`gdtoolkit==4.*`) | `uvx` |
| Python (scripts do harness) | 3.11+ (testado em 3.14) | - | sistema |
| pytest | o mais recente | `scripts/verify.sh` | `uvx pytest` |
| Ollama | contentor Docker `ollama`, só CPU | fora do repositório | já instalado |
| Modelo LLM | `llama3.1:8b` (Q4_K_M, 8B) | `insulano/llm/model` (T-101) | já instalado |

## Porque é que é esta stack

- **Godot 4 + GDScript:** a base já é Godot 4; `HTTPRequest` nativo para o Ollama; export Linux,
  Windows e Web; licença MIT; corre headless para testes automáticos.
- **Beehave:** a behavior tree da base está feita nele; decisão explícita sobre o que o personagem faz.
- **GUT:** framework de testes GDScript puro com CLI headless e JUnit XML; sem dependência de C#.
- **gdtoolkit via uvx:** lint e formatação reproduzíveis sem instalar nada globalmente.
- **Ollama local:** zero custo, privacidade total (ADR-002). O modelo foi escolhido por medição (ADR-006).

## API do Beehave usada (2.x)

Não existe `BTAction`. Folhas:

```gdscript
extends ActionLeaf        # ou ConditionLeaf
func tick(actor: Node, blackboard: Blackboard) -> int:
	return SUCCESS         # SUCCESS, FAILURE ou RUNNING
```

Compostos usados na cena `guy.tscn`: `SequenceComposite`, `SelectorComposite`, `SelectorRandomComposite`.

## Assets

Registo completo, com licenças e obrigações: [`../docs/assets-licencas.md`](../docs/assets-licencas.md).

## APIs externas

| Serviço | Uso | Estado | Chave |
|---|---|---|---|
| Ollama `POST /api/generate` | frases | local, obrigatório com fallback | não |
| wttr.in `?format=j1` | clima real | opcional, desligado por defeito (T-304, T-306) | não |

Detalhe do Ollama: [`../docs/api-ollama.md`](../docs/api-ollama.md).

## Ferramentas de desenvolvimento

| Ferramenta | Uso |
|---|---|
| `mise` | fixar a versão do Godot |
| `uv` / `uvx` | gdtoolkit e pytest sem instalação global |
| `gh` | descarregar releases de addons |
| Docker | o Ollama corre no contentor `ollama` (`docker exec ollama ollama list`) |
| git | controlo de versão; `core.hooksPath .githooks` |
