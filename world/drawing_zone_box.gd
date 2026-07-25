extends Area3D
class_name DrawingAreaTrigger

## Scale CollisionShape3D to cover the drawing site

## Assign cop npc as inspector

@export var cop: CopNPC
@export var only_trigger_once_per_visit: bool = true

var _player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if cop:
		cop.arrived_at_car.connect(_on_cop_arrived_at_car)
	else:
		push_warning("trigered, no cop")

func _on_cop_arrived_at_car() -> void:
	# fixes bug where you could just stand in drawing box
	if _player_inside and cop:
		print("[DrawingAreaTrigger] player still in area on cop's return - re-triggering")
		cop.notify_player_entered_drawing_area()

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if only_trigger_once_per_visit and _player_inside:
		return

	_player_inside = true
	print("In drawing box")

	if cop:
		cop.notify_player_entered_drawing_area()
	else:
		push_warning("trigered, no cop")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
