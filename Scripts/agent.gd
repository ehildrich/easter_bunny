extends CharacterBody2D

class_name Agent

const SPEED := 150.0
@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var world: World = get_node("/root/EasterBunny")
@onready var sprite := $Sprite2D
@onready var hitBox := $Area2D
@onready var timer := $Timer
@onready var audioPlayer := $Audio

var touchedPlayer := false
var runningAway := false
var stopped := false

func _ready() -> void: 
	timer.timeout.connect(flip_sprite)
	hitBox.body_entered.connect(steal)

func _physics_process(delta: float) -> void:
	var movement = Vector2.ZERO
	
	# If the player has been touched, just move upward until off the field
	if touchedPlayer: 
		movement = Vector2(0.0, -400.0)
		if position.y < -50.0:
			deleteEnemy()
	elif runningAway: 
		# If running away, move away from the player until off the field
		movement = position.direction_to(-player.position) * (SPEED * 2)
		if position.x > 1650 or position.x < -50 or position.y < -50 or position.y > 2450: 
			deleteEnemy()
	else: 
		# Enemies must stay within the screen wrap
		checkPosition()
		if not stopped: 
			movement = position.direction_to(player.position) * SPEED
	
	velocity = movement
	move_and_slide()
	
# Each time the timer ends, flip the sprite to simulate walking
func flip_sprite(): 
	if sprite.flip_h: 
		sprite.flip_h = false
	else: 
		sprite.flip_h = true

# When touching the player, steal an egg and set variable
func steal(body: Node2D) -> void: 
	if body is Bunny: 
		var player: Bunny = body as Bunny
		touchedPlayer = true
		
		if player.eggsCollected > 0: 
			player.eggsCollected = clamp(player.eggsCollected - 1, 0, 9999)
			world.distributeEgg()
			
		player.energy = clamp(player.energy - 100, 0, 9999)
		
		audioPlayer.play()


# Wraps the entity back into the play field if they move out of it
func checkPosition(): 
	# If they go into the negatives, wrap around to the positives
	if (position.x < 0): 
		position.x += 1600
	# If they go too far into the positives, wrap around to less than the max
	else: 
		position.x = int(position.x) % 1600
	
	# If they go into the negatives, wrap around to the positives
	if (position.y < 0): 
		position.y += 2400
	# If they go too far into the positives, wrap around to less than the max
	else: 
		position.y = int(position.y) % 2400

func deleteEnemy() -> void: 
	world.spawnEnemy()
	queue_free()
