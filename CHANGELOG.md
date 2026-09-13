# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.1.0/). Versionamento: SemVer.
Entradas em linguagem de utilizador, não de commit. Cada tarefa acrescenta a sua em `[Não lançado]`.

## [Não lançado]

### Adicionado
- Projecto jogável em `game/`, a partir do Guy on Island, a correr em Godot 4.7.2.
- Portão de verificação único (`scripts/verify.sh`): documentação, backlog, lint, testes, arranque, imagem, LLM e export.
- Testes automáticos: 11 testes GUT, 39 testes dos scripts, smoke de arranque de 30 s simulados.
- Captura de ecrã real de tamanho fixo, para provas visuais.
- Eval das frases do LLM local (latência, português de Portugal, comprimento, conteúdo proibido).
- Backlog de 33 tarefas em 6 fases, com critérios de aceitação verificáveis.
- Harness para agentes: AGENTS.md, tech design com contratos, agentes e skills do Claude Code.

### Alterado
- Renderer passa a Compatibility (OpenGL 3): mais leve para um protector de ecrã 2D.
- Feriados passam de YAML para JSON, com Carnaval e Páscoa calculados a partir da data da Páscoa.
- Modelo por defeito passa a `llama3.1:8b`, o único instalado, com limiares de latência medidos.

### Corrigido
- Documentação que indicava modelos, versões e endpoints que não correspondiam à máquina real.
- Lint, formatação e documentação dos 21 ficheiros de GDScript herdados do Guy on Island
  (`scripts/gd_baseline.txt` fica vazia): cabeçalhos e docstrings novos, variáveis exportadas
  `fishingRod`, `searchArea` e `navigationAgent` renomeadas para `snake_case` (cenas actualizadas),
  sem alterar o comportamento do jogo.
