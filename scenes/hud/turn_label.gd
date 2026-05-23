extends Label

func _ready() -> void:
	update_visibility(Global.endless)
	update_text(Global.num_turns)
	Global.endless_changed.connect(_on_global_endless_changed)


func get_turns_left(turn: int) -> int:
	return Global.num_turns - turn


func update_visibility(endless: bool) -> void:
	visible = not endless


func update_text(turns_left: int) -> void:
	if turns_left == 1:
		text = "%d Turn Left" % turns_left
	else:
		text = "%d Turns Left" % turns_left


func _on_city_map_turn_changed(turn: int) -> void:
	update_text(get_turns_left(turn))


func _on_global_endless_changed(endless: bool) -> void:
	update_visibility(endless)
