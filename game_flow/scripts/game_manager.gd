extends Node

@export var _mission_time_seconds: float = 300
@export var _police_countdown_seconds: float = 60

var _mission_countdown: float
var _police_countdown: float


func _ready() -> void:
    _mission_countdown = _mission_time_seconds
    _police_countdown = _police_countdown_seconds


func _process(delta: float) -> void:
    _mission_countdown -= delta
    _police_countdown -= delta

    if _police_countdown <= 0:
        print("POLICE ARE HERE")

    if _mission_countdown <= 0:
        print("MISSION OVER")


func get_mission_remaining_seconds() -> int:
    return roundi(_mission_countdown)

func get_police_remaining_seconds() -> int:
    return roundi(_police_countdown)