# Insulano - Design Técnico e de Produto

*Documento de especificação v0.1 - Setembro 2026*

---

## 1. INTERACÇÃO

### Filosofia base

O Insulano é um screensaver, não um jogo. A regra de ouro é: **qualquer input fecha o screensaver imediatamente** - mas antes de fechar, o náufrago pode reagir ao input por uma fracção de segundo. Isso cria a ilusão de que ele "sentiu" a presença do utilizador.

A analogia de Johnny Castaway é perfeita: ele nunca soube que estava num ecrã. O náufrago não deve "quebrar a quarta parede" - reage ao ambiente da ilha, não ao utilizador.

---

### 1.1 Modelo de Interacção

#### Movimento do rato

```
Rato move-se → Timer de "presença" inicia (100ms) → Náufrago olha para o horizonte
               → Se rato não parar: screensaver fecha
               → Se fosse modo --window: reacção visual sem fechar
```

**Implementação Godot:**

```gdscript
# autoload/InputWatcher.gd
extends Node

signal presence_detected
var _mode: String = "screensaver"  # ou "window"

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if event.relative.length() > 2.0:  # threshold anti-jitter
            _on_input_detected()
    elif event is InputEventMouseButton or event is InputEventKey:
        _on_input_detected()

func _on_input_detected() -> void:
    emit_signal("presence_detected")
    if _mode == "screensaver":
        # Dá 150ms para animação de reacção antes de fechar
        await get_tree().create_timer(0.15).timeout
        get_tree().quit()
```

> **Porquê 150ms?** É o tempo mínimo perceptível para o utilizador ver a reacção. Menos parece bug, mais parece lag.

---

#### Reacções do náufrago por tipo de input

| Input | Reacção (150ms) | Animação |
|---|---|---|
| Movimento suave do rato | Olha para cima, protege os olhos do sol | `look_up_shield` |
| Movimento brusco/rápido | Salta assustado, cai na areia | `startle_fall` |
| Clique esquerdo | Acena com a mão, sorri | `wave_hello` |
| Tecla qualquer | Vira-se para a direcção do som | `look_around` |
| ESC específico | Nenhuma reacção - fecha imediatamente | - |

**Implementação das reacções:**

```gdscript
# castaway/Castaway.gd
extends CharacterBody2D

enum Reaction { LOOK_UP, STARTLE, WAVE, LOOK_AROUND }

func react(type: Reaction) -> void:
    match type:
        Reaction.STARTLE:
            animation_player.play("startle_fall")
        Reaction.WAVE:
            animation_player.play("wave_hello")
        Reaction.LOOK_UP:
            animation_player.play("look_up_shield")
        Reaction.LOOK_AROUND:
            animation_player.play("look_around")
    # Animação é interrompida quando get_tree().quit() for chamado - tudo bem
```

---

#### Threshold de movimento do rato - problema Wayland

No Wayland, `InputEventMouseMotion.relative` pode disparar com valores quase zero por causa de aceleração de ponteiro. Solução:

```gdscript
# Acumula deltas durante 3 frames antes de decidir
var _accumulated_delta: float = 0.0
var _frames_counted: int = 0

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _accumulated_delta += event.relative.length()
        _frames_counted += 1
        if _frames_counted >= 3:
            if _accumulated_delta > 6.0:  # 3 frames × 2px mínimo
                _on_input_detected()
            _accumulated_delta = 0.0
            _frames_counted = 0
```

---

#### Modo --window vs --screensaver

O modo `--window` é para preview (ex: selector de screensaver do sistema, painel de configuração). Neste modo, **nunca fecha** por input. A distinção é feita por argumento CLI:

```gdscript
# main.gd
func _ready() -> void:
    var args = OS.get_cmdline_args()
    if "--screensaver" in args or "-s" in args:
        InputWatcher.set_mode("screensaver")
        _setup_screensaver_window()
    elif "--window" in args or "-w" in args:
        InputWatcher.set_mode("window")
        # Window mode: sem fullscreen, sem fechar por input
    elif "--config" in args:
        _open_config_screen()

func _setup_screensaver_window() -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    # No Hyprland/Wayland, pedir ao compositor para tratar como screensaver
    DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
```

---

### 1.2 Integração com hypridle

