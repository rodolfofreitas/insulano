extends GutTest
## Testes de [LLMSettings]: defeitos vindos de project.godot, sobreposição por
## user://settings.cfg e, por fim, pela variável de ambiente INSULANO_LLM_URL.
## Ordem de precedência do tech_design.md §4.1: env > .cfg > ProjectSettings.
##
## test_project_settings_layer_is_actually_read prova, com um valor que os
## defeitos hard-coded de llm_settings.gd:11-19 NÃO têm, que load_settings lê
## mesmo o ProjectSettings em runtime (não só compara contra si próprio).

## Caminho do .cfg temporário usado pelos testes que tocam ficheiro; nunca o
## user://settings.cfg real, para não haver contaminação entre corridas.
const TEST_CFG_PATH := "user://test_llm_settings.cfg"

## Valor de INSULANO_LLM_URL antes do teste corrente, para repor exactamente o
## estado que o ambiente tinha (e não apagar uma variável que já lá estava).
var _env_before: String
## Se INSULANO_LLM_URL existia antes do teste corrente. Necessário para
## distinguir "variável inexistente" de "variável definida como string vazia":
## sem isto, o after_each apagaria uma variável que existia com valor "".
var _env_existed_before: bool
## Valor de insulano/llm/model antes do teste corrente, para repor o
## ProjectSettings exactamente como estava (test_project_settings_layer_is_actually_read
## muda-o para provar a leitura em runtime e tem de o devolver ao defeito do
## project.godot, senão sujava todos os testes a correr depois deste).
var _project_model_before: Variant


func before_each() -> void:
	_env_before = OS.get_environment("INSULANO_LLM_URL")
	_env_existed_before = OS.has_environment("INSULANO_LLM_URL")
	if _env_existed_before:
		OS.unset_environment("INSULANO_LLM_URL")
	_project_model_before = ProjectSettings.get_setting("insulano/llm/model")


func after_each() -> void:
	if _env_existed_before:
		OS.set_environment("INSULANO_LLM_URL", _env_before)
	elif OS.has_environment("INSULANO_LLM_URL"):
		OS.unset_environment("INSULANO_LLM_URL")
	ProjectSettings.set_setting("insulano/llm/model", _project_model_before)
	var absolute_path := ProjectSettings.globalize_path(TEST_CFG_PATH)
	if FileAccess.file_exists(absolute_path):
		DirAccess.remove_absolute(absolute_path)


func test_defaults_without_file_or_env() -> void:
	# Afirma primeiro contra o motor, chave a chave: prova que as chaves
	# insulano/llm/* existem de facto no project.godot (tabela do tech_design.md
	# §3), não apenas que o LLMSettings tem os mesmos defeitos hard-coded.
	assert_true(ProjectSettings.has_setting("insulano/llm/enabled"))
	assert_eq(ProjectSettings.get_setting("insulano/llm/enabled"), true)
	assert_true(ProjectSettings.has_setting("insulano/llm/url"))
	assert_eq(ProjectSettings.get_setting("insulano/llm/url"), "http://127.0.0.1:11434")
	assert_true(ProjectSettings.has_setting("insulano/llm/model"))
	assert_eq(ProjectSettings.get_setting("insulano/llm/model"), "llama3.1:8b")
	assert_true(ProjectSettings.has_setting("insulano/llm/timeout_s"))
	assert_eq(ProjectSettings.get_setting("insulano/llm/timeout_s"), 8.0)
	assert_true(ProjectSettings.has_setting("insulano/llm/min_interval_s"))
	assert_eq(ProjectSettings.get_setting("insulano/llm/min_interval_s"), 30.0)

	var settings := LLMSettings.load_settings("user://nao_existe_llm_settings.cfg")
	assert_eq(settings.enabled, true)
	assert_eq(settings.url, "http://127.0.0.1:11434")
	assert_eq(settings.model, "llama3.1:8b")
	assert_eq(settings.timeout_s, 8.0)
	assert_eq(settings.min_interval_s, 30.0)


func test_cfg_file_overrides_model_and_timeout() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("llm", "model", "outro-modelo")
	cfg.set_value("llm", "timeout_s", 3.5)
	assert_eq(cfg.save(TEST_CFG_PATH), OK)

	var settings := LLMSettings.load_settings(TEST_CFG_PATH)
	assert_eq(settings.model, "outro-modelo")
	assert_eq(settings.timeout_s, 3.5)
	# Chaves não sobrepostas continuam no defeito do projecto.
	assert_eq(settings.url, "http://127.0.0.1:11434")


func test_env_var_overrides_cfg_url() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("llm", "url", "http://127.0.0.1:9999")
	assert_eq(cfg.save(TEST_CFG_PATH), OK)
	OS.set_environment("INSULANO_LLM_URL", "http://127.0.0.1:1")

	var settings := LLMSettings.load_settings(TEST_CFG_PATH)
	assert_eq(settings.url, "http://127.0.0.1:1")


func test_project_settings_layer_is_actually_read() -> void:
	# "modelo-de-prova" não é o defeito hard-coded de llm_settings.gd:15
	# ("llama3.1:8b"): se load_settings deixasse de ler ProjectSettings (ou
	# lesse a chave errada), este valor nunca apareceria em settings.model e
	# o teste falhava, ao contrário de test_defaults_without_file_or_env, que
	# não distingue "leu o motor" de "coincidiu com o defeito hard-coded".
	ProjectSettings.set_setting("insulano/llm/model", "modelo-de-prova")

	var settings := LLMSettings.load_settings("user://nao_existe_llm_settings.cfg")
	assert_eq(settings.model, "modelo-de-prova")
