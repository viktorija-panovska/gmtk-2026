extends Node3D

@export var _graffiti_locations: Dictionary[Constants.Location, Marker3D]

@onready var _graffiti_spot: GraffitiSpot = %GraffitiSpot as GraffitiSpot
@onready var _phone: Phone = %Phone as Phone


func _ready() -> void:
	var location = Constants.Location.WALL#GameManager.get_graffiti_location()
	if location not in _graffiti_locations: return
	_graffiti_spot.setup(_graffiti_locations[location], _phone)
