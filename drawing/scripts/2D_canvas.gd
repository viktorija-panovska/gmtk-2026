extends Control

const INVALID_COLOR: Color = Color(-1, -1, -1, 0)

@export var _drawable_texture: DrawableTexture2D
@export var _brush_texture: Texture2D
@export var _color: Color = Color.BLACK
@export var _size: int = 30
@export var _default_spray_can_texture: Texture2D
@export var _spray_can_textures: Dictionary[Color, Texture2D]
@export var _cursor_textures: Dictionary[Color, Texture2D]

var _hovered_color: Color = INVALID_COLOR

@onready var _color_container: HBoxContainer = %ColorContainer as HBoxContainer
@onready var _reference: TextureRect = %Reference as TextureRect
@onready var _stencil: TextureRect = %Stencil as TextureRect


#region Built-in Methods

func _ready() -> void:
	_drawable_texture.setup(get_viewport().size.x, get_viewport().size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0,0,0,0))
	_reference.texture = Inventory.get_reference_image()
	_stencil.visible = Inventory.has_stencil()
	_stencil.texture = Inventory.get_available_stencil()
	_fill_colors()
	_set_active_color(Inventory.DEFAULT_COLOR)


func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_color_hovered():
			_set_active_color(_hovered_color)
		else:
			_paint()

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_finalize_painting()

#endregion


#region Painting

func _paint() -> void:
	var mouse_pos = get_global_mouse_position()
	_drawable_texture.blit_rect(Rect2i(mouse_pos.x, mouse_pos.y, _size, _size), _brush_texture, _color)


func _finalize_painting() -> Image:
	var drawing: Image = _drawable_texture.get_image()
	drawing.convert(Image.FORMAT_RGBA8)

	var final = Image.create_empty(drawing.get_size().x, drawing.get_size().y, false, Image.FORMAT_RGBA8)
	final.fill(Color.WHITE)
	final.blend_rect(drawing, Rect2(Vector2(0, 0), drawing.get_size()), Vector2(0, 0))

	if Inventory.has_stencil():
		var mask: Image = Inventory.get_available_stencil().get_image()
		mask.convert(Image.FORMAT_RGBA8)
		final.blend_rect(mask, Rect2(Vector2(0, 0), mask.get_size()), Vector2(0, 0))

	# TODO: Remove before shipping, for testing only (can't save pictures on web)
	final.save_png("graffiti.png")
	return final

#endregion


#region Color Selection


func _fill_colors() -> void:
	for color in Inventory.get_available_colors():
		var item = TextureRect.new()
		item.texture = _spray_can_textures[color] if color in _spray_can_textures.keys() else _default_spray_can_texture
		item.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		item.mouse_entered.connect(func(): _set_hovered_color(color))
		item.mouse_exited.connect(_clear_hovered_color)
		_color_container.add_child(item)


func _clear_colors() -> void:
	for child in _color_container.get_children():
		_color_container.remove_child(child)


func _is_color_hovered() -> bool:
	return _hovered_color != INVALID_COLOR


func _set_hovered_color(color: Color) -> void:
	Input.set_custom_mouse_cursor(null)
	_hovered_color = color


func _clear_hovered_color() -> void:
	Input.set_custom_mouse_cursor(_cursor_textures[_color])
	_hovered_color = INVALID_COLOR


func _set_active_color(color: Color) -> void:
	_color = color
	if color in _cursor_textures:
		Input.set_custom_mouse_cursor(_cursor_textures[_color])

#endregion

