extends Node

var _scene_path: String
var _fade_tween: Tween
var _black_screen: ColorRect


func _ready() -> void:
	set_process(false)
	_black_screen = ColorRect.new()
	_black_screen.name = "BlackScreen"
	_black_screen.color = Color(0, 0, 0, 0)
	_black_screen.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT)
	_black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_black_screen.top_level = true


func _process(_delta: float) -> void:
	var progress: Array
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, progress)

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			printerr("ERROR: Could not load scene")
		ResourceLoader.THREAD_LOAD_LOADED:
			_finish_load()


func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	get_tree().root.add_child(_black_screen)

	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_black_screen, "color:a", 1, 0.3)
	await _fade_tween.finished

	_black_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_load()


func _start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path, "", false)
	if state == OK:
		set_process(true)
	

func _finish_load() -> void:
	set_process(false)
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(_scene_path))

	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_black_screen, "color:a", 0, 0.3)
	await _fade_tween.finished

	_black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.remove_child(_black_screen)
