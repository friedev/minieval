class_name SliderOption extends Option

@export var default: float

@export var slider: Slider


func get_option() -> float:
	return self.slider.value


func set_option(value: float, emit := true) -> void:
	self.slider.set_value_no_signal(value)
	super.set_option(value, emit)


func _on_slider_value_changed(value: float) -> void:
	self.set_option(value)
