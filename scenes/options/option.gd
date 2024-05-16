class_name Option extends Control

signal changed(value)

@export var key: String


func _ready() -> void:
	if self.key in Options.options:
		self.set_option(Options.options[self.key], false)


func get_option():
	return Options.options[self.key]


func set_option(value, emit := true) -> void:
	Options.options[self.key] = value
	if emit:
		self.changed.emit(value)
