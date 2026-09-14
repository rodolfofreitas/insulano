#!/bin/bash
# Health check do ComfyUI para o projecto Insulano
# Uso: bash scripts/comfyui_health.sh

COMFY_URL="http://127.0.0.1:8188"
COMFY_DIR="$HOME/Programacao/ComfyUI"

echo "=== ComfyUI Health Check ==="

# 1. Servidor a correr?
if curl -s --max-time 3 "$COMFY_URL/system_stats" > /dev/null 2>&1; then
  echo "SERVIDOR: OK ($COMFY_URL)"
  PYTHON_VER=$(curl -s "$COMFY_URL/system_stats" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['system']['python_version'])" 2>/dev/null)
  echo "PYTHON: $PYTHON_VER"
else
  echo "SERVIDOR: OFFLINE"
  echo "  Para arrancar: bash $COMFY_DIR/start-linux.sh"
fi

# 2. Modelos ESRGAN presentes?
UPSCALE_DIR="$COMFY_DIR/models/upscale_models"
for model in "4x-UltraSharp.pth" "RealESRGAN_x4plus.pth"; do
  if [ -f "$UPSCALE_DIR/$model" ]; then
    SIZE=$(du -sh "$UPSCALE_DIR/$model" | cut -f1)
    echo "ESRGAN $model: OK ($SIZE)"
  else
    echo "ESRGAN $model: FALTA"
  fi
done

# 3. LoRAs pixel art?
LORA_DIR="$COMFY_DIR/models/loras"
for lora in "pixelart-xl.safetensors" "pixelart-sd15.safetensors"; do
  if [ -f "$LORA_DIR/$lora" ]; then
    SIZE=$(du -sh "$LORA_DIR/$lora" | cut -f1)
    echo "LORA $lora: OK ($SIZE)"
  else
    echo "LORA $lora: FALTA"
  fi
done

# 4. SD1.5 base?
CKPT_DIR="$COMFY_DIR/models/checkpoints"
if [ -f "$CKPT_DIR/v1-5-pruned-emaonly.safetensors" ]; then
  SIZE=$(du -sh "$CKPT_DIR/v1-5-pruned-emaonly.safetensors" | cut -f1)
  echo "SD1.5: OK ($SIZE)"
else
  echo "SD1.5: FALTA"
fi

# 5. GPU?
if command -v nvidia-smi > /dev/null 2>&1; then
  GPU=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader)
  echo "GPU: $GPU"
else
  echo "GPU: nvidia-smi nao disponivel"
fi

echo "==========================="
