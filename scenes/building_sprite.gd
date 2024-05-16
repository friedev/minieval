class_name BuildingSprite extends Sprite2D

var building: Building


func _ready() -> void:
	self.texture = self.building.type.texture
