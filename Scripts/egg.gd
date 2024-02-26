extends Area2D

class_name Egg

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var audioPlayer = $Audio
var originHole: Hole

func _ready() -> void:
	audioPlayer.finished.connect(deleteEgg)
	body_entered.connect(on_body_entered)
	

func on_body_entered(body: Node2D) -> void: 
	# If the player collects an egg
	if body is Bunny: 
		var player: Bunny = body as Bunny
		
		# Add egg to player total
		player.eggsCollected += 1
		
		sprite.hide()
		collision.queue_free()
		
		# If the egg came from a pit, remove egg from pit
		if originHole != null: 
			originHole.hasEgg = false
			
		audioPlayer.play()

func deleteEgg() -> void: 
	queue_free()
