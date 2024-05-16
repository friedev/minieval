class_name CheckBoxOption extends Option

@export var default: bool

@export var check_box: CheckBox


func get_option() -> bool:
	return self.check_box.button_pressed


func set_option(value: bool, emit := true) -> void:
	self.check_box.set_pressed_no_signal(value)
	super.set_option(value, emit)


func _on_check_box_toggled(button_pressed: bool) -> void:
	self.set_option(button_pressed)
