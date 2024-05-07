extends Container


@onready var main := self.get_node("/root/Main")
@onready var tilemap := self.main.find_child("TileMap")
@onready var pause := self.main.find_child("Pause")
@onready var black_overlay := self.main.find_child("BlackOverlay")


func _ready() -> void:
	if Global.tutorial_seen:
		self.close_tutorial()
	else:
		self.open_tutorial()


func open_tutorial() -> void:
	self.pause.set_process_input(false)
	self.call_deferred("show")


func close_tutorial() -> void:
	self.hide()
	self.pause.set_process_input(true)
	Global.tutorial_seen = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		self.close_tutorial()


func _on_Tutorial_visibility_changed() -> void:
	if self.black_overlay != null:
		self.black_overlay.visible = self.visible
	if self.tilemap != null:
		self.tilemap.in_menu = self.visible


func _on_play_button_pressed() -> void:
	self.close_tutorial()
