extends Popup


onready var main := self.get_node("/root/Main")
onready var pause := self.main.find_node("Pause")
onready var black_overlay := self.main.find_node("BlackOverlay")


func _ready() -> void:
	if Global.tutorial_seen:
		close_tutorial()
	else:
		open_tutorial()


func open_tutorial() -> void:
	pause.set_process_input(false)
	self.call_deferred("popup")


func close_tutorial() -> void:
	visible = false
	pause.set_process_input(true)
	Global.tutorial_seen = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_tutorial()


func _on_PlayButton_pressed() -> void:
	close_tutorial()


func _on_Tutorial_visibility_changed():
	black_overlay.visible = self.visible
