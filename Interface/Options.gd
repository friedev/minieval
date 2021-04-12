extends Control




func _on_ReturnToGame_pressed():
	var title_ui = get_node(@"/root/Control/TitleUI/Control")
	visible = false
	if Global.last_scene == "res://Interface/Title.tscn":
		title_ui.visible = true
