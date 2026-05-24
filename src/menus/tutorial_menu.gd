class_name TutorialMenu
extends Menu

const tutorial_seen_key := "tutorial_seen"


func _ready() -> void:
	if Save.get_data(tutorial_seen_key, false):
		close()
	else:
		open()


func close() -> void:
	Save.set_data(tutorial_seen_key, true)
	super.close()