O hypridle activa o screensaver. Configuração recomendada em `~/.config/hypr/hypridle.conf`:

```conf
listener {
    timeout = 300          # 5 minutos de idle
    on-timeout = insulano --screensaver
    on-resume = pkill -x insulano
}
```

O `on-resume` é redundante (o screensaver já fecha sozinho), mas é segurança extra.

---

### 1.3 O que NÃO fazer

- **Não capturar input de sistema** (atalhos do Hyprland, volume, etc.) - usar `set_process_input(true)` apenas para detecção, não consumir eventos
- **Não bloquear o ecrã** - isso é trabalho do `hyprlock`, não do Insulano
- **Não ter menu de pausa** - screensavers não têm menus
- **Não pedir confirmação para fechar** - qualquer input = sair

---

## 2. MULTI-MONITOR

### 2.1 Análise das Opções

| Abordagem | Prós | Contras |
|---|---|---|
| Só monitor principal | Simples, eficiente | Monitores secundários ficam "vazios" - quebra a imersão |
| Ilha em cada monitor | Cada monitor tem o seu mundo | Duas instâncias do Ollama? Complexidade |
| Ilha expandida por todos | Visualmente impactante | Difícil de alinhar, relação de aspecto estranha |
| Céu/oceano em secundários, ilha no principal | Imersivo e eficiente | Sincronização entre janelas |

### 2.2 Recomendação: Abordagem Panorâmica Estratificada

**Proposta:** No monitor principal, a ilha completa. Nos monitores secundários, apenas o **oceano e o céu** - uma extensão do horizonte, com pássaros ocasionais e ondas. O náufrago e o Ollama ficam no principal.

**Porquê:** Cria imersão sem duplicar lógica de negócio. É o que faria sentido no mundo do náufrago - ele está numa ilha no centro, rodeado de oceano.

---

### 2.3 Implementação

```gdscript
# main.gd - Detecção de monitores
func _setup_multi_monitor() -> void:
    var screen_count = DisplayServer.get_screen_count()
    var primary = DisplayServer.get_primary_screen()
    
    if screen_count == 1:
        _launch_single_screen()
        return
    
    # Monitor principal: cena completa
    _launch_island_on_screen(primary)
    
    # Monitores secundários: só oceano
    for i in range(screen_count):
        if i != primary:
            _launch_ocean_on_screen(i)

func _launch_ocean_on_screen(screen_idx: int) -> void:
    # Abre sub-janela sem decorações
    var pos = DisplayServer.screen_get_position(screen_idx)
    var size = DisplayServer.screen_get_size(screen_idx)
    
    var window = Window.new()
    window.borderless = true
    window.unresizable = true
    window.position = pos
    window.size = size
    window.always_on_top = true
    add_child(window)
    
    var ocean_scene = preload("res://scenes/OceanBackground.tscn").instantiate()
    window.add_child(ocean_scene)
    
    # Sincroniza a hora do dia com o monitor principal
    ocean_scene.set_time_of_day(GameClock.current_hour)
```

---

### 2.4 Ficheiro de config para multi-monitor

```ini
# ~/.config/insulano/config.ini

[display]
multi_monitor_mode = "panoramic"  # "panoramic" | "primary_only" | "clone"
primary_screen = -1               # -1 = detectar automaticamente
ocean_on_secondary = true
sync_time_of_day = true
```

### 2.5 Caso Especial: Monitor Vertical (Retrato)

Se um monitor secundário estiver em modo retrato (90°), o fundo oceano deve detectar e ajustar:

```gdscript
func _get_orientation(screen_idx: int) -> String:
    var size = DisplayServer.screen_get_size(screen_idx)
    return "portrait" if size.y > size.x else "landscape"
```

Em retrato, mostrar oceano vertical com ondas mais altas e pássaros que sobem/descem em vez de atravessar horizontalmente.

---

## 3. ECRÃ DE CONFIGURAÇÃO

### 3.1 Princípios de Design

- **Um ecrã, não um menu de opções** - tudo visível sem scroll sempre que possível
- **Preview em directo** - o utilizador vê a ilha ao fundo enquanto configura
- **Defaults sãos** - funciona sem configurar nada
- **Abrir com:** `insulano --config`

---

### 3.2 Layout Proposto

