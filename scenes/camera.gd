class_name Camera extends Camera2D

signal zoom_changed
signal position_changed

@export var min_speed: float
@export var max_speed: float
@export var min_zoom: Vector2
@export var max_zoom: Vector2
@export var acceleration_time: float

@onready var default_zoom := self.zoom

var velocity := Vector2.ZERO


func _process(delta: float) -> void:
	var digital_input := Input.get_vector(
		&"digital_pan_left", &"digital_pan_right", &"digital_pan_up", &"digital_pan_down"
	).normalized()
	var analog_input := Input.get_vector(
		&"analog_pan_left", &"analog_pan_right", &"analog_pan_up", &"analog_pan_down"
	).normalized()
	var input: Vector2
	if not analog_input.is_zero_approx():
		input = analog_input
	else:
		input = digital_input

	var top_speed: float = (
		self.min_speed
		+ (self.max_speed - self.min_speed)
		* Options.options.get("camera_speed", 0.5)
	)
	var target_velocity := input * top_speed / self.zoom

	var smooth := analog_input == Vector2.ZERO
	if smooth:
		self.velocity = self.velocity.lerp(target_velocity, delta / self.acceleration_time)
	else:
		self.velocity = target_velocity

	if not self.velocity.is_zero_approx():
		self.position += self.velocity * delta
		self.position_changed.emit()


func reset_zoom() -> void:
	if self.zoom != self.default_zoom:
		self.zoom = self.default_zoom
		self.zoom_changed.emit()


func zoom_by(zoom_factor: Vector2) -> void:
	var old_zoom := self.zoom
	var old_mouse_position := self.get_global_mouse_position()
	# Round to ensure that integral, pixel-perfect zooming
	self.zoom = (self.zoom + zoom_factor).round().clamp(self.min_zoom, self.max_zoom)
	if self.zoom != old_zoom:
		var new_mouse_position := self.get_global_mouse_position()
		self.position += old_mouse_position - new_mouse_position
		self.zoom_changed.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		self.zoom_by(Vector2.ONE)
	if event.is_action_pressed(&"zoom_out"):
		self.zoom_by(-Vector2.ONE)
	if event.is_action_pressed(&"zoom_reset"):
		self.reset_zoom()
	if event is InputEventMouseMotion and Input.is_action_pressed(&"drag_camera"):
		var relative := (event as InputEventMouseMotion).relative
		if relative != Vector2.ZERO:
			self.position -= relative / self.zoom
			self.position_changed.emit()
