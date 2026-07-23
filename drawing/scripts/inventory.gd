extends Node

const DEFAULT_COLOR: Color = Color.BLACK

var _money: int
var _available_colors: Array[Color]
var _available_stencil: Texture2D
var _reference_image: Texture2D


func _ready() -> void:
    _available_colors.append(DEFAULT_COLOR)
    _available_colors.append(Color.RED)
    _available_colors.append(Color.BLUE)


# Called at end of mission to clear out all items
func clear_items() -> void:
    _available_colors.clear()
    _available_colors.append(DEFAULT_COLOR)
    _available_stencil = null
    _reference_image = null


func get_available_colors() -> Array[Color]:
    return _available_colors


func gain_color(color: Color) -> void:
    _available_colors.append(color)


func get_available_stencil() -> Texture2D:
    return _available_stencil


func has_stencil() -> bool:
    return _available_stencil != null


func gain_stencil(stencil: Texture2D) -> void:
    _available_stencil = stencil


func get_money() -> int:
    return _money


func gain_money(amount: int) -> void:
    _money += amount


func spend_money(amount: int) -> void:
    _money -= amount


func get_reference_image() -> Texture2D:
    return _reference_image