@tool
@icon("res://addons/stat_bar/StatBar.png")
class_name StatBar
extends Control

const STAT_BAR_RENDERER := preload("res://addons/stat_bar/rendering/stat_bar_renderer.gd")

signal value_changed(value: float)
signal max_value_changed(max_value: float)
signal value_full()
signal value_depleted()

var renderer: StatBarRenderer


#region Value

@export_category("Value")

@export var value: float = 100.0:
	set(new_value):
		var clamped_value := clampf(new_value, 0.0, max_value)

		if value == clamped_value:
			return

		var previous_value := value
		value = clamped_value

		value_changed.emit(value)

		if value <= 0.0 and previous_value > 0.0:
			value_depleted.emit()

		if value >= max_value and previous_value < max_value:
			value_full.emit()

		queue_redraw()


@export var max_value: float = 100.0:
	set(new_max_value):
		var clamped_max_value := maxf(new_max_value, 0.0)

		if max_value == clamped_max_value:
			return

		max_value = clamped_max_value
		value = minf(value, max_value)

		max_value_changed.emit(max_value)
		queue_redraw()

#endregion


#region Appearance

@export_category("Appearance")

@export var style: StatBarStyle:
	set(new_style):
		if style == new_style:
			return

		if style != null and style.changed.is_connected(_on_style_changed):
			style.changed.disconnect(_on_style_changed)

		style = new_style

		if style != null:
			style.changed.connect(_on_style_changed)

		queue_redraw()

#endregion


#region Fill

@export_category("Fill")

@export var fill: StatBarFill:
	set(new_fill):
		if fill == new_fill:
			return

		if fill != null and fill.changed.is_connected(_on_fill_changed):
			fill.changed.disconnect(_on_fill_changed)

		fill = new_fill

		if fill != null:
			fill.changed.connect(_on_fill_changed)

		queue_redraw()

#endregion


func _ready() -> void:
	renderer = STAT_BAR_RENDERER.new()

	if style != null and not style.changed.is_connected(_on_style_changed):
		style.changed.connect(_on_style_changed)

	if fill != null and not fill.changed.is_connected(_on_fill_changed):
		fill.changed.connect(_on_fill_changed)

	set_process(Engine.is_editor_hint())
	queue_redraw()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _on_style_changed() -> void:
	queue_redraw()


func _on_fill_changed() -> void:
	queue_redraw()


func get_percentage() -> float:
	if max_value <= 0.0:
		return 0.0

	return value / max_value


func _draw() -> void:
	if renderer == null:
		renderer = STAT_BAR_RENDERER.new()

	renderer.draw(
		self,
		size,
		get_percentage(),
		style,
		fill
	)
