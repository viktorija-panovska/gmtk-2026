extends VisualInstance3D

@export var drawable_texture: DrawableTexture2D
@export var texture_size: Vector2i = Vector2i(512, 512)

var _mouse_position: Vector2
var _is_drawing: bool


func _ready() -> void:
	drawable_texture.setup(texture_size.x, texture_size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.AQUA)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_is_drawing = event.is_pressed()
	if event is InputEventMouseMotion:
		_mouse_position = event.global_position
		print(_mouse_position)


func _process(_delta: float) -> void:
	if _is_drawing:
		var texture_pos = Vector2(_mouse_position.x + texture_size.x / 2.0, _mouse_position.y + texture_size.y / 2.0)
		print(texture_pos)
		var source = Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
		drawable_texture.blit_rect(Rect2i(_mouse_position.x, _mouse_position.y, 1, 1), source, Color.ORANGE)
