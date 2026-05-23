class_name Menu
extends Control

signal opened
signal closed

@export var default_focus: Control
@export var can_go_back := true

var previous_menu: Menu


func open(previous: Menu = null) -> void:
	if visible:
		return
	previous_menu = previous
	show()
	if default_focus != null:
		default_focus.grab_focus()
	Global.is_menu_open = true
	opened.emit()


func close() -> void:
	if not visible:
		return
	hide()
	if can_go_back and previous_menu != null:
		previous_menu.open()
	else:
		Global.is_menu_open = false
	closed.emit()


func _input(event: InputEvent) -> void:
	if (
		can_go_back
		and visible
		and event.is_action_pressed(&"ui_cancel")
	):
		close()
