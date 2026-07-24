class_name Mission extends Resource

@export var _time_in_seconds: int
@export var _reward: int
@export var _reference_image: Texture2D
@export var _description: String
@export var _police_countdown_seconds: int
@export var _stencil: Texture2D


func get_time_in_seconds() -> int:
    return _time_in_seconds


func get_reward() -> int:
    return _reward


func get_reference_image() -> Texture2D:
    return _reference_image


func get_description() -> String:
    return _description


func get_police_countdown_seconds() -> int:
    return _police_countdown_seconds


func get_stencil() -> Texture2D:
    return _stencil
