@tool
class_name StatBarStyle
extends Resource

@export_category("Background")

@export var background_color: Color = Color(0.12, 0.12, 0.12)


@export_category("Fill")

@export var fill_color: Color = Color(0.85, 0.15, 0.15)


@export_category("Border")

@export var border_enabled: bool = false
@export_range(0.0, 32.0, 1.0) var border_width: float = 1.0
@export var border_color: Color = Color.WHITE
