# Runbook — Insulano

Procedimentos operacionais para desenvolvimento e distribuição.

---

## 1. Setup do ambiente de desenvolvimento

### Pré-requisitos

```bash
# Verificar Ollama
ollama list
curl -s http://localhost:11434/api/tags | grep -c name

# Verificar Godot 4 instalado
godot --version   # deve ser 4.x

# Se Godot não estiver instalado no Omarchy
omarchy pkg add godot   # via pacman/AUR
# ou: flatpak install flathub org.godotengine.Godot
```

### Abrir o projecto

```bash
cd ~/Programacao/Kaeto/Insulano

# Inicializar submodulo (se clonado sem --recurse-submodules)
git submodule update --init --recursive

# Abrir base no Godot para referência
godot base-guy-on-island/project.godot &

# O projecto Insulano próprio (quando criado na Fase 1)
godot insulano/project.godot &
```

---

## 2. Fluxo de desenvolvimento por fase

### Fase 1 — LLM

```bash
# 1. Certificar que Ollama está a correr
ollama list

# 2. Instalar modelo se necessário
ollama pull gemma3:4b

# 3. Testar frase manualmente
ollama run gemma3:4b "Você é um náufrago numa ilha. Diga uma frase curta ao amanhecer."

# 4. Desenvolver LLMBridge.gd no Godot Editor

# 5. Testar com Ollama offline (forçar fallback)
# No terminal: killall ollama
# Correr o jogo — deve usar frases fixas sem crash

# 6. Export Linux
# Godot Editor → Project → Export → Linux/X11 → Export Project
# Testar: ./insulano.x86_64

# 7. Commit
git add . && git commit -m "feat: integrar LLM bridge com Ollama e fallback"
```

---

## 3. Export para distribuição

### Linux (principal)
```bash
# No Godot Editor:
# Project → Export → Add → Linux/X11
# Definir output: dist/insulano-linux.x86_64
# Clicar Export Project

# Testar
chmod +x dist/insulano-linux.x86_64
./dist/insulano-linux.x86_64
```

### Windows
```bash
# Requer wine ou máquina Windows para testar
# No Godot Editor: Add → Windows Desktop
# Output: dist/insulano-windows.exe
```

### HTML5
```bash
# No Godot Editor: Add → Web
# Output: dist/web/
# Testar: python3 -m http.server 8080 --directory dist/web/
# Abrir: http://localhost:8080
```

---

## 4. Publicar no itch.io

```bash
# Criar conta em itch.io (se não existir)
# Criar projecto: https://itch.io/game/new

# Configuração recomendada:
# Kind of project: HTML5 (para demo rápida) + Downloadable (Linux/Windows)
# Visibility: Devlog (durante dev) → Public (ao lançar)
# Pricing: No payments (free)
# Licença: MIT

# Upload dos ficheiros:
# - insulano-linux.tar.gz (binário + assets)
# - insulano-windows.zip
# - Web player (pasta web/)

# Créditos obrigatórios na descrição (CC-BY):
# "Character sprites by Antifarea & Clint Bellanger / OpenGameArt.org (CC-BY)"
```

---

## 5. Troubleshooting

### Ollama não responde
```bash
# Verificar se está a correr
ps aux | grep ollama

# Iniciar manualmente
ollama serve &

# Verificar porta
curl http://localhost:11434/api/tags
```

### Jogo não arranca no Omarchy (Wayland)
```bash
# Forçar X11 se necessário
DISPLAY=:0 ./insulano.x86_64

# Ou via XWayland (deve funcionar automaticamente no Hyprland)
```

### Modelo muito lento
```bash
# Usar modelo mais pequeno
ollama pull gemma3:4b   # ~2.5GB, mais rápido que 7B
# Alterar no ProjectSettings do Godot
```

### Export falha por falta de templates
```bash
# No Godot: Editor → Manage Export Templates → Download
# Escolher a versão correspondente ao Godot instalado
```

---

## 6. Créditos obrigatórios (CC-BY)

Incluir em ecrã de créditos do jogo e na página itch.io:

    Character sprites: Antifarea & Clint Bellanger / OpenGameArt.org
    Licença CC-BY: https://creativecommons.org/licenses/by/3.0/

O tileset Tiny Islands é CC0 — atribuição não obrigatória mas apreciada:
    Tileset: Majadroid / OpenGameArt.org
