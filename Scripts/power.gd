extends CharacterBody2D

class_name Head

signal floating
signal not_floating
signal used_power

const MOVE_SPEED := 75.0
@export var speedMultiplier := 1.0

@onready var headSprite = $HeadSprite
@onready var headTimer = $Timer

var beaming := false

var direction := false
var destination := "up"
var movement := Vector2.ZERO

var pit = false
var is_floating = false

func _physics_process(delta: float) -> void: 
	move()

func move() -> void: 
		# If currently in a pit, use pit physics
	if pit: 
		# If not floating, wait for float input, otherwise don't move head
		if not is_floating:
			if Input.is_action_just_pressed("power") and headTimer.is_stopped() and not beaming: 
				raiseHead()
			elif headTimer.is_stopped():
				movement.y = 0.0
		
		# If floating, wait for float cancel, otherwise don't move head
		elif is_floating: 
			if Input.is_action_just_pressed("power") and not beaming:
				lowerHead()
			elif headTimer.is_stopped():
				movement.y = 0.0
			
		# No matter what physics are used, horizontal movement is handled the same
		moveHorizontal()

	# If not currently in a pit, use normal physics
	else: 
		# If we are still floating upon exiting a pit, wait until 
		# player stops floating
		if is_floating: 
			if Input.is_action_just_pressed("power") and headTimer.is_stopped() and not beaming:
				destination = "down"
				lowerHead()
		# Otherwise move as normal
		else:
			# If power button is pressed and timer is not currently running, 
			# start moving upwards until timer runs out
			if Input.is_action_just_pressed("power") and headTimer.is_stopped() and not beaming:
				raiseHead()
				used_power.emit()
			# Once timer runs out, move down instead and start second timer
			elif destination == "down": 
				movement.y = 1.0
			# If neither timer is running then set velocity of the head to 0
			elif headTimer.is_stopped(): 
				movement.y = 0.0
				
		if not beaming: 
			# No matter what physics are used, horizontal movement is handled the same
			moveHorizontal()
	
	# Apply velocity
	velocity = movement * MOVE_SPEED * speedMultiplier
	move_and_slide()

# Move the head upwards
func raiseHead() -> void: 
	movement.y = -1.0
	headTimer.start();

# Move the head downwards
func lowerHead() -> void: 
	movement.y = 1.0
	headTimer.start()

func moveHorizontal(): 
	if Input.is_action_pressed("moveLeft"): 
		direction = false
	if Input.is_action_pressed("moveRight"): 
		direction = true
	
	if direction: 
		headSprite.flip_h = true
	else: 
		headSprite.flip_h = false
	

# Tells the head what to do when each timer runs out
func _on_timer_timeout() -> void:
	# If currently inside a pit
	if pit: 
		if destination == "down": 
			destination = "up"
		# If we're not floating, start floating and emit
		# the signal so the body can start moving
		elif not is_floating: 
			is_floating = true
			floating.emit()
		# If we are floating, stop and emit the signal
		# so the body can fall again
		else: 
			is_floating = false
			not_floating.emit()
	
	# If not currently in a pit
	else: 
		# When the first timer ends, tell the head to start 
		# moving down and start the second timer
		if destination == "up": 
			destination = "down"
			headTimer.start()
		# Once the second timer finishes, reset the destination
		else: 
			destination = "up"
			is_floating = false
			not_floating.emit()

