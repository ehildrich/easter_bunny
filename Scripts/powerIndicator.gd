extends Panel

class_name PowerIndicator

const YELLOW := Color("f8e070")
const ORANGE := Color("f0a860")
const PURPLE := Color("b890f8")

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var egg = load("res://Assets/eggrevealicon.png")
@onready var candy = load("res://Assets/candyrevealicon.png")
@onready var twister = load("res://Assets/confuseenemyicon.png")
@onready var landingZone = load("res://Assets/landingzoneicon.png")

@onready var sprite: TextureRect = $TextureRect

func _process(delta: float) -> void: 
	checkPower(player.availablePower)

func checkPower(power: String) -> void: 
	match power: 
		"egg": 
			sprite.texture = egg
			set_modulate(YELLOW)
		"candy": 
			sprite.texture = candy
			set_modulate(YELLOW)
		"twister": 
			sprite.texture = twister
			set_modulate(ORANGE)
		"landingZone": 
			sprite.texture = landingZone
			set_modulate(ORANGE)
		_: 
			sprite.texture = null
			set_modulate(PURPLE)
	
