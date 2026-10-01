@tool
class_name StatBarRenderer
extends RefCounted


const CORNER_SEGMENTS := 12


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
		var fill_polygon := _create_fill_polygon(
			bar_rect,
			fill_rect,
			style
		)

		if fill_polygon.size() >= 3:
			canvas.draw_colored_polygon(
				PackedVector2Array(fill_polygon),
				fill_color
			)

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


func _create_fill_polygon(
	bar_rect: Rect2,
	fill_rect: Rect2,
	style: StatBarStyle
) -> Array[Vector2]:
	var rounded_polygon := _create_rounded_rect_polygon(
		bar_rect,
		style
	)

	return _clip_polygon_to_rect(
		rounded_polygon,
		fill_rect
	)


func _create_rounded_rect_polygon(
	rect: Rect2,
	style: StatBarStyle
) -> Array[Vector2]:
	var top_left := 0.0
	var top_right := 0.0
	var bottom_right := 0.0
	var bottom_left := 0.0

	if style != null and style.corners != null:
		if style.corners is StatBarCorner:
			var corner := style.corners as StatBarCorner
			var radius := _safe_radius(corner.radius)

			top_left = radius
			top_right = radius
			bottom_right = radius
			bottom_left = radius

		elif style.corners is StatBarCorners:
			var corners := style.corners as StatBarCorners

			top_left = _safe_radius(corners.top_left)
			top_right = _safe_radius(corners.top_right)
			bottom_right = _safe_radius(corners.bottom_right)
			bottom_left = _safe_radius(corners.bottom_left)

	var max_radius := minf(
		rect.size.x,
		rect.size.y
	) * 0.5

	top_left = minf(top_left, max_radius)
	top_right = minf(top_right, max_radius)
	bottom_right = minf(bottom_right, max_radius)
	bottom_left = minf(bottom_left, max_radius)

	var polygon: Array[Vector2] = []

	_add_corner(
		polygon,
		rect.position + Vector2(top_left, top_left),
		top_left,
		180.0,
		270.0
	)

	_add_corner(
		polygon,
		rect.position + Vector2(
			rect.size.x - top_right,
			top_right
		),
		top_right,
		270.0,
		360.0
	)

	_add_corner(
		polygon,
		rect.position + Vector2(
			rect.size.x - bottom_right,
			rect.size.y - bottom_right
		),
		bottom_right,
		0.0,
		90.0
	)

	_add_corner(
		polygon,
		rect.position + Vector2(
			bottom_left,
			rect.size.y - bottom_left
		),
		bottom_left,
		90.0,
		180.0
	)

	return polygon


func _add_corner(
	polygon: Array[Vector2],
	center: Vector2,
	radius: float,
	start_angle: float,
	end_angle: float
) -> void:
	if radius <= 0.0:
		polygon.append(center)
		return

	for index in range(CORNER_SEGMENTS + 1):
		var ratio := float(index) / float(CORNER_SEGMENTS)
		var angle := deg_to_rad(
			lerpf(start_angle, end_angle, ratio)
		)

		polygon.append(
			center + Vector2(
				cos(angle),
				sin(angle)
			) * radius
		)


func _clip_polygon_to_rect(
	polygon: Array[Vector2],
	clip_rect: Rect2
) -> Array[Vector2]:
	var result := polygon

	result = _clip_polygon_edge(
		result,
		clip_rect.position.x,
		0
	)

	result = _clip_polygon_edge(
		result,
		clip_rect.end.x,
		1
	)

	result = _clip_polygon_edge(
		result,
		clip_rect.position.y,
		2
	)

	result = _clip_polygon_edge(
		result,
		clip_rect.end.y,
		3
	)

	return result


func _clip_polygon_edge(
	polygon: Array[Vector2],
	edge: float,
	edge_type: int
) -> Array[Vector2]:
	if polygon.is_empty():
		return []

	var result: Array[Vector2] = []

	for index in range(polygon.size()):
		var current := polygon[index]
		var previous := polygon[
			(index - 1 + polygon.size()) % polygon.size()
		]

		var current_inside := _is_inside_edge(
			current,
			edge,
			edge_type
		)

		var previous_inside := _is_inside_edge(
			previous,
			edge,
			edge_type
		)

		if current_inside != previous_inside:
			result.append(
				_intersect_edge(
					previous,
					current,
					edge,
					edge_type
				)
			)

		if current_inside:
			result.append(current)

	return result


func _is_inside_edge(
	point: Vector2,
	edge: float,
	edge_type: int
) -> bool:
	match edge_type:
		0:
			return point.x >= edge

		1:
			return point.x <= edge

		2:
			return point.y >= edge

		3:
			return point.y <= edge

	return false


func _intersect_edge(
	start: Vector2,
	end: Vector2,
	edge: float,
	edge_type: int
) -> Vector2:
	var difference := end - start

	if edge_type == 0 or edge_type == 1:
		if is_zero_approx(difference.x):
			return start

		var ratio := (edge - start.x) / difference.x

		return Vector2(
			edge,
			start.y + difference.y * ratio
		)

	if is_zero_approx(difference.y):
		return start

	var ratio := (edge - start.y) / difference.y

	return Vector2(
		start.x + difference.x * ratio,
		edge
	)


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
