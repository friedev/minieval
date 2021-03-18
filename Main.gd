extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# This section controls the camera with directional inputs
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= 2.5
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += 2.5
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= 2.5
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += 2.5
