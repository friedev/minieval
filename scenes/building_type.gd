class_name BuildingType extends Resource

@export var display_name: String
@export var key: StringName
@export var gp: int
@export var vp: int
@export var icon: Texture2D
@export var texture: Texture2D
## The coords by which the building preview is offset relative to the cursor
## coords.
@export var offset: Vector2i
## The area in which the building interacts with other buildings. NOT the area
## occupied by the building's cells.
@export var area: Rect2i
@export var cells: Array[Vector2i]
@export var gp_interactions: Dictionary # Dictionary[StringName, int]
@export var vp_interactions: Dictionary # Dictionary[StringName, int]

@export_group("Tile Settings")
@export var is_tile: bool
@export var terrain_set := -1
@export var terrain := -1

## Bounding box of the building's cells.
var bounds: Rect2i:
	get:
		if bounds.size == Vector2i.ZERO:
			for coords in self.cells:
				bounds = bounds.expand(coords)
		return bounds


# Returns a list of all cell vectors orthogonally adjacent to the given cell
# Duplicated from outer scope
static func get_orthogonal(coords: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(coords.x - 1, coords.y),
		Vector2i(coords.x + 1, coords.y),
		Vector2i(coords.x, coords.y - 1),
		Vector2i(coords.x, coords.y + 1),
	]


func get_cells(offset := Vector2i(0, 0)) -> Array[Vector2i]:
	var offset_cells: Array[Vector2i] = []
	for coords in self.cells:
		offset_cells.append(coords + offset)
	return offset_cells


func get_area_cells(offset := Vector2i(0, 0)) -> Array[Vector2i]:
	var area_cells: Array[Vector2i] = []
	for x in range(self.area.size.x):
		for y in range(self.area.size.y):
			area_cells.append(Vector2i(x, y) + self.area.position + offset)
	return area_cells


func get_adjacent_cells(offset := Vector2i(0, 0)) -> Array[Vector2i]:
	var adjacent_cells: Array[Vector2i] = []
	for coords in self.cells:
		for orthogonal_coords in self.get_orthogonal(coords):
			if not orthogonal_coords in self.cells and not orthogonal_coords + offset in adjacent_cells:
				adjacent_cells.append(orthogonal_coords + offset)
	return adjacent_cells
