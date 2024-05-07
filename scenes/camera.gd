extends Camera2D

@onready var default_zoom := self.zoom
@onready var default_offset := self.offset


func _process(delta: float) -> void:
	var input_x := (
		int(Input.is_action_pressed(&"pan_right"))
		- int(Input.is_action_pressed(&"pan_left"))
	)
	var input_y := (
		int(Input.is_action_pressed(&"pan_down"))
		- int(Input.is_action_pressed(&"pan_up"))
	)
	var input := Vector2(input_x, input_y)
	position = lerp(
		position,
		position + input * Global.speed,
		Global.speed * delta
	)


func reset_zoom() -> void:
	zoom = default_zoom
	position += offset - default_offset
	offset = default_offset


func zoom_by(zoomfactor: float) -> void:
	var new_zoom_level := (zoom * zoomfactor).x
#	if new_zoom_level > 1 or new_zoom_level < 0.0625:
#		return

	zoom *= zoomfactor
	# Compensate for the upcoming offset change by adjusting the position
	# This way, the camera zooms out from the center rather than the top left
	position += offset - offset * zoomfactor
	# Update offset so that the camera's origin remains at the top left
	offset *= zoomfactor


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		zoom_by(2.0)
	if event.is_action_pressed(&"zoom_out"):
		zoom_by(0.5)
	if event.is_action_pressed(&"zoom_reset"):
		reset_zoom()
