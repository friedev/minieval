extends Menu


func _ready() -> void:
	Options.setup()


func close() -> void:
	Options.save_config()
	super.close()


func _on_save_button_pressed() -> void:
	self.close()


func _on_cancel_button_pressed() -> void:
	Options.load_config()
	self.close()


func _on_restore_defaults_button_pressed() -> void:
	Options.apply_defaults()
