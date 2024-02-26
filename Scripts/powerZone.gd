extends Area2D

class_name PowerZone

signal run_away

const SIZE := 800
const EDGE := 20
var currentCell: Vector2i


@onready var world: World = get_node("/root/EasterBunny")
@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var head: Head = get_node("/root/EasterBunny/Bunny/Head")
@onready var timer: Timer = $Timer
@onready var audioPlayer = $Audio

@export var eggIndicator: PackedScene
@export var candyItem: PackedScene
var currentIndicator

var power := "none"
var playerInRange := false

func _ready() -> void: 
	randomize()
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	head.used_power.connect(use_power)


func on_body_entered(body: Node2D) -> void: 
	if body is Bunny: 
		var player: Bunny = body as Bunny
		player.availablePower = power
		playerInRange = true
		

func on_body_exited(body: Node2D) -> void: 
	if body is Bunny: 
		var player: Bunny = body as Bunny
		player.availablePower = "none"
		playerInRange = false

func use_power(): 
	# Using a power only works if the player is within range
	if playerInRange: 
		match power: 
			"egg": 
				audioPlayer.play()
				revealEgg()
			"candy": 
				audioPlayer.finished.connect(deleteZone)
				audioPlayer.play()
				revealCandy()
			"twister":
				audioPlayer.play()
				repelEnemies()
			"landingZone": land()



func revealEgg(): 
	var holes: Array
	currentCell = Vector2i(player.global_position) / Vector2i(SIZE, SIZE)
	
	# Get the current set of pits based on the cell
	if currentCell == Vector2i(1, 0): 
		holes = world.top
	elif currentCell == Vector2i(0, 1): 
		holes = world.yellow
	elif currentCell == Vector2i(1, 1): 
		holes = world.orange
	elif currentCell == Vector2i(0, 2): 
		holes = world.bottom
	
	if holes.size() != 0: 
		# Check each hole for an egg
		for i in range(holes.size()): 
			var current = holes[i]
			if current.hasEgg: 
				# If a hole has an egg, create an indicator at that pit
				var newIndicator = eggIndicator.instantiate()
				get_tree().root.add_child(newIndicator)
				newIndicator.global_position = Vector2(current.global_position.x, current.global_position.y)
	
	player.energy -= 100
				
		
	
func revealCandy(): 
	# Get the current cell
	currentCell = Vector2i(player.global_position) / Vector2i(SIZE, SIZE)
	
	# Generate 1-3 candies
	var candiesToGenerate := (randi() % 3) + 1
	
	# Get the bounds of the screen (plus a little space around the edges)
	var minX := SIZE * currentCell.x + EDGE
	var minY := SIZE * currentCell.y + EDGE
	var maxX := SIZE * currentCell.x + SIZE - EDGE
	var maxY := SIZE * currentCell.y + SIZE - EDGE
	
	# Generate the random number of candies within the bounds
	for i in range(candiesToGenerate): 
		var newCandy = candyItem.instantiate()
		get_tree().root.add_child(newCandy)
		newCandy.global_position = Vector2((randi() % (maxX - minX)) + minX, 
											(randi() % (maxY - minY)) + minY)
	
	player.energy -= 100

func repelEnemies(): 
	var enemies: Array = get_tree().get_nodes_in_group("Enemy")
	
	for i in range(enemies.size()): 
		var current = enemies[i]
		if current is Agent: 
			var agent: Agent = current as Agent
			agent.runningAway = true
		elif current is Scientist: 
			var scientist: Scientist = current as Scientist
			scientist.runningAway = true
	
	player.energy -= 100


func land():
	if player.eggsCollected >= 4: 
		var enemies: Array = get_tree().get_nodes_in_group("Enemy")
		for i in range(enemies.size()): 
			var current = enemies[i]
			current.stopped = true

		player.beamingUp = true

func deleteZone() -> void: 
	queue_free()
