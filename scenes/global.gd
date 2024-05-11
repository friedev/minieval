extends Node

# Default game parameters
const NUM_TURNS := 150
const GAME_SIZE := 64
const INITIAL_GP := 25

# Default options
const SPEED := 10.0
const MUSIC_VOLUME := 5
const SOUND_VOLUME := 5

var endless := false
var num_turns := Global.NUM_TURNS
var game_size := Global.GAME_SIZE
var initial_gp := Global.INITIAL_GP
var tutorial_seen := false

# Options
var speed := Global.SPEED
var music_volume := Global.MUSIC_VOLUME
var sound_volume := Global.SOUND_VOLUME


func reset_game_parameters() -> void:
	Global.num_turns = Global.NUM_TURNS
	Global.game_size = Global.GAME_SIZE
