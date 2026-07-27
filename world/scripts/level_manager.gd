extends Node3D

@onready var _graffiti_spots: Array[GraffitiSpot] = [
	%GraffitiSpot1 as GraffitiSpot,
	%GraffitiSpot2 as GraffitiSpot,
	%GraffitiSpot3 as GraffitiSpot,
	%GraffitiSpot4 as GraffitiSpot,
	%GraffitiSpot5 as GraffitiSpot,
	%GraffitiSpot6 as GraffitiSpot,
]
@onready var _phone: Phone = %Phone as Phone

func _ready() -> void:
	for spot in _graffiti_spots:
		spot.setup(_phone)
