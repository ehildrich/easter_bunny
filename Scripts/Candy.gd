extends Area2D

class_name Candy

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var audioPlayer = $Audio
var originHole: Hole = null

func _ready() -> void:
	audioPlayer.finished.connect(deleteCandy)
	body_entered.connect(on_body_entered)
	

func on_body_entered(body: Node2D) -> void: 
	# If the player collects a candy
	if body is Bunny: 
		var player: Bunny = body as Bunny
		# Add candy to player total
		player.candyCollected += 1
		
		sprite.hide()
		collision.queue_free()
		
		# If the candy came from a pit, decrement that pit's counter
		if originHole != null: 
			originHole.candy = clamp(originHole.candy - 1, 0, 3)
		
		audioPlayer.play()

func deleteCandy() -> void: 
	queue_free()
