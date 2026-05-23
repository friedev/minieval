extends Label

func _on_city_map_gp_changed(gp: int) -> void:
	text = str(gp)
