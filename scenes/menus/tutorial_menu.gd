class_name TutorialMenu extends Menu


func _ready() -> void:
	if Global.tutorial_seen:
		self.close()
	else:
		self.open()


func close() -> void:
	Global.tutorial_seen = true
	super.close()
