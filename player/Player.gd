class_name Player extends CharacterBody3D



@export var debug = false
@export var speed = 6
@export var SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 1
@export var BOB_AMP = 0.03
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

var _is_input_paused: bool

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#CharacterBody3D Parameters:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_max_angle = deg_to_rad(100) #Snap Up Max Height
	floor_snap_length = 0.2 #Snap Down Max Drop (before gravity sets in instead)
	#Stop From Getting Stuck On Walls (slide along):	
	max_slides = 6
	safe_margin = 0.01

func _input(event):
	if event is InputEventMouseMotion and not _is_input_paused:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	if debug:
		# Uncapture the mouse when pressing the UI Cancel button (Default: Escape Key)
		if event.is_action_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		# Recapture the mouse when clicking back inside the game window
		if event is InputEventMouseButton and event.pressed:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _update_footsteps() -> void:
	if not footstep_player:
		return
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var should_be_walking := horizontal_speed > 0.5 and is_on_floor()

	if should_be_walking and not footstep_player.playing:
		footstep_player.play()
	elif not should_be_walking and footstep_player.playing:
		footstep_player.stop()

func _physics_process(delta):
	if _is_input_paused:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	
	var target_fov = BASE_FOV 
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	_update_footsteps()   
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func toggle_pause_input() -> void:
	_is_input_paused = !_is_input_paused
