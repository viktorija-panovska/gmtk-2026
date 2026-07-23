class_name Mission extends Resource

@export var _time: float
@export var _reference_drawing: Texture2D


func _init(time: float = 0, reference_drawing: Texture2D = null):
    _time = time
    _reference_drawing = reference_drawing
