extends Control


@onready var _reference_image: TextureRect = %Reference as TextureRect
@onready var _drawing: TextureRect = %Drawing as TextureRect
@onready var _matching_bar: ProgressBar = %MatchingBar as ProgressBar

@onready var _reward: Panel = %Reward as Panel
@onready var _reward_text: Label = %RewardText as Label
@onready var _back_button: Button = %Back as Button


func _ready() -> void:
    _reference_image.texture = GameManager.get_reference_image()
    _drawing.material.set_shader_parameter("use_stencil", Inventory.has_stencil())
    _drawing.material.set_shader_parameter("stencil_tex", Inventory.get_available_stencil())
    _back_button.pressed.connect(GameManager.end_mission)
    _back_button.visible = false
    _back_button.disabled = true


func show_scores(score: float, reward: int) -> void:
    _reward_text.text = "+$%s" % reward

    var bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).chain()
    bar_tween.tween_property(_matching_bar, "value", score, 5)
    await bar_tween.finished
    var reward_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).chain()
    reward_tween.tween_property(_reward, "offset_transform_position:y", 0, 1)
    reward_tween.tween_property(_reward, "offset_transform_position:y", -500, 2).set_delay(2)
    await reward_tween.finished

    _back_button.visible = true
    _back_button.disabled = false