class_name BuildingSprite extends Sprite2D

var building: Building


func _ready() -> void:
	self.texture = self.building.type.texture
	self.scale = Vector2.ZERO
	self.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ONE, 0.25)


func destroy() -> void:
	var tween := self.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(self, "scale", Vector2.ZERO, 0.25)
	await tween.finished
	self.queue_free()
