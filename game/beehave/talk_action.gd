@tool
extends ActionLeaf

class_name TalkAction

@export var texts: PackedStringArray

func tick(actor: Node, blackboard: Blackboard) -> int:
	var character = actor as Character
	
	if texts != null && texts.size() > 0:
		var index: int = randi_range(0, texts.size() - 1)
		character.talking_text = texts[index]
	else:
		character.talking_text = ""
	return SUCCESS
