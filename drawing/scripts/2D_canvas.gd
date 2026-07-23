extends Control

const INVALID_COLOR: Color = Color(-1, -1, -1, 0)

@export var _drawable_texture: DrawableTexture2D
@export var _brush_texture: Texture2D
@export var _color: Color = Color.BLACK
@export var _size: int = 30
@export var _spray_can_texture: Texture2D

var _hovered_color: Color = INVALID_COLOR

@onready var _color_container: HBoxContainer = %ColorContainer as HBoxContainer


func _ready() -> void:
	_drawable_texture.setup(get_viewport().size.x, get_viewport().size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0,0,0,0))
	_fill_colors()


func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_color_hovered():
			_color = _hovered_color
			print(_color)
		else:
			_paint()


func _paint() -> void:
	var mouse_pos = get_global_mouse_position()
	_drawable_texture.blit_rect(Rect2i(mouse_pos.x, mouse_pos.y, _size, _size), _brush_texture, _color)


func _fill_colors() -> void:
	for color in Inventory.get_available_colors():
		var item = TextureRect.new()
		item.texture = _spray_can_texture
		item.modulate = color
		item.mouse_entered.connect(func(): _set_hovered_color(color))
		item.mouse_exited.connect(_clear_hovered_color)
		_color_container.add_child(item)


func _clear() -> void:
	for child in _color_container.get_children():
		_color_container.remove_child(child)


func _is_color_hovered() -> bool:
	return _hovered_color != INVALID_COLOR


func _set_hovered_color(color: Color) -> void:
	_hovered_color = color


func _clear_hovered_color() -> void:
	_hovered_color = INVALID_COLOR
