extends Node

# Default game parameters
const GAME_MODE = 0
const NUM_TURNS = 100
const GAME_SIZE = 64
const GAME_TIME = 300

# Default options
const SPEED = 10.0
const MUSIC_VOLUME = 5
const SFX_VOLUME = 5

# Game parameters
# 0 - turn, 1 - time, 2 - freeplay, 3 - creative
var game_mode = GAME_MODE
var num_turns = NUM_TURNS
var game_size = GAME_SIZE
var game_time = GAME_TIME
var timer_over = false
var last_scene = ""
var tutorial_seen = false

# Options
var speed = SPEED
var music_volume = MUSIC_VOLUME
var sfx_volume = SFX_VOLUME

func reset_game_parameters():
	game_mode = GAME_MODE
	num_turns = NUM_TURNS
	game_size = GAME_SIZE
	game_time = GAME_TIME
