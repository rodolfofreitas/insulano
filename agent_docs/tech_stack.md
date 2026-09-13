# Tech Stack — Insulano

## Motor de jogo

**Godot 4.x** (versão estável mais recente)
- Linguagem: GDScript (não C#)
- Export targets: Linux x86_64, Windows x86_64, HTML5 (WebGL2)
- Renderer: Forward+ (padrão Godot 4)

Por que Godot 4 e não Unity/Pygame/Raylib:
- Guy on Island já usa Godot 4 — base de código herdada
- Export multi-plataforma com um clique
- GDScript tem HTTPRequest nativo (necessário para Ollama)
- Licença MIT — sem royalties, sem restrições comerciais

## Behaviour Trees

**Beehave** plugin para Godot 4
- Repositório: https://github.com/bitbra-in/beehave
- Versão: estável do Godot Asset Library
- Uso: árvore de decisão do personagem (o que fazer em cada momento)

Estrutura da árvore (herdada do Guy on Island, a expandir):

    Selector (raiz)
      ├── Sequence: tem fome?
      │     ├── Condition: hunger < threshold
      │     └── Action: GoFish → Eat
      ├── Sequence: tem frase para dizer?
      │     ├── Condition: llm_response ready
      │     └── Action: Say
      └── Action: WalkToRandom (idle)

## LLM local

**Ollama** — servidor HTTP local, porta 11434
- URL base: http://localhost:11434
- Endpoint usado: POST /api/generate
- Modelos recomendados (por ordem de preferência):
  1. gemma3:4b — rápido, frases curtas, ~1-2s
  2. llama3.2:3b — alternativa, similar latência
  3. mistral:7b — melhor qualidade mas ~3-5s
- Chamadas assíncronas via HTTPRequest do Godot (não bloqueia o render)
- Fallback obrigatório: array de frases fixas se Ollama offline

## Assets

### Tileset
Tiny Islands por Majadroid
- Licença: CC0 (domínio público)
- Tamanho de tile: 16x16 px
- Inclui: ilha, costa, oceano, floresta, edifícios, barco
- URL: https://opengameart.org/content/tiny-islands-16x16-tilemap

### Sprites do personagem
Character Base Template Collage por Antifarea & Clint Bellanger
- Licença: CC-BY (crédito obrigatório no jogo)
- Tamanho: 16x18 px por frame
- Animações incluídas: walk (4 direcções), attack, cast
- Novas animações (pescar, dormir, sentar): gerar com ComfyUI local ou Aseprite
- URL: https://opengameart.org/content/16x18-character-base-template-collage

### Sons (Fase 5)
- Fonte: freesound.org, filtro CC0
- Sons ambiente: oceano, gaivota, vento

## APIs externas (opcionais, Fase 3)

### Clima
wttr.in — API pública, sem key, JSON
- URL: https://wttr.in/?format=j1
- Dados usados: condição meteorológica (chuva, sol, nuvens)
- Chamada HTTP ao arranque e a cada hora

### Fuso horário / hora local
- Sistema operativo via Time.get_unix_time_from_system()
- Sem API externa necessária

## Ferramentas de desenvolvimento

| Ferramenta | Uso |
|------------|-----|
| Godot 4 Editor | Desenvolvimento principal |
| Aseprite (opcional) | Edição de sprites pixel art |
| ComfyUI (local) | Geração de novos assets com IA |
| git | Controlo de versão |
| Ollama CLI | Testar modelos localmente |

## Dependências e versões mínimas

| Dependência | Versão mínima | Notas |
|-------------|---------------|-------|
| Godot | 4.2 | GDScript 2, HTTPRequest async |
| Beehave | 3.x | Para Godot 4 |
| Ollama | 0.3+ | API /generate estável |
| Linux | kernel 5.15+ | Wayland/X11 ambos suportados |
