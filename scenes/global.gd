extends Node

signal is_menu_open_changed(is_menu_open: bool)
signal endless_changed(endless: bool)

# Default game parameters
const NUM_TURNS := 150
const GAME_SIZE := 64
const INITIAL_GP := 25

# Default options
const SPEED := 10.0
const MUSIC_VOLUME := 1.0
const SOUND_VOLUME := 1.0

var endless := false:
	set(value):
		if value != self.endless:
			endless = value
			self.endless_changed.emit(self.endless)

var num_turns := self.NUM_TURNS
var game_size := self.GAME_SIZE
var initial_gp := self.INITIAL_GP
var tutorial_seen := false

var is_menu_open := false:
	set(value):
		if value != self.is_menu_open:
			is_menu_open = value
			self.get_tree().paused = self.is_menu_open
			self.is_menu_open_changed.emit(self.is_menu_open)

# Options
var speed := self.SPEED
var music_volume := self.MUSIC_VOLUME
var sound_volume := self.SOUND_VOLUME


func reset_game_parameters() -> void:
	self.num_turns = self.NUM_TURNS
	self.game_size = self.GAME_SIZE


func change_scene_to_file(path: String) -> void:
	self.is_menu_open = false
	self.get_tree().paused = false
	self.get_tree().change_scene_to_file(path)
