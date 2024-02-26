extends PanelContainer

class_name ScoreScreen

@onready var player: Bunny = get_node("/root/EasterBunny/Bunny")
@onready var scoreLabel: Label = $VBoxContainer/Total
@onready var timer = $Timer

var canStart := false
var died := false

var scoreFile = "user://score.save"
var highScore := 0
var currentScore := 0

const CANDY_VALUE = 300

func _ready() -> void: 
	loadScore()
	player.died.connect(calcScoreDied)
	player.won.connect(calculateScore)
	timer.timeout.connect(start)

func _process(delta: float) -> void: 
	if Input.is_action_pressed("power") and canStart: 
		if died: 
			currentScore = 0
			saveScore()
			get_tree().change_scene_to_file("res://Scenes/title.tscn")
		else: 
			get_tree().change_scene_to_file("res://Scenes/easterBunny.tscn")
			

func calcScoreDied() -> void: 
	calculateScore()
	died = true

func calculateScore() -> void: 
	currentScore = player.energy + (player.candyCollected * CANDY_VALUE) + currentScore
	if currentScore > highScore: 
		highScore = currentScore
	scoreLabel.text = str(currentScore)
	
	show()
	timer.start()
	
	saveScore()
	
	
func start() -> void: 
	canStart = true

func saveScore():
	var savedScore = FileAccess.open(scoreFile, FileAccess.WRITE)
	savedScore.store_var(currentScore)
	

func loadScore():
	if not FileAccess.file_exists(scoreFile):
		currentScore = 0 # Error! We don't have a save to load.
		
	else: 
		var savedScore = FileAccess.open(scoreFile, FileAccess.READ)
		currentScore = savedScore.get_var()

