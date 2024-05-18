class_name TutorialMenu extends Menu

const tutorial_seen_key := "tutorial_seen"


func _ready() -> void:
	if Save.get_data(self.tutorial_seen_key, false):
		self.close()
	else:
		self.open()


func close() -> void:
	Save.set_data(self.tutorial_seen_key, true)
	super.close()
