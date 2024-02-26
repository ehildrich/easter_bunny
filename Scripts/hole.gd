extends Area2D

class_name Hole

const GLOBAL_EGG_POSITION := Vector2(1850, 715)
const GLOBAL_CANDY_Y := 735
const GLOBAL_CANDY_X := [1850, 2000, 2150]

@export var eggItem: PackedScene
@export var candyItem: PackedScene

var hasEgg := false
var candy := 0

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var head: Head = get_node("/root/EasterBunny/Bunny/Head")

func _ready() -> void: 
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void: 
	if body is Bunny: 
		var player: Bunny = body as Bunny
		player.priorPosition = position
		player.position = player.PIT_POSITION
		player.pit = true
		head.pit = true
		
		if hasEgg: 
			spawnEgg()
		elif candy > 0: 
			spawnCandy(candy)



func spawnEgg() -> void: 
	var newEgg = eggItem.instantiate()
	newEgg.add_to_group("PitItems")
	owner.add_child(newEgg)
	newEgg.global_position = GLOBAL_EGG_POSITION
	newEgg.originHole = self

func spawnCandy(candy: int) -> void: 
	for i in range(candy): 
		var newCandy = candyItem.instantiate()
		newCandy.add_to_group("PitItems")
		owner.add_child(newCandy)
		newCandy.global_position = Vector2(GLOBAL_CANDY_X[i], GLOBAL_CANDY_Y)
		newCandy.originHole = self