```
┌─────────────────────────────────────────────────────────────────┐
│  🏝️  Insulano  ·  Configuração                          [×]     │
│─────────────────────────────────────────────────────────────────│
│                                                                 │
│  ╔══════════════════════╗  ┌─────────────────────────────────┐  │
│  ║                      ║  │  🤖 Modelo de IA                │  │
│  ║   [preview da ilha]  ║  │  ○ Nenhum (só animação)        │  │
│  ║   [animada, 30fps]   ║  │  ● Ollama local (:11434)       │  │
│  ║                      ║  │     Modelo: [llama3.2:3b    ▼] │  │
│  ╚══════════════════════╝  │  ○ API remota                  │  │
│                            │     URL: [___________________] │  │
│                            │     Chave: [***************]   │  │
│                            └─────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────┐  ┌─────────────────────────────────┐  │
│  │  🌍 Idioma           │  │  ⚡ Performance                  │  │
│  │  [Português (PT) ▼]  │  │  Qualidade:  ○ Baixa  ● Média  │  │
│  │                      │  │             ○ Alta              │  │
│  │  🐢 Velocidade       │  │  FPS Limite: [30        ]      │  │
│  │  Animação: ━━●━━━━━  │  │  □ Pausar se bateria < 20%    │  │
│  │  IA: ━━━━●━━━━━      │  └─────────────────────────────────┘  │
│  └──────────────────────┘                                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  🔊 Som                                                  │   │
│  │  Volume geral: ━━━━━━●━━━━  Ondas: ━━━━●━━━━━           │   │
│  │  □ Mutar tudo                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│              [Repor defaults]     [Guardar e Fechar]           │
└─────────────────────────────────────────────────────────────────┘
```

---

### 3.3 Opções Detalhadas

#### Bloco: Modelo de IA

```gdscript
# config/OllamaModelPicker.gd
func _fetch_local_models() -> void:
    # Tenta ligar ao Ollama local
    var http = HTTPRequest.new()
    add_child(http)
    http.request_completed.connect(_on_models_received)
    
    var err = http.request("http://127.0.0.1:11434/api/tags")
    if err != OK:
        _show_status("Ollama não encontrado em :11434")
        _disable_local_option()

func _on_models_received(result, code, headers, body) -> void:
    if code == 200:
        var json = JSON.parse_string(body.get_string_from_utf8())
        var models = json["models"].map(func(m): return m["name"])
        _populate_model_dropdown(models)
        _show_status("✓ Ollama ligado - %d modelos disponíveis" % models.size())
    else:
        _show_status("Erro ao ligar ao Ollama")
```

Quando o utilizador abre o ecrã de config, o Insulano faz ping ao Ollama automaticamente e popula o dropdown com os modelos disponíveis.

---

#### Bloco: Idiomas suportados (v1.0)

| Código | Nome | Bandeira |
|---|---|---|
| `pt_PT` | Português (Portugal) | 🇵🇹 |
| `pt_BR` | Português (Brasil) | 🇧🇷 |
| `en_GB` | English (UK) | 🇬🇧 |
| `es_ES` | Español | 🇪🇸 |
| `fr_FR` | Français | 🇫🇷 |

O idioma afecta os diálogos do náufrago e os tooltips da UI. As animações são independentes do idioma.

---

#### Bloco: Velocidade

Dois sliders independentes:
- **Velocidade de animação** - quão rápido o náufrago se move, gesticula, dorme
- **Frequência de IA** - de quanto em quanto tempo o LLM gera novo comportamento/diálogo

```gdscript
# Guardar config
func _save_config() -> void:
    var config = ConfigFile.new()
    config.set_value("ai", "provider", _ai_provider)
    config.set_value("ai", "model", _selected_model)
    config.set_value("ai", "api_url", _api_url)
    config.set_value("display", "language", _language)
    config.set_value("gameplay", "animation_speed", _anim_speed)
    config.set_value("gameplay", "ai_frequency", _ai_frequency)
    config.set_value("audio", "master_volume", _master_vol)
    config.set_value("audio", "ocean_volume", _ocean_vol)
    config.set_value("audio", "muted", _muted)
    config.set_value("performance", "quality", _quality_preset)
    config.set_value("performance", "fps_cap", _fps_cap)
    config.set_value("performance", "pause_on_battery", _pause_battery)
    
    # Guardar em ~/.config/insulano/config.ini
    var path = OS.get_environment("HOME") + "/.config/insulano/config.ini"
    config.save(path)
```

