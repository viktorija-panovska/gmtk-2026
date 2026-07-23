extends Node

@export var _default_color: Color = Color.BLACK

var _money: int
var _available_colors: Array[Color]
var _available_stencil: Texture2D


func _ready() -> void:
    _available_colors.append(_default_color)


# Called at end of mission to clear out all items
func clear() -> void:
    _available_colors.clear()
    _available_colors.append(_default_color)



func get_available_colors() -> Array[Color]:
    return _available_colors


func gain_color(color: Color) -> void:
    _available_colors.append(color)


func get_available_stencil() -> Texture2D:
    return _available_stencil


func gain_stencil(stencil: Texture2D) -> void:
    _available_stencil = stencil


func get_money() -> int:
    return _money


func gain_money(amount: int) -> void:
    _money += amount


func spend_money(amount: int) -> void:
    _money -= amount