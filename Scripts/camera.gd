extends Camera2D

@export var player: Bunny
var currentCell: Vector2i
var size := 800

func _ready() -> void: 
	updateCameraPosition()
	
func _physics_process(delta: float) -> void:
	updateCameraPosition()

func updateCameraPosition() -> void: 
	currentCell = Vector2i(player.global_position) / Vector2i(size, size)
	var cameraPosition = Vector2(currentCell.x * size + size / 2, currentCell.y * size + size / 2)
	
	global_position = cameraPosition
