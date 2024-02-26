extends Panel

class_name EggCounter

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var empty = load("res://Assets/emptyBasket.png")
@onready var oneEgg = load("res://Assets/oneEggBasket.png")
@onready var twoEgg = load("res://Assets/twoEggBasket.png")
@onready var threeEgg = load("res://Assets/threeEggBasket.png")
@onready var fourEgg = load("res://Assets/fourEggBasket.png")

@onready var sprite: TextureRect = $TextureRect

func _process(delta: float) -> void: 
	checkBasket(player.eggsCollected)

func checkBasket(eggs: int) -> void: 
	match eggs: 
		0: sprite.texture = empty
		1: sprite.texture = oneEgg
		2: sprite.texture = twoEgg
		3: sprite.texture = threeEgg
		_: sprite.texture = fourEgg
	
