# API Ollama — Referência para o Insulano

Documentação da integração com o Ollama local.

## Endpoint usado

POST http://localhost:11434/api/generate

## Request

```json
{
  "model": "gemma3:4b",
  "prompt": "<prompt construído pelo LLMBridge>",
  "stream": false,
  "options": {
    "num_predict": 50,
    "temperature": 0.8,
    "top_p": 0.9
  }
}
```

Campos:
- `model`: modelo instalado no Ollama. Verificar com `ollama list`.
- `stream: false`: resposta única (não streaming). Mais simples para Godot.
- `num_predict: 50`: limitar tokens (~50 palavras). Frases curtas são melhores.
- `temperature: 0.8`: alguma criatividade sem ser caótico.

## Response

```json
{
  "model": "gemma3:4b",
  "created_at": "2026-09-13T10:00:00Z",
  "response": "O oceano está calmo hoje, mas meu estômago não está.",
  "done": true,
  "total_duration": 1234000000,
  "eval_count": 15
}
```

Campo relevante: `response` — a frase gerada.

## Construção do prompt em GDScript

```gdscript
func _build_prompt(context: Dictionary) -> String:
    var action: String = context.get("action", "descansando")
    var hour: int = Time.get_datetime_dict_from_system().hour
    var period: String = "manhã" if hour < 12 else ("tarde" if hour < 18 else "noite")

    return (
        "Você é um náufrago numa ilha deserta há meses. "
        + "Diga uma frase curta (máximo 12 palavras), na perspectiva do náufrago. "
        + "Agora está " + action + " de " + period + ". "
        + "Responda apenas com a frase, sem aspas, sem explicação."
    )
```

## Tratamento de erros em GDScript

```gdscript
func _on_request_completed(result: int, response_code: int,
                           headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
        # Fallback automático
        phrase_ready.emit(_get_fallback_phrase())
        return

    var json = JSON.new()
    if json.parse(body.get_string_from_utf8()) != OK:
        phrase_ready.emit(_get_fallback_phrase())
        return

    var text: String = json.data.get("response", "").strip_edges()
    if text.is_empty():
        phrase_ready.emit(_get_fallback_phrase())
        return

    phrase_ready.emit(text)
```

## Verificar se Ollama está disponível

```bash
# Terminal — verificar se Ollama responde
curl -s http://localhost:11434/api/tags | python3 -m json.tool | grep name

# Listar modelos instalados
ollama list

# Testar frase manualmente
ollama run gemma3:4b "Você é um náufrago. Diga uma frase curta de manhã."
```

## Timeout

HTTPRequest do Godot: `set_timeout(5.0)` — se não responder em 5s, usa fallback.

## Modelos testados

| Modelo | Latência típica | Qualidade | Instalado? |
|--------|----------------|-----------|------------|
| gemma3:4b | ~1-2s | Boa para frases curtas | Verificar |
| llama3.2:3b | ~1-3s | Similar | Verificar |
| mistral:7b | ~3-5s | Melhor mas mais lento | Verificar |

Para instalar: `ollama pull gemma3:4b`
