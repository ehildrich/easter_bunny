extends Sprite2D

class_name EggIndicator

@onready var timer = $Timer

func _ready() -> void: 
	# Indicator deletes itself once the autostart timer runs out
	# Timer starts upon instantiation 
	timer.timeout.connect(indicator_timeout)

func indicator_timeout() -> void: 
	queue_free()
