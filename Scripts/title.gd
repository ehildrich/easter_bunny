extends Node2D

class_name Title

@onready var timer = $CanStart

var canStart := false

func _ready() -> void: 
	timer.timeout.connect(start)

func _process(delta: float) -> void: 
	if Input.is_action_pressed("power") and canStart: 
		get_tree().change_scene_to_file("res://Scenes/easterBunny.tscn")

func start() -> void: 
	canStart = true
