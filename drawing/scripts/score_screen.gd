extends Control

var _tween: Tween

@onready var _reference_image: TextureRect = %Reference as TextureRect
@onready var _drawing: TextureRect = %Drawing as TextureRect
@onready var _matching_bar: ProgressBar = %MatchingBar as ProgressBar

@onready var _phone: Panel = %Phone as Panel
@onready var _reward: Label = %Reward as Label
@onready var _back_button: Button = %Back as Button


func _ready() -> void:
	_reference_image.texture = GameManager.get_reference_image()
	_drawing.material.set_shader_parameter("use_stencil", Inventory.has_stencil())
	_drawing.material.set_shader_parameter("stencil_tex", Inventory.get_available_stencil())
	_back_button.mouse_entered.connect(func(): _hover_button(true))
	_back_button.mouse_exited.connect(func(): _hover_button(false))
	_back_button.pressed.connect(GameManager.end_mission)
	_back_button.visible = false
	_back_button.disabled = true


func show_scores(score: float, reward: int) -> void:
	_reward.text = "+$%s" % reward

	var bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).chain()
	bar_tween.tween_property(_matching_bar, "value", score, 5)
	await bar_tween.finished
	var reward_tween = create_tween().chain()
	reward_tween.tween_property(_phone, "offset_transform_position:y", 0, 0.2)
	reward_tween.tween_property(_phone, "offset_transform_position:y", 400, 0.5).set_delay(2)
	await reward_tween.finished

	_back_button.visible = true
	_back_button.disabled = false


func _hover_button(is_hovering: bool) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_back_button, "scale", Vector2(1.2, 1.2) if is_hovering else Vector2(1, 1), 0.1)
