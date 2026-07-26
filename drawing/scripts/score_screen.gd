class_name ScoreScreen extends Control

@onready var _phone: Panel = %Phone as Panel
@onready var _reward: Label = %Reward as Label


func show_scores(reward: int) -> void:
	_reward.text = "+$%s" % reward

	var reward_tween = create_tween().chain()
	reward_tween.tween_property(_phone, "offset_transform_position:y", 0, 0.2)
	reward_tween.tween_property(_phone, "offset_transform_position:y", 400, 0.5).set_delay(2)
	await reward_tween.finished
	SceneLoader.load_scene(Constants.SCENE_UID_MISSION_SELECT)
