extends Control


func _ready() -> void:
	Global.is_menu_open_changed.connect(self._on_global_is_menu_open_changed)


func _on_global_is_menu_open_changed(is_menu_open: bool) -> void:
	self.visible = is_menu_open