> **Porquê `~/.config/insulano/` em vez de `user://`?** A path `user://` do Godot resolve para `~/.local/share/insulano/` - menos óbvio para o utilizador que quer editar a config manualmente. `~/.config/` é a convenção XDG e mais fácil de descobrir.

---

#### Presets de qualidade

| Preset | FPS | Sombras | Partículas | Água |
|---|---|---|---|---|
| Baixa | 15 | Não | 20 max | Sprite estático |
| Média | 30 | Estáticas | 50 max | Animação simples |
| Alta | 60 | Dinâmicas | 100 max | Shader completo |

O preset **Média** é o default - é o que um 486 MHz faria com orgulho num RTX 3060.

---

### 3.4 Integração do Config com o Screensaver

```gdscript
# main.gd - Carrega config antes de iniciar
func _ready() -> void:
    var cfg = _load_config()
    
    Engine.max_fps = cfg.get_value("performance", "fps_cap", 30)
    
    # Aplicar qualidade
    var quality = cfg.get_value("performance", "quality", "medium")
    QualityManager.apply_preset(quality)
    
    # Iniciar com IA ou sem
    var provider = cfg.get_value("ai", "provider", "none")
    if provider != "none":
        AIDirector.start(provider, cfg)
```

---

## 4. PERFORMANCE

### 4.1 Filosofia: o Padrão Johnny Castaway

Johnny Castaway de 1992 corria a 256 cores, sprites de 16×16 pixels, num 486 a 33 MHz. Era **leve por necessidade**. No Insulano, ser leve é uma escolha de respeito pelo utilizador.

**Targets:**

| Recurso | Target | Máximo Aceitável |
|---|---|---|
| CPU (thread principal) | < 2% | 5% |
| CPU (total) | < 4% | 8% |
| GPU | < 5% | 15% |
| RAM | < 80 MB | 150 MB |
| VRAM | < 50 MB | 100 MB |
| FPS cap | 30 fps | 60 fps (modo Alto) |
| Latência de arranque | < 1.5s | 3s |

> O RTX 3060 do utilizador tem 6 GB VRAM e uma GPU dedicada. Mesmo assim, o Insulano não deve abusar - o utilizador pode estar a compilar código ou ter outros processos importantes a correr.

---

### 4.2 Como Medir

#### Durante desenvolvimento

```bash
# Terminal 1: monitorar GPU (NVIDIA)
watch -n 1 nvidia-smi --query-gpu=utilization.gpu,utilization.memory,memory.used \
  --format=csv,noheader

# Terminal 2: monitorar CPU e RAM do processo
watch -n 1 "ps aux | grep insulano | grep -v grep | awk '{print \"CPU:\", \$3\"%  RAM:\", \$6/1024, \"MB\"}'"

# Terminal 3: ver FPS do Godot
# No project.godot:
# [debug] > settings > performance > show_fps = true (só em modo --window)
```

#### Script de benchmark integrado

```gdscript
# debug/PerformanceMonitor.gd (só activo em builds de debug)
func _process(_delta: float) -> void:
    if not OS.is_debug_build():
        return
    
    var stats = {
        "fps": Engine.get_frames_per_second(),
        "draw_calls": RenderingServer.get_rendering_info(
            RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
        "objects": RenderingServer.get_rendering_info(
            RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
    }
    
    # Escreve para ficheiro a cada 60 segundos para análise posterior
    if Engine.get_process_frames() % 1800 == 0:
        _append_to_log(stats)
```

---

### 4.3 Optimizações Obrigatórias

#### Limitação de FPS

```gdscript
# Aplicar imediatamente no arranque, antes de qualquer cena
func _init() -> void:
    Engine.max_fps = 30  # default; sobrescrito pela config
```

No Godot com Compatibility renderer (OpenGL 3), `Engine.max_fps` é suficiente - não é necessário `VSync` forçado.

#### Partículas: usar GPUParticles2D com moderação

