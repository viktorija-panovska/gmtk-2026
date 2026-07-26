extends Area3D

var _is_in_area: bool
var _is_canvas_open: bool
var _has_canvas_been_opened: bool

@onready var _canvas: GraffitiCanvas = %Canvas as GraffitiCanvas
@onready var _prompt: Control = %Prompt as Control
@onready var _wall: MeshInstance3D = %GraffitiWall as MeshInstance3D


func _ready() -> void:
    body_entered.connect(func(_body: Node3D) -> void: _toggle_canvas_prompt(true))
    body_exited.connect(func(_body: Node3D) -> void: _toggle_canvas_prompt(false))
    _wall.get_active_material(0).set_shader_parameter("use_stencil", Inventory.has_stencil())
    _wall.get_active_material(0).set_shader_parameter("stencil_tex", Inventory.get_available_stencil())


func _process(_delta: float) -> void:
    if _is_in_area and Input.is_action_just_pressed("Interact"):
        _toggle_canvas(not _is_canvas_open)


func _toggle_canvas_prompt(on: bool) -> void:
    _is_in_area = on
    _prompt.visible = on


func _toggle_canvas(on: bool) -> void:
    _prompt.visible = not on

    if not _has_canvas_been_opened:
        _canvas.setup()
        _has_canvas_been_opened = true

    _canvas.process_mode = Node.PROCESS_MODE_INHERIT if on else Node.PROCESS_MODE_DISABLED
    _canvas.visible = on
    _canvas.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
    _is_canvas_open = on

    if _is_canvas_open:
        _canvas.set_current_cursor()
        return

    Input.set_custom_mouse_cursor(null)


func get_drawing() -> Texture2D:
    return _canvas.get_drawing()