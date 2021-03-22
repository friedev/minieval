extends Camera2D

export var speed = 10.0
export var zoomspeed = 10.0
export var zoommargin = 0.1

var default_zoom = Vector2(0.25, 0.25)
var default_offset = Vector2(128, 75)


func _process(delta):
	var input_x = (int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")))
	var input_y = (int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")))
	var input = Vector2(input_x, input_y)

	position = lerp(position, position + input * speed, speed * delta)


func reset_zoom():
	zoom = default_zoom
	position += offset - default_offset
	offset = default_offset


func zoom(zoomfactor):
	var new_zoom_level = (zoom * zoomfactor).x
	if new_zoom_level > 1 or new_zoom_level < 0.0625:
		return
	
	zoom *= zoomfactor
	# Compensate for the upcoming offset change by adjusting the position
	# This way, the camera zooms out from the center rather than the top left
	position += offset - offset * zoomfactor
	# Update offset so that the camera's origin remains at the top left
	offset *= zoomfactor


func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom(0.5)
	if event.is_action_pressed("zoom_out"):
		zoom(2)
	if event.is_action_pressed("zoom_reset"):
		reset_zoom()
