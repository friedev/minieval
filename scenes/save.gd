extends Node

## Save file path.
const SAVE_PATH := "user://save.cfg"
## Section of the save file under which all save data is saved.
const SAVE_SECTION := "save"

var save_file := ConfigFile.new()


func get_data(key: String, default: Variant) -> Variant:
	return self.save_file.get_value(self.SAVE_SECTION, key, default)


func set_data(key: String, value: Variant) -> void:
	self.save_file.set_value(self.SAVE_SECTION, key, value)
	self.save_file.save(self.SAVE_PATH)


func _ready() -> void:
	self.save_file.load(self.SAVE_PATH)
