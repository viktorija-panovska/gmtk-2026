extends Control

@export var _drawable_texture: DrawableTexture2D
@export var _brush_texture: Texture2D
@export var _color: Color = Color.BLACK
@export var _size: int = 30
@export var _default_spray_can_texture: Texture2D
@export var _spray_can_textures: Dictionary[Color, Texture2D]
@export var _cursor_textures: Dictionary[Color, Texture2D]

var _hovered_color: Color = Inventory.INVALID_COLOR
var _hovered_spray_can: Control
var _spray_can_tweens: Dictionary[Color, Tween]

@onready var _color_container: HBoxContainer = %ColorContainer as HBoxContainer
@onready var _stencil: TextureRect = %Stencil as TextureRect
@onready var _phone: Phone = %Phone as Phone


#region Built-in Methods

func _ready() -> void:
	_drawable_texture.setup(get_viewport().size.x, get_viewport().size.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0,0,0,0))
	_stencil.visible = Inventory.has_stencil()
	_stencil.texture = Inventory.get_available_stencil()
	_fill_colors()
	_set_active_color(Inventory.DEFAULT_COLOR)


func _process(_delta: float) -> void:
	if _phone.is_full_view():
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _hovered_color != Inventory.INVALID_COLOR:
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

	return final

#endregion


#region Color Selection

func _fill_colors() -> void:
	for color in Inventory.get_available_colors():
		var item = TextureRect.new()
		item.texture = _spray_can_textures[color] if color in _spray_can_textures else _default_spray_can_texture
		item.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		item.mouse_entered.connect(func(): _set_hovered_color(color, item))
		item.mouse_exited.connect(_clear_hovered_color)
		_color_container.add_child(item)


func _clear_colors() -> void:
	for child in _color_container.get_children():
		_color_container.remove_child(child)


func _set_hovered_color(color: Color, spray_can: Control) -> void:
	Input.set_custom_mouse_cursor(null)
	_hovered_color = color
	_hovered_spray_can = spray_can

	if color in _spray_can_tweens:
		_spray_can_tweens[color].kill()
	
	_spray_can_tweens[color] = create_tween()
	_spray_can_tweens[color].tween_property(spray_can, "position:y", -30, 0.2)


func _clear_hovered_color() -> void:
	Input.set_custom_mouse_cursor(_cursor_textures[_color])

	if _hovered_color in _spray_can_tweens:
		_spray_can_tweens[_hovered_color].kill()
	
	_spray_can_tweens[_hovered_color] = create_tween()
	_spray_can_tweens[_hovered_color].tween_property(_hovered_spray_can, "position:y", 0, 0.2)

	_hovered_color = Inventory.INVALID_COLOR
	_hovered_spray_can = null


func _set_active_color(color: Color) -> void:
	_color = color
	if color in _cursor_textures:
		Input.set_custom_mouse_cursor(_cursor_textures[_color])
		_phone.set_scene_cursor(_cursor_textures[color])

#endregion