```gdscript
# NÃO fazer isto:
# 500 CPUParticles2D para areia

# Fazer isto:
# 1 GPUParticles2D com emission_shape e amount = 50
var particles = GPUParticles2D.new()
particles.amount = 50          # máximo em modo Médio
particles.lifetime = 3.0
particles.one_shot = false
```

#### Background: SubViewport em vez de cena principal

O oceano e o céu são estáticos maioritariamente. Usar um `SubViewport` com `update_mode = UPDATE_ONCE` e só re-renderizar quando o tempo do dia muda:

```gdscript
# BackgroundLayer.gd
var _last_hour: int = -1

func _process(_delta: float) -> void:
    var current_hour = GameClock.current_hour
    if current_hour != _last_hour:
        _last_hour = current_hour
        sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        _update_sky_gradient(current_hour)
```

#### Áudio: streams em vez de samples

```gdscript
# Sons de oceano: usar AudioStreamOggVorbis (comprimido)
# NÃO usar WAV para ambient sounds longos
var ocean_stream: AudioStreamOggVorbis = preload("res://audio/ocean_loop.ogg")
```

#### Sono do náufrago = pausa da IA

Quando o náufrago adormece (comportamento aleatório), parar o polling do Ollama:

```gdscript
# Poupa CPU quando não há nada a fazer
func on_castaway_sleep() -> void:
    AIDirector.pause()
    set_process(false)  # parar _process() da cena principal
    # Manter só: áudio, partículas de background, relógio

func on_castaway_wake() -> void:
    AIDirector.resume()
    set_process(true)
```

#### Pausa em bateria baixa

```gdscript
# Verificar bateria (Linux)
func _check_battery() -> void:
    var file = FileAccess.open(
        "/sys/class/power_supply/BAT0/capacity", FileAccess.READ)
    if file:
        var level = int(file.get_as_text().strip_edges())
        if level < 20 and _pause_on_battery:
            Engine.max_fps = 5  # quase parado
            AIDirector.pause()
```

---

### 4.4 O Que NÃO Usar no Compatibility Renderer

| Funcionalidade | Porquê evitar |
|---|---|
| `WorldEnvironment` com SSAO | Não existe em Compatibility |
| `LightmapGI` | 3D, não aplicável |
| Shaders complexos (mais de 50 instruções) | Lento em OpenGL 3 |
| Texturas > 1024×1024 sem mipmaps | Thrashing de VRAM |
| `CanvasItem.use_parent_material` em cadeia longa | Draw calls extras |

---

### 4.5 Perfil de Startup

O screensaver deve estar visível em menos de 1.5 segundos. Sequência:

```
0ms    - Processo lançado pelo hypridle
50ms   - Janela criada, fundo preto
200ms  - Céu e oceano base carregados (sprites estáticos)
500ms  - Ilha e náufrago carregados
800ms  - Animações iniciadas
1200ms - Som de oceano inicia (fade in suave)
1500ms - IA começa a polling (não bloqueia o arranque)
```

Para atingir isto: **carregar assets em background thread** enquanto o primeiro frame é apresentado.

```gdscript
func _ready() -> void:
    # Frame 1: mostrar fundo simples
    $Sky.visible = true
    $Ocean.visible = true
    
    # Background: carregar resto
    var thread = Thread.new()
    thread.start(_load_heavy_assets)

func _load_heavy_assets() -> void:
    ResourceLoader.load("res://scenes/Castaway.tscn")
    ResourceLoader.load("res://scenes/Island.tscn")
    call_deferred("_on_assets_loaded")
```

---

## 5. INSTALAÇÃO

### 5.1 Filosofia: Um Comando

A instalação deve ser `curl ... | bash` - sim, controverso, mas é a realidade do ecossistema Arch. A alternativa sensata é um script que o utilizador descarrega e revê antes de correr.

**Objectivo:** do zero ao screensaver activo em menos de 2 minutos.

---

### 5.2 Script de Instalação (sem sudo)

