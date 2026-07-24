extends Node

signal police_incoming
signal police_arrived

var _police_incoming_alert_seconds: float
var _mission_countdown: float
var _police_countdown: float
var _is_police_incoming_emitted: bool
var _is_police_arrived_emitted: bool
var _should_refresh_police_countdown: bool

var _missions: Array[Mission]
var _current_mission: Mission
var _current_mission_idx: int
var _has_mission_started: bool

@onready var _reference_image: Texture2D = preload("res://utilities/icon.svg")
@onready var _stencil: Texture2D = preload("res://utilities/icon.svg")


func _ready() -> void:
	for resource in ResourceLoader.list_directory("res://game_flow/missions/"):
		_missions.append(ResourceLoader.load("res://game_flow/missions/" + resource))


func _process(delta: float) -> void:
	if not _has_mission_started:
		return

	_mission_countdown = max(_mission_countdown - delta, 0)
	_police_countdown = _police_countdown + delta if _should_refresh_police_countdown else max(_police_countdown - delta, 0)
	print(_mission_countdown)

	if _police_countdown == 0 and not _is_police_arrived_emitted:
		_is_police_arrived_emitted = true
		police_arrived.emit()
	
	elif _police_countdown <= _police_incoming_alert_seconds and not _is_police_incoming_emitted:
		_is_police_incoming_emitted = true
		police_incoming.emit()

	if _mission_countdown <= 0:
		print("MISSION OVER")


#region Countdowns

func get_mission_remaining_seconds() -> int:
	return roundi(_mission_countdown)


func get_police_remaining_seconds() -> int:
	return roundi(_police_countdown)


func set_refresh_police_countdown(refresh: bool) -> void:
	_is_police_incoming_emitted = false
	_is_police_arrived_emitted = false
	_should_refresh_police_countdown = refresh

#endregion


#region Missions

func get_mission_count() -> float:
	return len(_missions)


func get_mission(idx: int) -> Mission:
	return _missions[idx] if idx < len(_missions) else null


func get_reference_image() -> Texture2D:
	return _reference_image


func get_stencil() -> Texture2D:
	return _stencil


func start_mission(idx: int) -> void:
	_current_mission = _missions[idx]
	_current_mission_idx = idx

	print("STARTING MISSION")

	_mission_countdown = _current_mission.get_time_in_seconds()
	_police_countdown = _current_mission.get_police_countdown_seconds()
	_police_incoming_alert_seconds = _police_countdown / 2
	_has_mission_started = true

#endregion
