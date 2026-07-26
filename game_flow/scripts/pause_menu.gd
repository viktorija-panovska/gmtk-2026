extends Control

@export var _level_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

var _resume_button_tween: Tween
var _quit_button_tween: Tween

@onready var _resume_button: Button = %ResumeButton as Button
@onready var _quit_button: Button = %QuitButton as Button


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_resume_button.mouse_entered.connect(func(): _hover_button(_resume_button, _resume_button_tween, true))
	_resume_button.mouse_exited.connect(func(): _hover_button(_resume_button, _resume_button_tween, false))
	_resume_button.pressed.connect(toggle_menu)

	_quit_button.mouse_entered.connect(func(): _hover_button(_quit_button, _quit_button_tween, true))
	_quit_button.mouse_exited.connect(func(): _hover_button(_quit_button, _quit_button_tween, false))
	_quit_button.pressed.connect(func(): get_tree().quit())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()


func toggle_menu() -> void:
	visible = !visible
	mouse_filter = Control.MOUSE_FILTER_STOP if visible else Control.MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else _level_mouse_mode)


func _hover_button(button: Button, tween: Tween, is_hovering: bool) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.2, 1.2) if is_hovering else Vector2(1, 1), 0.1)
