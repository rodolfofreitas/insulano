class_name IDirector
extends Resource
## Contrato que SimpleDirector e LLMDirector satisfazem.
## Quem usa a direccao nunca sabe qual implementacao esta activa.


## Devolve a directiva actual para o EventDirector executar.
func get_directive() -> DirectorDirective:
	return DirectorDirective.new()


## True se o director esta pronto a fornecer directivas.
func is_available() -> bool:
	return true
