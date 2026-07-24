extends Node

var _mission_buttons: Array[Button]
var _mission_button_labels: Array[Label]

@onready var _mission_list: Control = %MissionList as Control


func _ready() -> void:
	for child in _mission_list.get_children():
		if not child is Button: continue
		_add_mission_button(child)
		
		var grandchild = child.get_child(0)
		if grandchild and grandchild is Label:
			_add_mission_button_label(grandchild)
	
	print(_mission_buttons)
	print(_mission_button_labels)


func _add_mission_button(button: Button) -> void:
	var mission_idx: int = len(_mission_buttons)
	# TODO: if the index is less than the number of missions
	button.pressed.connect(func(): _open_mission_detail(mission_idx))
	_mission_buttons.append(button)


func _add_mission_button_label(label: Label) -> void:
	# TODO: if the index is less than the number of missions
	label.text = "Hello"
	_mission_button_labels.append(label)


func _open_mission_detail(mission_idx: int) -> void:
	print("open: " + str(mission_idx))
