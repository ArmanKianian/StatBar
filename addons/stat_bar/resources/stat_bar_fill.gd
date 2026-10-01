@tool
class_name StatBarFill
extends Resource

enum Direction {
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT,
	TOP_TO_BOTTOM,
	BOTTOM_TO_TOP
}

@export_category("Direction")

@export var direction: Direction = Direction.LEFT_TO_RIGHT


@export_category("Padding")

@export_range(0.0, 100.0, 1.0) var padding_left: float = 0.0
@export_range(0.0, 100.0, 1.0) var padding_top: float = 0.0
@export_range(0.0, 100.0, 1.0) var padding_right: float = 0.0
@export_range(0.0, 100.0, 1.0) var padding_bottom: float = 0.0
