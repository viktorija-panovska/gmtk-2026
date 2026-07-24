extends Node

var _start_button_tween: Tween
var _quit_button_tween: Tween

@onready var _start_button: Button = %StartButton as Button
@onready var _quit_button: Button = %QuitButton as Button


func _ready() -> void:
    _start_button.mouse_entered.connect(func(): _hover_button(_start_button, _start_button_tween, true))
    _start_button.mouse_exited.connect(func(): _hover_button(_start_button, _start_button_tween, false))
    _start_button.pressed.connect(_start_game)

    _quit_button.mouse_entered.connect(func(): _hover_button(_quit_button, _quit_button_tween, true))
    _quit_button.mouse_exited.connect(func(): _hover_button(_quit_button, _quit_button_tween, false))
    _quit_button.pressed.connect(_quit_game)


func _start_game() -> void:
    SceneLoader.load_scene(Constants.SCENE_UID_MISSION_SELECT)


func _quit_game() -> void:
    get_tree().quit()


func _hover_button(button: Button, tween: Tween, is_hovering: bool) -> void:
    if tween:
        tween.kill()
    tween = create_tween()
    tween.tween_property(button, "scale", Vector2(1.2, 1.2) if is_hovering else Vector2(1, 1), 0.1)