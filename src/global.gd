extends Node

signal is_menu_open_changed(is_menu_open: bool)
signal endless_changed(endless: bool)

# Default game parameters
const NUM_TURNS := 150
const GAME_SIZE := 64
const INITIAL_GP := 25

var endless := false:
	set(value):
		if value != endless:
			endless = value
			endless_changed.emit(endless)

var num_turns := NUM_TURNS
var game_size := GAME_SIZE
var initial_gp := INITIAL_GP

var is_menu_open := false:
	set(value):
		if value != is_menu_open:
			is_menu_open = value
			get_tree().paused = is_menu_open
			is_menu_open_changed.emit(is_menu_open)

static var building_types := {
	&"road": preload("res://src/building_types/road.tres"),
	&"house": preload("res://src/building_types/house.tres"),
	&"mansion": preload("res://src/building_types/mansion.tres"),
	&"shop": preload("res://src/building_types/shop.tres"),
	&"statue": preload("res://src/building_types/statue.tres"),
	&"forge": preload("res://src/building_types/forge.tres"),
	&"cathedral": preload("res://src/building_types/cathedral.tres"),
	&"keep": preload("res://src/building_types/keep.tres"),
	&"tower": preload("res://src/building_types/tower.tres"),
	&"pyramid": preload("res://src/building_types/pyramid.tres"),
}


func reset_game_parameters() -> void:
	num_turns = NUM_TURNS
	game_size = GAME_SIZE


func change_scene_to_file(path: String) -> void:
	is_menu_open = false
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
