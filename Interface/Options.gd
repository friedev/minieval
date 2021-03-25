extends Control






# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_ReturnToGame_pressed():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	get_tree().change_scene("res://Main.tscn")
