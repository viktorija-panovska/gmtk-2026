class_name Phone extends Control

var _phone_tween: Tween
var _is_phone_hovered: bool
var _is_full_view: bool
var _scene_cursor: Texture2D
var _image_tween: Tween
var _warning_tween: Tween

@onready var _phone: TextureRect = %PhoneObject as TextureRect
@onready var _mission_countdown: Label = %MissionCountdown as Label
@onready var _police_countdown: Label = %PoliceCountdown as Label
@onready var _reference: TextureRect = %Reference as TextureRect
@onready var _full_view: TextureRect = %FullView as TextureRect
@onready var _police_warning: Label = %PoliceWarning as Label


func _ready() -> void:
	_phone.mouse_entered.connect(_hover_phone)
	_phone.mouse_exited.connect(_unhover_phone)
	GameManager.police_incoming.connect(_show_police_alert)
	_reference.texture = Inventory.get_reference_image()


func _process(_delta: float) -> void:
	_mission_countdown.text = Utilities.seconds_to_time(GameManager.get_mission_remaining_seconds())
	_police_countdown.text = Utilities.seconds_to_time(GameManager.get_police_remaining_seconds())
	
	if Input.is_action_just_pressed("Click") and _is_phone_hovered:
		_toggle_image()


func set_scene_cursor(cursor: Texture2D) -> void:
	_scene_cursor = cursor


func is_full_view() -> bool:
	return _is_full_view


func _toggle_image() -> void:
	_is_full_view = !_is_full_view
	_full_view.texture = _reference.texture

	if _image_tween:
		_image_tween.kill()
	_image_tween = create_tween()
	_image_tween.tween_property(_full_view, "scale", Vector2(1, 1) if _is_full_view else Vector2(0, 0), 0.2)


func _hover_phone() -> void:
	Input.set_custom_mouse_cursor(null)
	_is_phone_hovered = true

	if _phone_tween:
		_phone_tween.kill()
	_phone_tween = create_tween()
	_phone_tween.tween_property(_phone, "offset_transform_position:y", -30, 0.2)


func _unhover_phone() -> void:
	if not _is_full_view:
		Input.set_custom_mouse_cursor(_scene_cursor)
	
	_is_phone_hovered = false

	if _phone_tween:
		_phone_tween.kill()
	_phone_tween = create_tween()
	_phone_tween.tween_property(_phone, "offset_transform_position:y", 0, 0.2)


func _show_police_alert() -> void:
	if _warning_tween:
		_warning_tween.kill()
	_warning_tween = create_tween().chain()
	_warning_tween.tween_property(_police_warning, "scale", Vector2(1, 1), 0.1)
	_warning_tween.tween_property(_police_warning, "scale", Vector2(0, 0), 0.5).set_delay(3)
