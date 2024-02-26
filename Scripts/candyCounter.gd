extends Label

class_name CandyCounter

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")

func _process(delta: float) -> void: 
	text = str(player.candyCollected)
