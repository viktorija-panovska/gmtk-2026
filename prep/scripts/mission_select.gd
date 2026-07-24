extends Node

var _mission_buttons: Array[Button]
var _mission_button_labels: Array[Label]
var _selected_mission_idx: int = -1

@onready var _mission_list: Control = %MissionList as Control
@onready var _mission_detail: Control = %MissionDetail as Control
@onready var _mission_description: Label = %MissionDescription as Label
@onready var _reference_image: TextureRect = %ReferenceImage as TextureRect
@onready var _mission_reward: Label = %MissionReward as Label
@onready var _mission_time: Label = %MissionTime as Label
@onready var _accept_button: Button = %AcceptButton as Button
@onready var _back_button: Button = %BackButton as Button


func _ready() -> void:
	_accept_button.pressed.connect(_accept_mission)
	_back_button.pressed.connect(_close_mission_detail)
	for child in _mission_list.get_children():
		if not child is Button: continue
		_add_mission_button(child)
		
		var grandchild = child.get_child(0)
		if grandchild and grandchild is Label:
			_add_mission_button_label(grandchild)
	_mission_list.visible = true


func _add_mission_button(button: Button) -> void:
	var mission_idx: int = len(_mission_buttons)
	if mission_idx < GameManager.get_mission_count():
		button.pressed.connect(func(): _open_mission_detail(mission_idx))

	_mission_buttons.append(button)


func _add_mission_button_label(label: Label) -> void:
	var mission: Mission = GameManager.get_mission(len(_mission_button_labels))
	if mission != null:
		label.text = mission.get_description()

	_mission_button_labels.append(label)


func _open_mission_detail(mission_idx: int) -> void:
	_selected_mission_idx = mission_idx
	var mission: Mission = GameManager.get_mission(mission_idx)

	_mission_description.text = mission.get_description()
	_reference_image.texture = mission.get_reference_image()
	_mission_reward.text = "Reward: $%s" % mission.get_reward()
	_mission_time.text = "Time: %s" % Utilities.seconds_to_time(mission.get_time_in_seconds())

	_mission_list.visible = false
	_mission_detail.visible = true


func _close_mission_detail() -> void:
	_selected_mission_idx = -1
	_mission_detail.visible = false
	_mission_list.visible = true


func _accept_mission() -> void:
	GameManager.accept_mission(_selected_mission_idx)
