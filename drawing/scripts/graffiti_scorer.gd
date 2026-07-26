class_name GraffitiScorer extends Node

const GROUPS_ONE_SIDE: int = 8
const GROUPS_TOTAL: int = GROUPS_ONE_SIDE * GROUPS_ONE_SIDE
const MAX_SCORE_PER_GROUP: int = 10


class PixelCounts:
	var black: Array[int]
	var red: Array[int]
	var green: Array[int]
	var blue: Array[int]

	func _init() -> void:
		black.resize(GROUPS_TOTAL)
		black.fill(0.0)
		red.resize(GROUPS_TOTAL)
		red.fill(0.0)
		blue.resize(GROUPS_TOTAL)
		blue.fill(0.0)
		green.resize(GROUPS_TOTAL)
		green.fill(0.0)

	func get_total_for_group(group: int) -> int:
		return black[group] + red[group] + green[group] + blue[group]


@export var _drawing: DrawableTexture2D
@export var _scoring_curve: Curve

var _max_reference_score_per_group: float


func compute_score() -> float:
	var drawing_img = _drawing.get_image()
	drawing_img.resize(64, 64, Image.Interpolation.INTERPOLATE_NEAREST)
	drawing_img.convert(Image.FORMAT_RGBA8)

	var reference_img: Image = load("uid://ddg745x2g6ci7").get_image()#GameManager.get_reference_image().get_image()
	reference_img.resize(64, 64, Image.Interpolation.INTERPOLATE_NEAREST)
	reference_img.convert(Image.FORMAT_RGBA8)

	var mask: Image
	if Inventory.has_stencil():
		mask = Inventory.get_available_stencil().get_image()
		mask.resize(64, 64, Image.Interpolation.INTERPOLATE_NEAREST)
		mask.convert(Image.FORMAT_RGBA8)

	var counts: Array[PixelCounts] = _count_pixels(drawing_img, reference_img, mask)
	var group_score: float = _compute_raw_score(counts[0], counts[1])

	print(group_score / (GROUPS_TOTAL * MAX_SCORE_PER_GROUP * 4) * 100)
	return 0


func compute_reward(score: float, max_reward: int) -> int:
	if score >= 50:
		return max_reward
	return roundi(max_reward / 2)


func _count_pixels(drawing_img: Image, reference_img: Image, mask_img: Image) -> Array[PixelCounts]:
	var reference_counts: PixelCounts = PixelCounts.new()
	var drawing_counts: PixelCounts = PixelCounts.new()

	var pixels_per_group: Vector2i = Vector2i(int(drawing_img.get_width() / GROUPS_ONE_SIDE), int(drawing_img.get_height() / GROUPS_ONE_SIDE))
	_max_reference_score_per_group = pixels_per_group.x * pixels_per_group.y

	for x in range(drawing_img.get_width()):
		for y in range(drawing_img.get_height()):
			var drawing_pixel: Color = drawing_img.get_pixel(y, x)
			if Inventory.has_stencil() and mask_img.get_pixel(y, x) == Color.WHITE:
				continue
			var index: int = int(y / pixels_per_group.y) * GROUPS_ONE_SIDE + int(x / pixels_per_group.x)
			var reference_pixel: Color = reference_img.get_pixel(y, x)
			_count_pixel_color(drawing_pixel, index, drawing_counts)
			_count_pixel_color(reference_pixel, index, reference_counts)
	
	return [reference_counts, drawing_counts]


func _compute_raw_score(reference_counts: PixelCounts, drawing_counts: PixelCounts) -> float:
	var score: float = 0

	print(" ref: ", reference_counts.black, " draw: ", drawing_counts.black)
	for i in range(GROUPS_TOTAL):
		var black: float = _compute_one_dimensional_score(reference_counts.black[i], drawing_counts.black[i])
		var red: float = _compute_one_dimensional_score(reference_counts.red[i], drawing_counts.red[i])
		var green: float = _compute_one_dimensional_score(reference_counts.green[i], drawing_counts.green[i])
		var blue: float = _compute_one_dimensional_score(reference_counts.blue[i], drawing_counts.blue[i])
		var group_score = black + red + green + blue
		score += group_score

	return score


func _compute_one_dimensional_score(reference_counts: int, drawing_counts: int) -> float:
	if reference_counts == drawing_counts:
		return MAX_SCORE_PER_GROUP

	print(_max_reference_score_per_group)
	print("---")
	print(drawing_counts)
	print(reference_counts)
	print(abs(drawing_counts - reference_counts) / _max_reference_score_per_group)
	print(_scoring_curve.sample(abs(drawing_counts - reference_counts) / _max_reference_score_per_group))
	return _scoring_curve.sample(abs(drawing_counts - reference_counts) / _max_reference_score_per_group) * MAX_SCORE_PER_GROUP


func _count_pixel_color(pixel: Color, index: int, scores: PixelCounts) -> void:
	if pixel.a == 0: return

	if _is_pixel_black(pixel):
		scores.black[index] += 1
		return
	
	if _is_pixel_red(pixel):
		scores.red[index] += 1
	if _is_pixel_green(pixel):
		scores.green[index] += 1
	if _is_pixel_blue(pixel):
		scores.blue[index] += 1


func _is_pixel_black(pixel: Color) -> bool:
	return max(pixel.r, pixel.g, pixel.b) < 0.3


func _is_pixel_red(pixel: Color) -> bool:
	return max(pixel.r, pixel.g, pixel.b) == pixel.r


func _is_pixel_blue(pixel: Color) -> bool:
	return max(pixel.r, pixel.g, pixel.b) == pixel.b


func _is_pixel_green(pixel: Color) -> bool:
	return max(pixel.r, pixel.g, pixel.b) == pixel.g
