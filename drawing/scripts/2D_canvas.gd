extends Control

@export var _drawable_texture: DrawableTexture2D
@export var _brush: Texture2D
@export var _color: Color = Color.BLACK
@export var _size: int = 30


func _ready() -> void:
	_drawable_texture.setup(get_viewport().size.x, get_viewport().size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0,0,0,0))


func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()
		_drawable_texture.blit_rect(Rect2i(mouse_pos.x, mouse_pos.y, _size, _size), _brush, _color)
