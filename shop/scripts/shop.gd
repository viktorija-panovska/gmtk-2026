extends Node3D

@export var _stencil_price: int
@export var _color_prices: Dictionary[Color, int]

var _is_stencil_hovered: bool = false
var _hovered_color: Color = Inventory.INVALID_COLOR
var _hovered_spray_can: StaticBody3D
var _color_tweens: Dictionary[Color, Tween]
var _stencil_tween: Tween
var _no_money_tween: Tween

@onready var _stencil: Node3D = %Stencil as Node3D
@onready var _stencil_mesh: MeshInstance3D = %StencilMesh as MeshInstance3D
@onready var _stencil_price_label: Label = %StencilPrice as Control
@onready var _paints: Dictionary[Color, StaticBody3D] = {
	Color.RED: %RedPaintCan as Node3D,
	Color.BLUE: %BluePaintCan as Node3D 
}
@onready var _color_price_labels: Dictionary[Color, Label] = {
	Color.RED: %RedPrice as Label,
	Color.BLUE: %BluePrice as Label
}
@onready var _money_label: Label = %Money as Label


func _ready() -> void:
	Input.set_custom_mouse_cursor(null)
	
	var material: StandardMaterial3D = _stencil_mesh.get_surface_override_material(0)
	material.albedo_texture = GameManager.get_stencil()

	_stencil_price_label.text = "$%s" % _stencil_price
	for color in _color_price_labels:
		_color_price_labels[color].text = "$%s" % (_color_prices[color] if color in _color_prices else 0)
	_money_label.text = "BUDGET: $%s" % Inventory.get_money()

	_stencil.mouse_entered.connect(_hover_stencil)
	_stencil.mouse_exited.connect(_unhover_stencil)

	for color in _paints:
		_paints[color].mouse_entered.connect(func(): _hover_paint(_paints[color], color))
		_paints[color].mouse_exited.connect(_unhover_paint)


func _process(_delta: float) -> void:
	if not Input.is_action_just_pressed("Click"):
		return
	
	if _hovered_color != Inventory.INVALID_COLOR:
		_buy_paint()
	if _is_stencil_hovered:
		_buy_stencil()


func _hover_paint(spray_can: StaticBody3D, color: Color) -> void:
	_hovered_color = color
	_hovered_spray_can = spray_can
	
	if color in _color_tweens:
		_color_tweens[color].kill()
	
	_color_tweens[color] = create_tween()
	_color_tweens[color].tween_property(spray_can, "position:y", 0.1, 0.2)


func _unhover_paint() -> void:
	if not _hovered_spray_can:
		return

	if _hovered_color in _color_tweens:
		_color_tweens[_hovered_color].kill()
	
	_color_tweens[_hovered_color] = create_tween()
	_color_tweens[_hovered_color].tween_property(_hovered_spray_can, "position:y", 0, 0.2)

	_hovered_color = Inventory.INVALID_COLOR
	_hovered_spray_can = null


func _buy_paint() -> void:
	if _hovered_color in _color_prices and _color_prices[_hovered_color] > 0 and not _try_buy(_color_prices[_hovered_color]):
		return

	Inventory.gain_color(_hovered_color)
	_hovered_spray_can.process_mode = Node.PROCESS_MODE_DISABLED
	var color: Color = _hovered_color
	var can: Node3D = _hovered_spray_can
	_hovered_color = Inventory.INVALID_COLOR
	_hovered_spray_can = null
	
	if color in _color_tweens:
		_color_tweens[color].kill()
	var tween = create_tween()
	tween.tween_property(can, "scale", Vector3(0, 0, 0), 0.1)


func _hover_stencil() -> void:
	_is_stencil_hovered = true

	if _stencil_tween:
		_stencil_tween.kill()
	
	_stencil_tween = create_tween()
	_stencil_tween.tween_property(_stencil, "scale", Vector3(1.1, 1.1, 1.1), 0.1)


func _unhover_stencil() -> void:
	if not _is_stencil_hovered:
		return
	_is_stencil_hovered = false

	if _stencil_tween:
		_stencil_tween.kill()
	
	_stencil_tween = create_tween()
	_stencil_tween.tween_property(_stencil, "scale", Vector3(1, 1, 1), 0.1)


func _buy_stencil() -> void:
	if _stencil_price > 0 and not _try_buy(_stencil_price):
		return
	
	Inventory.gain_stencil(GameManager.get_stencil())
	_stencil.process_mode = Node.PROCESS_MODE_DISABLED
	_is_stencil_hovered = false
	
	if _stencil_tween:
		_stencil_tween.kill()
	
	_stencil_tween = create_tween()
	_stencil_tween.tween_property(_stencil, "scale", Vector3(0, 0, 0), 0.1)


func _try_buy(price: int) -> bool:
	if not Inventory.has_enough_money(price):
		if _no_money_tween:
			_no_money_tween.kill()
		_no_money_tween = create_tween().chain()
		_no_money_tween.tween_property(_money_label, "self_modulate", Color.RED, 0.1)
		_no_money_tween.tween_property(_money_label, "self_modulate", Color.WHITE, 0.1).set_delay(1)
		return false
	
	Inventory.spend_money(price)
	_money_label.text = "BUDGET: $%s" % Inventory.get_money()
	return true
