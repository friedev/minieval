extends Node

# Default game parameters
const NUM_TURNS := 150
const GAME_SIZE := 64

# Default options
const SPEED := 10.0
const MUSIC_VOLUME := 5
const SOUND_VOLUME := 5

var endless := false
var num_turns := NUM_TURNS
var game_size := GAME_SIZE
var tutorial_seen := false

# Options
var speed := SPEED
var music_volume := MUSIC_VOLUME
var sound_volume := SOUND_VOLUME


func reset_game_parameters() -> void:
	num_turns = NUM_TURNS
	game_size = GAME_SIZE
