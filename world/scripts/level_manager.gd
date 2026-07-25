extends Node3D

@export var _graffiti_locations: Dictionary[Constants.Location, Marker3D]

@onready var _graffiti_spot: Node3D = %GraffitiSpot as Node3D


func _ready() -> void:
	var location = GameManager.get_graffiti_location()
	if location not in _graffiti_locations: return
	_graffiti_spot.global_position = _graffiti_locations[location].global_position
	_graffiti_spot.global_rotation = _graffiti_locations[location].global_rotation
