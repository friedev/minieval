class_name FullscreenOption
extends CheckBoxOption

var previous_value: bool


func _ready() -> void:
	previous_value = default


func get_option() -> bool:
	var window_mode := get_window().mode
	return (
		window_mode == Window.MODE_FULLSCREEN
		or window_mode == Window.MODE_EXCLUSIVE_FULLSCREEN
	)


func set_option(value: bool, emit := true) -> void:
	get_window().mode = (
		Window.MODE_EXCLUSIVE_FULLSCREEN
		if value
		else Window.MODE_WINDOWED
	)
	super.set_option(value, emit)


func _process(delta: float) -> void:
	# Ideally this would trigger via a signal or notification, but I can't find
	# one that deals with window mode changes
	# Tried:
	# - NOTIFICATION_WM_SIZE_CHANGED
	# - Window.titlebar_changed
	# - Viewport.size_changed
	var current_value := get_option()
	if current_value != previous_value:
		previous_value = current_value
		set_option(current_value)