```bash
#!/usr/bin/env bash
# install.sh - Instalação do Insulano (sem sudo, sem root)
set -euo pipefail

INSULANO_VERSION="1.0.0"
INSTALL_DIR="$HOME/.local/share/insulano"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/insulano"
HYPRLAND_CONFIG="$HOME/.config/hypr"

# ── Cores ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}▸${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

echo ""
echo "  🏝️  Instalação do Insulano v${INSULANO_VERSION}"
echo "  ─────────────────────────────────────────"
echo ""

# ── Verificações ───────────────────────────────────────────────────
info "A verificar dependências..."

command -v Xwayland >/dev/null 2>&1 || true  # não obrigatório

# Hyprland
if ! command -v hyprctl >/dev/null 2>&1; then
    warn "hyprctl não encontrado - tens Hyprland instalado?"
fi

# hypridle
if ! command -v hypridle >/dev/null 2>&1; then
    warn "hypridle não encontrado. Instala com: yay -S hypridle"
    warn "O Insulano funciona sem ele, mas não activará automaticamente."
fi

# ── Criar directorias ──────────────────────────────────────────────
info "A criar directorias..."
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$CONFIG_DIR"

# ── Descarregar binário ────────────────────────────────────────────
RELEASE_URL="https://github.com/rodolfoc/insulano/releases/download/v${INSULANO_VERSION}"
BINARY_URL="${RELEASE_URL}/insulano-linux-x86_64.tar.gz"

info "A descarregar Insulano v${INSULANO_VERSION}..."
if command -v curl >/dev/null 2>&1; then
    curl -L --progress-bar "$BINARY_URL" -o /tmp/insulano.tar.gz
elif command -v wget >/dev/null 2>&1; then
    wget -q --show-progress "$BINARY_URL" -O /tmp/insulano.tar.gz
else
    error "curl ou wget necessários."
fi

# ── Extrair ────────────────────────────────────────────────────────
info "A extrair ficheiros..."
tar -xzf /tmp/insulano.tar.gz -C "$INSTALL_DIR" --strip-components=1
rm /tmp/insulano.tar.gz
chmod +x "$INSTALL_DIR/insulano"

# ── Symlink no PATH ────────────────────────────────────────────────
ln -sf "$INSTALL_DIR/insulano" "$BIN_DIR/insulano"

# Verificar que ~/.local/bin está no PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR não está no PATH."
    warn "Adiciona ao teu ~/.bashrc ou ~/.zshrc:"
    warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ── Config default ─────────────────────────────────────────────────
if [[ ! -f "$CONFIG_DIR/config.ini" ]]; then
    info "A criar configuração default..."
    cat > "$CONFIG_DIR/config.ini" << 'EOF'
[ai]
provider=none
model=llama3.2:3b
api_url=http://127.0.0.1:11434

[display]
language=pt_PT
multi_monitor_mode=panoramic

[gameplay]
animation_speed=1.0
ai_frequency=1.0

[audio]
master_volume=0.8
ocean_volume=0.7
muted=false

[performance]
quality=medium
fps_cap=30
pause_on_battery=true
EOF
fi

# ── Integração hypridle ────────────────────────────────────────────
info "A configurar hypridle..."

HYPRIDLE_CONF="$HYPRLAND_CONFIG/hypridle.conf"

if [[ -f "$HYPRIDLE_CONF" ]]; then
    # Verificar se já tem entrada do insulano
    if grep -q "insulano" "$HYPRIDLE_CONF" 2>/dev/null; then
        warn "hypridle.conf já tem entrada do Insulano - a saltar."
    else
        cat >> "$HYPRIDLE_CONF" << 'EOF'

# ── Insulano screensaver ───────────────────────
listener {
    timeout = 300
    on-timeout = insulano --screensaver
    on-resume = pkill -x insulano || true
}
EOF
        success "hypridle.conf actualizado."
    fi
else
    warn "hypridle.conf não encontrado em $HYPRIDLE_CONF"
    warn "Cria o ficheiro e adiciona:"
    cat << 'EOF'
listener {
    timeout = 300
    on-timeout = insulano --screensaver
    on-resume = pkill -x insulano || true
}
EOF
fi

# ── Desktop entry (para launchers) ────────────────────────────────
XDG_DATA="$HOME/.local/share"
mkdir -p "$XDG_DATA/applications"

cat > "$XDG_DATA/applications/insulano-config.desktop" << EOF
[Desktop Entry]
Name=Insulano - Configuração
Comment=Configurar o protector de ecrã Insulano
Exec=$BIN_DIR/insulano --config
Icon=$INSTALL_DIR/assets/icon.png
Type=Application
Categories=Settings;DesktopSettings;
EOF

# ── Teste de execução ──────────────────────────────────────────────
info "A testar execução..."
if "$BIN_DIR/insulano" --version >/dev/null 2>&1; then
    success "Insulano instalado e funcional!"
else
    warn "Não foi possível verificar a versão - verifica manualmente com: insulano --version"
fi

# ── Sumário ────────────────────────────────────────────────────────
echo ""
echo "  ────────────────────────────────────────────────────"
success "Insulano instalado com sucesso!"
echo ""
echo "  Comandos disponíveis:"
echo "    insulano --screensaver   Iniciar protector de ecrã"
echo "    insulano --window        Modo preview"
echo "    insulano --config        Abrir configuração"
echo ""
echo "  O screensaver activa automaticamente após 5 minutos"
echo "  de inactividade (configurável em $HYPRIDLE_CONF)"
echo ""
echo "  Para configurar o Ollama: insulano --config"
echo "  ────────────────────────────────────────────────────"
```

