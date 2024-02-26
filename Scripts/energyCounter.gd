extends Label

class_name EnergyCounter

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")

func _process(delta: float) -> void: 
	text = str(player.energy)
