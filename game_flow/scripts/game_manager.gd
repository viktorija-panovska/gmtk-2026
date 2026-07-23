extends Node

signal police_incoming
signal police_arrived

@export var _mission_time_seconds: float = 300
@export var _police_countdown_seconds: float = 60

var _police_incoming_seconds: float = _police_countdown_seconds / 2
var _mission_countdown: float
var _police_countdown: float
var _is_police_incoming_emitted: bool
var _is_police_arrived_emitted: bool
var _should_refresh_police_countdown: bool


func _ready() -> void:
    _mission_countdown = _mission_time_seconds
    _police_countdown = _police_countdown_seconds


func _process(delta: float) -> void:
    _mission_countdown = max(_mission_countdown - delta, 0)
    _police_countdown = _police_countdown + delta if _should_refresh_police_countdown else max(_police_countdown - delta, 0)

    if _police_countdown == 0 and not _is_police_arrived_emitted:
        _is_police_arrived_emitted = true
        police_arrived.emit()
    
    elif _police_countdown <= _police_incoming_seconds and not _is_police_incoming_emitted:
        _is_police_incoming_emitted = true
        police_incoming.emit()

    if _mission_countdown <= 0:
        print("MISSION OVER")


func get_mission_remaining_seconds() -> int:
    return roundi(_mission_countdown)


func get_police_remaining_seconds() -> int:
    return roundi(_police_countdown)


func set_refresh_police_countdown(refresh: bool) -> void:
    _is_police_incoming_emitted = false
    _is_police_arrived_emitted = false
    _should_refresh_police_countdown = refresh