extends Camera2D

export var speed = 10.0
export var zoomspeed = 10.0
export var zoommargin = 0.1


var zoompos = Vector2()
var zoomfactor = 1.0
var zooming = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Prevents camera from updating during this method
	# Instead, all changes happen simultaneously at the end
	current = false
	
	# This section controls the camera with directional inputs
	var inpx = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	var inpy = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))

	position.x = lerp(position.x, position.x + inpx *speed, speed * delta)
	position.y = lerp(position.y, position.y + inpy *speed, speed * delta)
	
	# Zoom function
	zoom.x = lerp(zoom.x, zoom.x * zoomfactor, zoomspeed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoomfactor, zoomspeed * delta)
	# Update offset so that the camera's origin remains at the top left
	var old_offset = offset
	offset.x = lerp(offset.x, offset.x * zoomfactor, zoomspeed * delta)
	offset.y = lerp(offset.y, offset.y * zoomfactor, zoomspeed * delta)
	# Compensate for the offset change by adjusting the position
	# This way, the camera zooms out from the center rather than the top left
	position += old_offset - offset
	
	if not zooming:
		zoomfactor = 1.0
	
	current = true

func _input(event):
	if abs(zoompos.x - get_global_mouse_position().x) > zoommargin:
		zoomfactor = 1.0
	if abs(zoompos.y - get_global_mouse_position().y) > zoommargin:
		zoomfactor = 1.0
	if event is InputEventMouseButton:
		if event.is_pressed():
			zooming = true
			if event.button_index == BUTTON_WHEEL_UP:
				zoomfactor -= 0.01 * zoomspeed
				zoompos = get_global_mouse_position()
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoomfactor += 0.01 * zoomspeed
				zoompos = get_global_mouse_position()
		else:
			zooming = false
