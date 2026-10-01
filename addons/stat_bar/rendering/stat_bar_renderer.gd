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

	canvas.draw_style_box(
		_create_style_box(background_color, style, bar_rect.size),
		bar_rect
	)

	var fill_area := _get_fill_area(bar_rect, fill)
	var fill_rect := _get_fill_rect(fill_area, fill_ratio, fill)

	if fill_rect.size.x > 0.0 and fill_rect.size.y > 0.0:
		var bar_polygon := _get_rounded_polygon(bar_rect, style)
		var fill_polygon := PackedVector2Array([
			fill_rect.position,
			Vector2(fill_rect.end.x, fill_rect.position.y),
			fill_rect.end,
			Vector2(fill_rect.position.x, fill_rect.end.y)
		])

		var intersected := Geometry2D.intersect_polygons(
			bar_polygon,
			fill_polygon
		)

		for polygon in intersected:
			if polygon.size() >= 3:
				canvas.draw_colored_polygon(
					polygon,
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
	var box := StyleBoxFlat.new()
	box.bg_color = color

	_apply_corners(box, style, box_size)

	return box


func _apply_corners(
	box: StyleBoxFlat,
	style: StatBarStyle,
	box_size: Vector2
) -> void:
	var top_left := 0.0
	var top_right := 0.0
	var bottom_right := 0.0
	var bottom_left := 0.0

	if style != null and style.corners != null:
		if style.corners is StatBarCorner:
			var corner := style.corners as StatBarCorner
			top_left = corner.radius
			top_right = corner.radius
			bottom_right = corner.radius
			bottom_left = corner.radius

		elif style.corners is StatBarCorners:
			var corners := style.corners as StatBarCorners
			top_left = corners.top_left
			top_right = corners.top_right
			bottom_right = corners.bottom_right
			bottom_left = corners.bottom_left

	var max_radius := minf(box_size.x, box_size.y) * 0.5

	box.corner_radius_top_left = int(minf(maxf(top_left, 0.0), max_radius))
	box.corner_radius_top_right = int(minf(maxf(top_right, 0.0), max_radius))
	box.corner_radius_bottom_right = int(minf(maxf(bottom_right, 0.0), max_radius))
	box.corner_radius_bottom_left = int(minf(maxf(bottom_left, 0.0), max_radius))


func _get_rounded_polygon(
	rect: Rect2,
	style: StatBarStyle
) -> PackedVector2Array:
	var radii := _get_radii(rect.size, style)
	var polygon := PackedVector2Array()

	_add_corner(
		polygon,
		rect.position + Vector2(radii.x, radii.x),
		radii.x,
		180.0
	)
	_add_corner(
		polygon,
		rect.position + Vector2(rect.size.x - radii.y, radii.y),
		radii.y,
		270.0
	)
	_add_corner(
		polygon,
		rect.position + Vector2(rect.size.x - radii.z, rect.size.y - radii.z),
		radii.z,
		0.0
	)
	_add_corner(
		polygon,
		rect.position + Vector2(radii.w, rect.size.y - radii.w),
		radii.w,
		90.0
	)

	return polygon


func _get_radii(
	box_size: Vector2,
	style: StatBarStyle
) -> Vector4:
	var radii := Vector4.ZERO

	if style != null and style.corners != null:
		if style.corners is StatBarCorner:
			var corner := style.corners as StatBarCorner
			radii = Vector4(
				corner.radius,
				corner.radius,
				corner.radius,
				corner.radius
			)

		elif style.corners is StatBarCorners:
			var corners := style.corners as StatBarCorners
			radii = Vector4(
				corners.top_left,
				corners.top_right,
				corners.bottom_right,
				corners.bottom_left
			)

	var max_radius := minf(box_size.x, box_size.y) * 0.5

	return Vector4(
		minf(maxf(radii.x, 0.0), max_radius),
		minf(maxf(radii.y, 0.0), max_radius),
		minf(maxf(radii.z, 0.0), max_radius),
		minf(maxf(radii.w, 0.0), max_radius)
	)


func _add_corner(
	polygon: PackedVector2Array,
	center: Vector2,
	radius: float,
	start_angle: float
) -> void:
	if radius <= 0.0:
		polygon.append(center)
		return

	for index in range(CORNER_SEGMENTS + 1):
		var angle := deg_to_rad(
			start_angle + 90.0 * float(index) / CORNER_SEGMENTS
		)

		polygon.append(
			center + Vector2(cos(angle), sin(angle)) * radius
		)


func _get_fill_area(
	bar_rect: Rect2,
	fill: StatBarFill
) -> Rect2:
	if fill == null:
		return bar_rect

	var area := Rect2(
		bar_rect.position + Vector2(
			fill.padding_left,
			fill.padding_top
		),
		Vector2(
			bar_rect.size.x - fill.padding_left - fill.padding_right,
			bar_rect.size.y - fill.padding_top - fill.padding_bottom
		)
	)

	area.size.x = maxf(area.size.x, 0.0)
	area.size.y = maxf(area.size.y, 0.0)

	return area


func _get_fill_rect(
	fill_area: Rect2,
	fill_ratio: float,
	fill: StatBarFill
) -> Rect2:
	var rect := fill_area

	if fill == null:
		rect.size.x *= fill_ratio
		return rect

	match fill.direction:
		StatBarFill.Direction.LEFT_TO_RIGHT:
			rect.size.x *= fill_ratio

		StatBarFill.Direction.RIGHT_TO_LEFT:
			rect.position.x += rect.size.x * (1.0 - fill_ratio)
			rect.size.x *= fill_ratio

		StatBarFill.Direction.TOP_TO_BOTTOM:
			rect.size.y *= fill_ratio

		StatBarFill.Direction.BOTTOM_TO_TOP:
			rect.position.y += rect.size.y * (1.0 - fill_ratio)
			rect.size.y *= fill_ratio

	return rect
