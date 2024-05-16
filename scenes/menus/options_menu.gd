extends Menu


func close() -> void:
	Options.save_config()
	super.close()


func _on_save_button_pressed() -> void:
	self.close()


func _on_cancel_button_pressed() -> void:
	Options.load_config()
	self.close()
