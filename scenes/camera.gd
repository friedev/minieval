class_name Camera extends Camera2D

@export var min_speed: float
@export var max_speed: float
@export var min_zoom: Vector2
@export var max_zoom: Vector2

@onready var default_zoom := self.zoom


func _process(delta: float) -> void:
	var input := Vector2(
		Input.get_axis(&"pan_left", &"pan_right"),
		Input.get_axis(&"pan_up", &"pan_down")
	)
	var speed: float = (
		self.min_speed
		+ (self.max_speed - self.min_speed)
		* Options.options.get("camera_speed", 0.5)
	)
	self.position = self.position.lerp(
		self.position + input * speed,
		speed * delta
	)


func reset_zoom() -> void:
	self.zoom = self.default_zoom


func zoom_by(zoom_factor: float) -> void:
	var old_mouse_position := self.get_global_mouse_position()
	self.zoom *= zoom_factor
	self.zoom = self.zoom.clamp(self.min_zoom, self.max_zoom)
	var new_mouse_position := self.get_global_mouse_position()
	self.position += old_mouse_position - new_mouse_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"zoom_in"):
		self.zoom_by(2.0)
	if event.is_action_pressed(&"zoom_out"):
		self.zoom_by(0.5)
	if event.is_action_pressed(&"zoom_reset"):
		self.reset_zoom()
