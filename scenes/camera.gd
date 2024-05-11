extends Camera2D

@onready var default_zoom := self.zoom
@onready var default_offset := self.offset


func _process(delta: float) -> void:
	var input := Vector2(
		Input.get_axis(&"pan_left", &"pan_right"),
		Input.get_axis(&"pan_up", &"pan_down")
	)
	self.position = self.position.lerp(
		self.position + input * Global.speed,
		Global.speed * delta
	)


func reset_zoom() -> void:
	self.zoom = self.default_zoom
	self.position += self.offset - self.default_offset
	self.offset = self.default_offset


func zoom_by(zoomfactor: float) -> void:
	var new_zoom_level := (self.zoom * zoomfactor).x
#	if new_zoom_level > 1 or new_zoom_level < 0.0625:
#		return

	self.zoom *= zoomfactor
	# Compensate for the upcoming offset change by adjusting the position
	# This way, the camera zooms out from the center rather than the top left
	self.position += offset - offset * zoomfactor
	# Update offset so that the camera's origin remains at the top left
	self.offset *= zoomfactor


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		self.zoom_by(2.0)
	if event.is_action_pressed(&"zoom_out"):
		self.zoom_by(0.5)
	if event.is_action_pressed(&"zoom_reset"):
		self.reset_zoom()
