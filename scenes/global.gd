extends Node

signal is_menu_open_changed(is_menu_open: bool)

# Default game parameters
const NUM_TURNS := 150
const GAME_SIZE := 64
const INITIAL_GP := 25

# Default options
const SPEED := 10.0
const MUSIC_VOLUME := 1.0
const SOUND_VOLUME := 1.0

var endless := false
var num_turns := Global.NUM_TURNS
var game_size := Global.GAME_SIZE
var initial_gp := Global.INITIAL_GP
var tutorial_seen := false
var is_menu_open := false:
	set(value):
		if value != Global.is_menu_open:
			is_menu_open = value
			self.get_tree().paused = Global.is_menu_open
			Global.is_menu_open_changed.emit(Global.is_menu_open)

# Options
var speed := Global.SPEED
var music_volume := Global.MUSIC_VOLUME
var sound_volume := Global.SOUND_VOLUME


func reset_game_parameters() -> void:
	Global.num_turns = Global.NUM_TURNS
	Global.game_size = Global.GAME_SIZE


func change_scene_to_file(path: String) -> void:
	Global.is_menu_open = false
	self.get_tree().paused = false
	self.get_tree().change_scene_to_file(path)
