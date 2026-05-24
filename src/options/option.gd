class_name Option
extends Control

signal changed(value)

@export var key: String


func _ready() -> void:
	if key in Options.options:
		set_option(Options.options[key], false)


func get_option():
	return Options.options[key]


func set_option(value, emit := true) -> void:
	Options.options[key] = value
	if emit:
		changed.emit(value)
