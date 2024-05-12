extends Label


func _ready() -> void:
	self.update_visibility(Global.endless)
	self.update_text(Global.num_turns)
	Global.endless_changed.connect(self._on_global_endless_changed)


func get_turns_left(turn: int) -> int:
	return Global.num_turns - turn


func update_visibility(endless: bool) -> void:
	self.visible = not endless


func update_text(turns_left: int) -> void:
	if turns_left == 1:
		self.text = "%d Turn Left" % turns_left
	else:
		self.text = "%d Turns Left" % turns_left


func _on_city_map_turn_changed(turn: int) -> void:
	self.update_text(self.get_turns_left(turn))


func _on_global_endless_changed(endless: bool) -> void:
	self.update_visibility(endless)
