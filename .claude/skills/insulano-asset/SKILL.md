---
name: insulano-asset
description: Adiciona um asset (imagem, sprite, som, fonte) ao Insulano com licença verificada e registada, ou pára e passa ao Rodolfo quando é de terceiros. Usar sempre que uma tarefa precisa de um asset novo, quando se pergunta "posso usar esta imagem?", ou antes de publicar para auditar licenças.
---

# Adicionar um asset ao Insulano

O pilar 2 do projecto é ser legalmente limpo. Um asset sem licença verificada é um defeito de lançamento.

## 1. Classificar a origem

| Origem | Pode o agente decidir? | Registo |
|---|---|---|
| Desenhado em código (`_draw()`, partículas, shaders) | sim | não precisa, é código |
| PNG criado pelo agente nesta tarefa (pixel art original, gerado por script no repositório) | sim | "criado pelo projecto", com o caminho do script ou da tarefa |
| CC0 de terceiros | **não**: o Rodolfo confirma | autor, URL, licença |
| CC-BY de terceiros | **não** | autor, URL, licença, texto do crédito para o ecrã de créditos |
| MIT, OFL (fontes) | **não** | autor, URL, licença, ficheiro de licença copiado |
| NC, ND, "free for personal use", sem licença, Sierra ou Activision | **nunca** | recusar |

Preferência: desenhar em código > criar pelo projecto > CC0 > CC-BY.

## 2. Terceiros: parar com uma proposta

1. Acrescenta uma linha em `docs/assets-licencas.md`, secção "Pendentes de aprovação", com autor, URL da página,
   licença exacta, o que se ganha e alternativa sem terceiros.
2. Muda a tarefa para `estado: humano` com o motivo no Relatório.
3. Não descarregues o ficheiro para dentro de `game/`.

## 3. Criado pelo projecto: integrar

1. Ficheiro em `game/<funcionalidade>/`, nome `snake_case.png`.
2. Pixel art: no `.import`, filtro `Nearest` (ou `texture_filter` do nó a `TEXTURE_FILTER_NEAREST`).
3. `$(mise which godot) --headless --path game --import`.
4. Linha na tabela principal de `docs/assets-licencas.md` com origem "criado pelo projecto" e a tarefa.
5. Screenshot com o asset em uso em `docs/proof/`, inspeccionado.

## 4. Auditoria antes de publicar

```bash
cd ~/Programacao/Kaeto/Insulano/game
find . -path ./.godot -prune -o -path ./addons -prune -o -type f \( -name '*.png' -o -name '*.svg' -o -name '*.ogg' -o -name '*.wav' -o -name '*.mp3' -o -name '*.ttf' -o -name '*.otf' \) -print
```

Cada ficheiro listado tem de ter linha em `docs/assets-licencas.md` sem "por confirmar".
