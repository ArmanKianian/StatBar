@tool
class_name StatBarRenderer
extends RefCounted


func draw(
	canvas: CanvasItem,
	bar_size: Vector2,
	fill_ratio: float,
	style: StatBarStyle,
	fill: StatBarFill
) -> void:
	var bar_rect := Rect2(Vector2.ZERO, bar_size)

	var background_color := Color(0.12, 0.12, 0.12)
	var fill_color := Color(0.85, 0.15, 0.15)

	if style != null:
		background_color = style.background_color
		fill_color = style.fill_color

	canvas.draw_rect(bar_rect, background_color)

	var fill_area := _get_fill_area(bar_rect, fill)
	var fill_rect := _get_fill_rect(fill_area, fill_ratio, fill)

	canvas.draw_rect(fill_rect, fill_color)

	if style != null and style.border_enabled and style.border_width > 0.0:
		canvas.draw_rect(
			bar_rect,
			style.border_color,
			false,
			style.border_width
		)


func _get_fill_area(
	bar_rect: Rect2,
	fill: StatBarFill
) -> Rect2:
	if fill == null:
		return bar_rect

	var fill_area := Rect2(
		bar_rect.position + Vector2(
			fill.padding_left,
			fill.padding_top
		),
		Vector2(
			bar_rect.size.x - fill.padding_left - fill.padding_right,
			bar_rect.size.y - fill.padding_top - fill.padding_bottom
		)
	)

	fill_area.size.x = maxf(fill_area.size.x, 0.0)
	fill_area.size.y = maxf(fill_area.size.y, 0.0)

	return fill_area


func _get_fill_rect(
	fill_area: Rect2,
	fill_ratio: float,
	fill: StatBarFill
) -> Rect2:
	var fill_rect := fill_area

	if fill == null:
		fill_rect.size.x = fill_area.size.x * fill_ratio
		return fill_rect

	match fill.direction:
		StatBarFill.Direction.LEFT_TO_RIGHT:
			fill_rect.size.x = fill_area.size.x * fill_ratio

		StatBarFill.Direction.RIGHT_TO_LEFT:
			fill_rect.position.x += fill_area.size.x * (1.0 - fill_ratio)
			fill_rect.size.x = fill_area.size.x * fill_ratio

		StatBarFill.Direction.TOP_TO_BOTTOM:
			fill_rect.size.y = fill_area.size.y * fill_ratio

		StatBarFill.Direction.BOTTOM_TO_TOP:
			fill_rect.position.y += fill_area.size.y * (1.0 - fill_ratio)
			fill_rect.size.y = fill_area.size.y * fill_ratio

	return fill_rect
