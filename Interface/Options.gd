extends Control



func _on_ReturnToGame_pressed():
	var title_ui = get_node(@"/root/Control/TitleUI/Control")
	visible = false
	if Global.last_scene == "res://Interface/Title.tscn":
		title_ui.visible = true


func _on_CameraSpeed_value_changed(value):
	var slider = get_node("CameraSpeed")
	var value_text = get_node("CameraSpeedValue")
	Global.speed = slider.value
	value_text.text = str(slider.value)


func _on_Options_ready():
	var camera = get_node("CameraSpeedValue")
	var volume = get_node("VolumeValue")
	camera.text = str(Global.speed)
	volume.text = str(Global.speed)

func _on_GameVolume_value_changed(value):
	var slider = get_node("GameVolume")
	var value_text = get_node("VolumeValue")
	Global.volume = slider.value
	value_text.text = str(slider.value)
