class_name Camera extends Camera2D

@onready var default_zoom := self.zoom


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


func zoom_by(zoomfactor: float) -> void:
	var new_zoom_level := (self.zoom * zoomfactor).x
#	if new_zoom_level > 1 or new_zoom_level < 0.0625:
#		return
	self.zoom *= zoomfactor


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		self.zoom_by(2.0)
	if event.is_action_pressed(&"zoom_out"):
		self.zoom_by(0.5)
	if event.is_action_pressed(&"zoom_reset"):
		self.reset_zoom()
