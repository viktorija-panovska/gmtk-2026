class_name GraffitiSpot extends Area3D

var _is_in_area: bool
var _is_canvas_open: bool
var _player: Player

@onready var _canvas: GraffitiCanvas = %Canvas as GraffitiCanvas
@onready var _prompt: Control = %Prompt as Control
@onready var _wall: MeshInstance3D = %GraffitiWall as MeshInstance3D


func _ready() -> void:
	body_entered.connect(func(_body: Node3D) -> void: _toggle_canvas_prompt(true, _body))
	body_exited.connect(func(_body: Node3D) -> void: _toggle_canvas_prompt(false, _body))
	_wall.get_active_material(0).set_shader_parameter("use_stencil", Inventory.has_stencil())
	_wall.get_active_material(0).set_shader_parameter("stencil_tex", Inventory.get_available_stencil())


func _process(_delta: float) -> void:
	if _is_in_area and Input.is_action_just_pressed("Interact"):
		_toggle_canvas(not _is_canvas_open)


func _toggle_canvas_prompt(on: bool, body: Node3D) -> void:
	if not body is Player:
		return

	_player = body if on else null
	_is_in_area = on
	_prompt.visible = on


func _toggle_canvas(on: bool) -> void:
	if _player:
		_player.toggle_pause_input()

	_prompt.visible = not on

	_canvas.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED
	_canvas.visible = on
	_canvas.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
	_is_canvas_open = on

	if _is_canvas_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_canvas.set_current_cursor()
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func setup(phone: Phone) -> void:
	_canvas.setup(phone)


func get_drawing() -> Texture2D:
	return _canvas.get_drawing()
