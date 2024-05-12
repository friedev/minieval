extends Label


func _on_city_map_vp_changed(vp: int) -> void:
	self.text = str(vp)
