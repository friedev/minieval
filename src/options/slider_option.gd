class_name SliderOption
extends Option

@export var default: float

@export var slider: Slider


func get_option() -> float:
	return slider.value


func set_option(value: float, emit := true) -> void:
	slider.set_value_no_signal(value)
	super.set_option(value, emit)


func _on_slider_value_changed(value: float) -> void:
	set_option(value)
