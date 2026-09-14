class_name PhraseContext
extends RefCounted
## Contexto tipado que descreve a situação do náufrago num dado momento.
##
## Preenchido por quem chama o LLM (SayGeneratedAction, T-106; a gaivota e o
## barco, T-302/T-303) a partir do Clock, da Need de fome e do Weather. Não lê
## nem escreve nada por si: só junta os campos que o PromptBuilder (T-102)
## precisa para preencher game/data/prompts/phrase_prompt.txt. Um campo de
## texto em branco ("") marca o contexto como incompleto: o PromptBuilder
## recusa-se a gerar um prompt com esse contexto. Nota: "hour" não entra
## nesta validação (é int, não texto, e 0 é uma hora válida, meia-noite);
## um "hour" nunca atribuído fica 0 e não é detectado como incompleto.

## Hora do dia, 0-23.
var hour: int = 0
## Período do dia em pt-PT: "madrugada" | "manhã" | "tarde" | "fim da tarde" | "noite".
var period: String = ""
## O que o náufrago está a fazer, verbo no infinitivo com complemento: "pescar", "comer um peixe".
var action: String = ""
## Rótulo de fome em pt-PT (ver PromptBuilder.hunger_label_for):
## "satisfeito" | "com fome" | "esfomeado".
var hunger_label: String = ""
## Tempo em pt-PT: "sol", "chuva forte", "nublado", ...
var weather: String = ""
## Nome do feriado do dia, ou "nenhuma" quando não há nenhum.
var holiday: String = ""


## Devolve os campos no formato que o template phrase_prompt.txt espera
## ({hour}, {period}, {action}, {hunger}, {weather}, {holiday}). As chaves da
## Dictionary são os nomes dos placeholders do template, não os nomes das
## variáveis desta classe (hunger_label vira "hunger", por exemplo).
func to_template_fields() -> Dictionary:
	return {
		"hour": hour,
		"period": period,
		"action": action,
		"hunger": hunger_label,
		"weather": weather,
		"holiday": holiday,
	}
