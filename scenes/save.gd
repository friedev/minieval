extends Node

## Save file path.
const SAVE_PATH := "user://save.cfg"
## Section of the save file under which all save data is saved.
const SAVE_SECTION := "save"

var save_file := ConfigFile.new()


func get_data(key: String, default: Variant) -> Variant:
	return save_file.get_value(SAVE_SECTION, key, default)


func set_data(key: String, value: Variant) -> void:
	save_file.set_value(SAVE_SECTION, key, value)
	save_file.save(SAVE_PATH)


func _ready() -> void:
	save_file.load(SAVE_PATH)
