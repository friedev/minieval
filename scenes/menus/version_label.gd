extends Label


func _ready() -> void:
	self.text = "v%s" % ProjectSettings.get_setting("application/config/version")
