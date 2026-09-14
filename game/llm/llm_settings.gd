class_name LLMSettings
extends RefCounted
## Configuração da camada LLM: se está activa, URL, modelo, timeout e intervalo
## mínimo entre pedidos.
##
## Fonte única de leitura das chaves insulano/llm/* (tech_design.md §3); nenhum outro
## script lê ProjectSettings com este prefixo. Não fala com o Ollama nem valida a
## ligação: só junta configuração. Usada pelo LLMBridge (T-105).

## Se falso, o LLMBridge nunca chama a rede: usa sempre o fallback.
var enabled: bool = true
## Endpoint HTTP do Ollama.
var url: String = "http://127.0.0.1:11434"
## Nome do modelo Ollama a pedir; tem de bater com o instalado (docs/api-ollama.md).
var model: String = "llama3.1:8b"
## Segundos de espera antes de desistir de um pedido e cair no fallback.
var timeout_s: float = 8.0
## Segundos mínimos entre duas frases geradas pelo SayGeneratedAction.
var min_interval_s: float = 30.0


## Constrói as definições pela ordem de precedência do tech_design.md §4.1:
## 1) defeitos de project.godot (ProjectSettings, chaves insulano/llm/*);
## 2) secção [llm] de cfg_path, se o ficheiro existir;
## 3) variável de ambiente INSULANO_LLM_URL, só para url (costura de teste,
##    documentada em tech_design.md §3, para apontar o LLMBridge a um endpoint
##    morto sem tocar em ficheiros).
## cfg_path é injectável para os testes GUT usarem um ficheiro temporário em
## vez do user://settings.cfg real; em jogo usa-se sempre o defeito.
static func load_settings(cfg_path: String = "user://settings.cfg") -> LLMSettings:
	var settings := LLMSettings.new()
	settings.enabled = ProjectSettings.get_setting("insulano/llm/enabled", settings.enabled)
	settings.url = ProjectSettings.get_setting("insulano/llm/url", settings.url)
	settings.model = ProjectSettings.get_setting("insulano/llm/model", settings.model)
	settings.timeout_s = ProjectSettings.get_setting("insulano/llm/timeout_s", settings.timeout_s)
	settings.min_interval_s = ProjectSettings.get_setting(
		"insulano/llm/min_interval_s", settings.min_interval_s
	)

	var cfg := ConfigFile.new()
	if cfg.load(cfg_path) == OK:
		settings.enabled = cfg.get_value("llm", "enabled", settings.enabled)
		settings.url = cfg.get_value("llm", "url", settings.url)
		settings.model = cfg.get_value("llm", "model", settings.model)
		settings.timeout_s = cfg.get_value("llm", "timeout_s", settings.timeout_s)
		settings.min_interval_s = cfg.get_value("llm", "min_interval_s", settings.min_interval_s)

	if OS.has_environment("INSULANO_LLM_URL"):
		settings.url = OS.get_environment("INSULANO_LLM_URL")

	return settings
