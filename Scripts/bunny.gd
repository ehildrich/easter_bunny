extends CharacterBody2D

class_name Bunny

signal died
signal won

var candyCollected := 0
var eggsCollected := 0
var availablePower := "none"
var energy := 9999

const PIT_POSITION := Vector2(2000, 115)
const START_POSITION := Vector2(-50, 275)

const MOVE_SPEED := 400.0
const SHIP_SPEED := 40.0
var movement: Vector2
@export var speedMultiplier := 1.0

@onready var body := $Body
@onready var bodySprite := $Body
@onready var deadSprite := $DeadSprite
@onready var head := $Head
@onready var headSprite := $Head/HeadSprite
@onready var collision := $CollisionShape2D
@onready var ship := $Ship

@onready var energyTimer := $Timer
@onready var walkTimer := $WalkTimer

@onready var audioPlayer := $Audio
@onready var walkAudio := $WalkAudio

# Used for beaming up/down animations
var beamingDown := true
var beamingUp := false
var beamState := "center"
var shipPosition: Vector2
var bunnyPosition: Vector2
var beamUpSoundPlayed := false

var dead := false

var direction := false

var priorPosition: Vector2
var pit := false
var is_floating := false

func _ready() -> void:
	audioPlayer.play()
	energyTimer.timeout.connect(drainEnergy)
	walkTimer.timeout.connect(walkTimeout)
	global_position = START_POSITION

func _physics_process(delta: float) -> void: 
	if dead: 
		movement = Vector2.ZERO
		if Input.is_action_pressed("power"): 
			died.emit()
	elif beamingDown: 
		head.beaming = true
		beamingDownAnim()
	elif beamingUp: 
		head.beaming = true
		if not beamUpSoundPlayed: 
			audioPlayer.play()
			beamUpSoundPlayed = true
		beamingUpAnim()
	elif pit: 
		movePit()
		checkPitPosition()
	else: 
		move()
		checkPosition()


func beamingDownAnim(): 
	if beamState == "center": 
		velocity = Vector2(1.0, 0.0) * MOVE_SPEED * speedMultiplier
		if global_position.x > 400: 
			beamState = "down"
			shipPosition = global_position
		
		move_and_slide()
		
	elif beamState == "down": 
		velocity = Vector2(0.0, 1.0) * MOVE_SPEED * speedMultiplier
		ship.global_position = shipPosition
		if global_position.y > 475: 
			beamState = "shipLeave"
			bunnyPosition = global_position
		
		move_and_slide()
	
	elif beamState == "shipLeave": 
		ship.velocity = Vector2(1.0, 0.0) * MOVE_SPEED * speedMultiplier * 3
		global_position = bunnyPosition
		if ship.global_position.x > 1300: 
			beamingDown = false
			head.beaming = false
			beamState = "bunny"
		
		ship.move_and_slide()

func beamingUpAnim(): 
	if beamState == "bunny": 
		ship.velocity = Vector2(-1.0, 0.0) * MOVE_SPEED * speedMultiplier * 2
		if ship.global_position.x < global_position.x: 
			shipPosition = ship.global_position
			beamState = "up"
		
		ship.move_and_slide()
		
	elif beamState == "up": 
		velocity = Vector2(0.0, -1.0) * MOVE_SPEED * speedMultiplier
		ship.global_position = shipPosition
		if global_position.y < ship.global_position.y: 
			beamState = "away"
		
		move_and_slide()
	
	elif beamState == "away": 
		velocity = Vector2(-1.0, 0.0) * MOVE_SPEED * speedMultiplier
		if global_position.x < -100: 
			beamingUp = false
			beamUpSoundPlayed = false
			won.emit()
		
		move_and_slide()


# Movement when on the overworld
func move() -> void: 
	# Each frame, start with zero movement
	movement = Vector2.ZERO
	
	# If moving up or down, add that velocity
	if Input.is_action_pressed("moveUp"): movement.y -= 1.0
	if Input.is_action_pressed("moveDown"): movement.y += 1.0
	# Then add horizontal movement
	movement = moveHorizontal(movement)
	
	# Play a walking animation when moving
	if movement != Vector2.ZERO or is_floating: 
		body.play("Walk")
	else: 
		body.stop()
	
	# Apply movement
	velocity = movement * MOVE_SPEED * speedMultiplier
	move_and_slide()


# Movement when inside a pit
func movePit(): 
	# Start with zero movement
	movement = Vector2.ZERO
	
	if is_floating: 
		movement.y -= 1.25
	else: 
		movement.y += 2.0
	movement = moveHorizontal(movement)
	
	velocity = movement * MOVE_SPEED * speedMultiplier
	move_and_slide()


func moveHorizontal(movement: Vector2) -> Vector2: 
	if Input.is_action_pressed("moveLeft"): 
		movement.x -= 1.0
		direction = false
	if Input.is_action_pressed("moveRight"): 
		movement.x += 1.0
		direction = true
		
	if direction: 
		body.flip_h = true
		head.position.x = body.position.x + 23
	else: 
		body.flip_h = false
		head.position.x = body.position.x
	
	return movement
	

# Wraps the player back into the play field if they walk out of it
func checkPosition(): 
	# If you go into the negatives, wrap around to the positives
	if (position.x < 0): 
		position.x += 1600
	# If you go too far into the positives, wrap around to less than the max
	else: 
		position.x = int(position.x) % 1600
	
	# If you go into the negatives, wrap around to the positives
	if (position.y < 0): 
		position.y += 2400
	# If you go too far into the positives, wrap around to less than the max
	else: 
		position.y = int(position.y) % 2400


func checkPitPosition(): 
	if position.y < PIT_POSITION.y - 1: 
		collision.disabled = true
		position = Vector2(priorPosition.x, priorPosition.y - 25)
		pit = false
		head.pit = false
		clearPit()
	
func clearPit(): 
	var pitItems: Array = get_tree().get_nodes_in_group("PitItems")
	for i in range(pitItems.size()): 
		pitItems[i].queue_free()

func drainEnergy() -> void: 
	if movement != Vector2.ZERO: 
		energy = clamp(energy - 1, 0, 9999)
		if energy == 0: 
			dead = true
			headSprite.hide()
			bodySprite.hide()
			deadSprite.show()
			collision.disabled = true
			
			var enemies: Array = get_tree().get_nodes_in_group("Enemy")
			for i in range(enemies.size()): 
				var current = enemies[i]
				current.stopped = true
			

func walkTimeout() -> void: 
	if movement != Vector2.ZERO: 
		walkAudio.play()

func _on_head_floating() -> void:
	is_floating = true

func _on_head_not_floating() -> void:
	is_floating = false
	collision.disabled = false


