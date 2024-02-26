extends Node2D

class_name World

@export var powerZone: PackedScene
@export var agent: PackedScene
@export var scientist: PackedScene

const PIT_CELLS := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
const SIZE := 800
const EDGE := 40
const AGENT_SPAWN = Vector2(1109, 2171)
const SCIENTIST_SPAWN = Vector2(1300, 1840)

const TWISTER_ZONES = 8

var holes: Array
var yellow: Array
var top: Array
var orange: Array
var bottom: Array

var nextSpawn = "s"


func _ready() -> void: 
	holes = get_tree().get_nodes_in_group("Holes")
	randomizeHoleContents(holes)
	scatterPowerZones()
	
	spawnEnemy()
	

func randomizeHoleContents(holes: Array) -> void: 
	yellow = holes.slice(0, 4)
	top = holes.slice(4, 8)
	orange = holes.slice(8, 12)
	bottom = holes.slice(12, 16)
	
	var splitHoles := [top, bottom, yellow, orange]
	for i in range(splitHoles.size()): 
		var current: Array = splitHoles[i]
		current.shuffle()
		current[0].hasEgg = true
		current[1].candy = 1
		current[2].candy = 2
		current[3].candy = 3

func distributeEgg() -> void: 
	# Get a random hole by shuffling them
	holes.shuffle()
	var index = 0
	var current = holes[index]
	
	# Roll through the list until we find a hole that doesn't 
	# already have an egg
	while current.hasEgg == true: 
		index += 1
		current = holes[index]
	
	# Give the hole an egg and remove the candy
	current.hasEgg = true
	current.candy = 0



func scatterPowerZones() -> void: 
	for i in range(PIT_CELLS.size()): 
		var currentCell = PIT_CELLS[i]
		var candyZonesToGenerate := (randi() % 2) + 1
		var minX = SIZE * currentCell.x + EDGE
		var minY = SIZE * currentCell.y + EDGE
		var maxX = SIZE * currentCell.x + SIZE - EDGE
		var maxY = SIZE * currentCell.y + SIZE - EDGE

		for j in range(candyZonesToGenerate): 
			generateZone("candy", Vector2((randi() % (maxX - minX)) + minX, 
										(randi() % (maxY - minY)) + minY))
		
		generateZone("egg", Vector2((randi() % (maxX - minX)) + minX, 
									(randi() % (maxY - minY)) + minY))
		
	for k in range(TWISTER_ZONES): 
		generateZone("twister", Vector2(randi() % (1600 - EDGE) + EDGE, 
									randi() % (2400 - EDGE) + EDGE))
	
	generateZone("landingZone", Vector2(randi() % (800 - EDGE * 2) + EDGE, 
									randi() % (800 - EDGE * 2) + EDGE))
	

func generateZone(power: String, pos: Vector2i) -> void: 
	var newZone := powerZone.instantiate()
	add_child(newZone)
	newZone.global_position = pos
	newZone.power = power

func spawnEnemy() -> void: 
	if nextSpawn == "s": 
		var newScientist := scientist.instantiate()
		add_child(newScientist)
		newScientist.global_position = SCIENTIST_SPAWN
		nextSpawn = "a"
	elif nextSpawn == "a": 
		var newAgent := agent.instantiate()
		add_child(newAgent)
		newAgent.global_position = AGENT_SPAWN
		nextSpawn = "s"
