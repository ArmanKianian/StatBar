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

	var background_box := _create_style_box(
		background_color,
		style,
		bar_rect.size
	)

	canvas.draw_style_box(background_box, bar_rect)

	var fill_area := _get_fill_area(bar_rect, fill)
	var fill_rect := _get_fill_rect(fill_area, fill_ratio, fill)

	if fill_rect.size.x > 0.0 and fill_rect.size.y > 0.0:
		var fill_box := _create_style_box(
			fill_color,
			style,
			fill_rect.size
		)

		canvas.draw_style_box(fill_box, fill_rect)

	if style != null and style.border_enabled and style.border_width > 0.0:
		var border_box := _create_style_box(
			Color.TRANSPARENT,
			style,
			bar_rect.size
		)

		border_box.border_width_left = int(style.border_width)
		border_box.border_width_top = int(style.border_width)
		border_box.border_width_right = int(style.border_width)
		border_box.border_width_bottom = int(style.border_width)
		border_box.border_color = style.border_color

		canvas.draw_style_box(border_box, bar_rect)


func _create_style_box(
	color: Color,
	style: StatBarStyle,
	box_size: Vector2
) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color

	if style == null or style.corners == null:
		return style_box

	if style.corners is StatBarCorner:
		var corner := style.corners as StatBarCorner
		var radius := _safe_radius(corner.radius)

		_apply_corners(
			style_box,
			radius,
			radius,
			radius,
			radius,
			box_size
		)

	elif style.corners is StatBarCorners:
		var corners := style.corners as StatBarCorners

		_apply_corners(
			style_box,
			_safe_radius(corners.top_left),
			_safe_radius(corners.top_right),
			_safe_radius(corners.bottom_right),
			_safe_radius(corners.bottom_left),
			box_size
		)

	return style_box


func _apply_corners(
	style_box: StyleBoxFlat,
	top_left: float,
	top_right: float,
	bottom_right: float,
	bottom_left: float,
	box_size: Vector2
) -> void:
	var max_radius := minf(
		box_size.x,
		box_size.y
	) * 0.5

	top_left = minf(top_left, max_radius)
	top_right = minf(top_right, max_radius)
	bottom_right = minf(bottom_right, max_radius)
	bottom_left = minf(bottom_left, max_radius)

	style_box.corner_radius_top_left = int(top_left)
	style_box.corner_radius_top_right = int(top_right)
	style_box.corner_radius_bottom_right = int(bottom_right)
	style_box.corner_radius_bottom_left = int(bottom_left)


func _safe_radius(radius) -> float:
	if radius == null:
		return 0.0

	return maxf(float(radius), 0.0)


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
