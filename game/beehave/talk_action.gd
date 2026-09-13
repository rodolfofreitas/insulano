@tool
class_name TalkAction
extends ActionLeaf
## Escolhe ao acaso uma frase de `texts` e escreve-a em `character.talking_text`.
##
## Com `texts` vazio, limpa a fala (`talking_text = ""`). Sempre `SUCCESS`: é
## uma acção instantânea, nunca bloqueia a árvore.

@export var texts: PackedStringArray


## Ignora o blackboard; sorteia uma frase de `texts` para o actor dizer.
func tick(actor: Node, _blackboard: Blackboard) -> int:
	var character = actor as Character

	if texts != null && texts.size() > 0:
		var index: int = randi_range(0, texts.size() - 1)
		character.talking_text = texts[index]
	else:
		character.talking_text = ""
	return SUCCESS