---

### 5.3 Package AUR (Futuro)

Estrutura do `PKGBUILD`:

```bash
# PKGBUILD
pkgname=insulano
pkgver=1.0.0
pkgrel=1
pkgdesc="Protector de ecrã com náufrago e IA para Hyprland/Wayland"
arch=('x86_64')
url="https://github.com/rodolfoc/insulano"
license=('MIT')
depends=('glibc' 'libgl')
optdepends=(
    'hypridle: activação automática do screensaver'
    'ollama: diálogos gerados por IA'
)
source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")

package() {
    install -Dm755 "$srcdir/insulano-linux-x86_64/insulano" \
        "$pkgdir/usr/share/insulano/insulano"
    
    # Wrapper no PATH do sistema
    install -Dm755 /dev/stdin "$pkgdir/usr/bin/insulano" << 'EOF'
#!/bin/sh
exec /usr/share/insulano/insulano "$@"
EOF
    
    install -Dm644 "$srcdir/insulano.desktop" \
        "$pkgdir/usr/share/applications/insulano-config.desktop"
    
    install -Dm644 "$srcdir/LICENSE" \
        "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
```

Com o AUR: `yay -S insulano` e a integração com hypridle seria feita pelo hook post-install.

---

### 5.4 Desinstalação

```bash
#!/usr/bin/env bash
# uninstall.sh
set -euo pipefail

rm -f "$HOME/.local/bin/insulano"
rm -rf "$HOME/.local/share/insulano"
rm -f "$HOME/.local/share/applications/insulano-config.desktop"

# Config preservada propositadamente - o utilizador decide
echo "Configuração preservada em ~/.config/insulano/"
echo "Para remover completamente: rm -rf ~/.config/insulano/"
```

> **Porquê preservar a config?** Se o utilizador reinstalar, não perde as suas preferências. É o comportamento que todos esperamos de ferramentas bem comportadas.

---

## Apêndice: Mapa de Ficheiros

```
~/.local/
├── bin/
│   └── insulano                    # symlink → share/insulano/insulano
└── share/
    ├── insulano/
    │   ├── insulano                # binário Godot exportado
    │   ├── insulano.pck            # assets empacotados
    │   └── assets/
    │       └── icon.png
    └── applications/
        └── insulano-config.desktop

~/.config/
└── insulano/
    └── config.ini                  # configuração do utilizador

~/.config/hypr/
└── hypridle.conf                   # modificado pelo installer (append)
```

---

## Apêndice: Decisões de Design - Resumo

| Decisão | Escolha | Alternativa rejeitada | Razão |
|---|---|---|---|
| Input → fechar | 150ms delay com reacção | Fechar imediato | Mais humano, sem custo real |
| Multi-monitor | Panorâmica (ilha + oceano) | Clone em cada monitor | Imersivo e eficiente |
| Config path | `~/.config/insulano/` | `user://` (Godot) | Convenção XDG, mais descobrível |
| FPS default | 30 | 60 | Metade da carga, imperceptível num screensaver |
| Instalação | Script sem sudo | AUR imediato | AUR requer manutenção de infra; script é suficiente para v1 |
| IA em sleep | Pausa do polling | Continuar a correr | Poupa CPU quando nada muda |
| Qualidade default | Média | Alta | Respeitar outros processos do utilizador |