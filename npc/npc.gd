extends CharacterBody3D
class_name CopNPC


## Expects children:
##   -NavigationAgent3D
##   -VisionCone3D
##   - StateTimer

## need 2 markers, car and drawing spot
@onready var anim_player: AnimationPlayer = $Cop_anim/AnimationPlayer
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var siren_player: AudioStreamPlayer3D = $SirenPlayer
@onready var whistle_player: AudioStreamPlayer3D = $WhistlePlayer

signal player_busted

@export_group("Busted")
@export var busted_radius: float = 2.0    # how close counts as "caught"
@export var busted_time: float = 5.0      # how long within that radius before busted

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var vision_cone: VisionCone3D = $VisionCone3D
@onready var state_timer: Timer = $StateTimer

@export var move_speed: float = 5.0
@export var chase_speed: float = 7.0
@export var car_spot: Marker3D
@export var drawing_site_spot: Marker3D
var car_position: Vector3
var drawing_site_position: Vector3

@export_group("Timings (seconds)")
@export var reaction_delay: float = 2.0        # pause in car before heading out

## mby random
##randomize() # mby not needed
##reaction_delay = randf_range(0.0, 10.0)
 
@export var warning_time: float = 1.5          # aka spot before chase
@export var wait_at_site_time: float = 5.0     # idle at drawing box (marker 3d)
##@export var search_time_at_last_known: float = 3.0 
@export var confused_time: float = 3.0 # confused

signal arrived_at_car

enum State {
	IN_CAR,
	TO_DRAWING_SITE,
	AT_DRAWING_SITE,
	SPOTTED_WARNING,
	CHASE,
	SEARCH_LAST_KNOWN,
	CONFUSED,
	RETURN_TO_CAR,
}

var _busted_proximity_time: float = 0.0
var _busted: bool = false

var state: State = State.IN_CAR
var player: Node3D = null
var player_currently_visible: bool = false
var last_known_position: Vector3
var _pending_state: int = -1   # used only for the "wait then transition" cases

func _ready() -> void:
	_setup_animation_loops()
	if car_spot:
		car_position = car_spot.global_position
	else:
		push_warning("NPC: no car spor check marker")
	if drawing_site_spot:
		drawing_site_position = drawing_site_spot.global_position
	else:
		push_warning("NPC: no drawing spot check marker")

	vision_cone.body_sighted.connect(_on_body_sighted)
	vision_cone.body_hidden.connect(_on_body_hidden)
	vision_cone.body_entered.connect(func(_body: Node3D) -> void:
		print("Debug: player in cone")
	)
	vision_cone.body_exited.connect(_on_area_body_exited)
	state_timer.one_shot = true
	state_timer.timeout.connect(_on_state_timer_timeout)
	_enter_state(State.IN_CAR)
	floor_max_angle = deg_to_rad(100) #Snap Up Max Height
	floor_snap_length = 0.2 #Snap Down Max Drop (before gravity sets in instead)
	
	
func _play_anim(anim_name: String) -> void:
	if not anim_player:
		return
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)
		
func _update_footsteps() -> void:
	if not footstep_player:
		return
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var should_be_walking := horizontal_speed > 0.2 and is_on_floor()
 
	if should_be_walking and not footstep_player.playing:
		footstep_player.play()
	elif not should_be_walking and footstep_player.playing:
		footstep_player.stop()
		
func _play_one_shot(player: AudioStreamPlayer3D) -> void:
	if not player:
		return
	player.stop()   # restart cleanly even if it's still finishing a previous play
	player.play()
		
func _setup_animation_loops() -> void:
	if not anim_player:
		return
	var exclude := ["Gun in holster"]
	for anim_name in anim_player.get_animation_list():
		if anim_name in exclude:
			continue
		var anim := anim_player.get_animation(anim_name)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR

## notify cop if he is in car
func notify_player_entered_drawing_area() -> void:
	print("NPC: player at draw spot ")
	if state == State.IN_CAR:
		_pending_state = State.TO_DRAWING_SITE
		state_timer.start(reaction_delay)
		print("cop ready in car staring search ")

func _on_state_timer_timeout() -> void:
	print("NPC state change: ", _pending_state)
	if _pending_state != -1:
		var next = _pending_state
		_pending_state = -1
		_enter_state(next)
		return

	match state:
		State.AT_DRAWING_SITE:
			_enter_state(State.RETURN_TO_CAR)
		State.SPOTTED_WARNING:
			_enter_state(State.CHASE)
		State.SEARCH_LAST_KNOWN:
			_enter_state(State.CONFUSED)
		State.CONFUSED:
			_enter_state(State.RETURN_TO_CAR)

func _enter_state(new_state: State) -> void:
	state_timer.stop()
	state = new_state
	print("NPC entered ", State.keys()[state], " state")

	match state:
		State.IN_CAR:
			_play_anim("Gun in holster") 
			vision_cone.monitoring = false #cone off in car
			global_position = car_position
			velocity = Vector3.ZERO
			arrived_at_car.emit()
			

		State.TO_DRAWING_SITE:
			_play_one_shot(siren_player)
			_play_anim("Walk")
			vision_cone.monitoring = true   #cone on in all other cases
			nav_agent.set_target_position(drawing_site_position)
			print("NPC moving to draw site")
			print("NPC target reachable: ", nav_agent.is_target_reachable())

		State.AT_DRAWING_SITE:
			_play_anim("Looking around") 
			vision_cone.monitoring = true
			velocity = Vector3.ZERO
			state_timer.start(wait_at_site_time)

		State.SPOTTED_WARNING:
			#_play_one_shot(whistle_player)
			_play_anim("Gun in holster")  
			
			velocity = Vector3.ZERO
			state_timer.start(warning_time)
			# hook up alers here

		State.CHASE:
			_play_one_shot(whistle_player)
			
			_play_anim("Walk with gun")
			 
			if player:
				nav_agent.set_target_position(player.global_position)

		State.SEARCH_LAST_KNOWN:
			_play_anim("Walk with gun") 
			nav_agent.set_target_position(last_known_position)

		State.CONFUSED:
			velocity = Vector3.ZERO
			_play_anim("Looking around")
			# hook up confused here
			state_timer.start(confused_time)

		State.RETURN_TO_CAR:
			_play_anim("Walk")  
			vision_cone.monitoring = true
			nav_agent.set_target_position(car_position)


func _on_body_sighted(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	player_currently_visible = true
	# Can be spotted from any "out of the car" state.
	var spottable_states = [
		State.TO_DRAWING_SITE, State.AT_DRAWING_SITE,
		State.SEARCH_LAST_KNOWN, State.CONFUSED, State.RETURN_TO_CAR,
	]
	if state in spottable_states:
		player = body
		_enter_state(State.SPOTTED_WARNING)

# player always visable bug fix
func _on_area_body_exited(body: Node3D) -> void:
	print("Debug: player exited vision volume")
	_on_body_hidden(body)


# stops early chase by forcing player invisble, bs but wahtever big fixed
func _on_body_hidden(body: Node3D) -> void:
	if body != player:
		return
	player_currently_visible = false
	if state == State.CHASE:
		last_known_position = player.global_position
		_enter_state(State.SEARCH_LAST_KNOWN)
	elif state == State.SPOTTED_WARNING:

		last_known_position = body.global_position
		_enter_state(State.SEARCH_LAST_KNOWN)


func _physics_process(_delta: float) -> void:
	_apply_gravity(_delta)
	_update_busted_check(_delta)
	_update_footsteps()
	match state:
		State.CHASE:
			if player and player_currently_visible:
				nav_agent.set_target_position(player.global_position)
			_move(chase_speed)

		State.TO_DRAWING_SITE, State.RETURN_TO_CAR:
			_move(move_speed)
			if nav_agent.is_navigation_finished():
				_on_arrived()

		State.SEARCH_LAST_KNOWN:
			_move(move_speed)
			if nav_agent.is_navigation_finished():
				if state_timer.is_stopped():
					##state_timer.start(confused_time) #no need  double
					print("arrived at last known spot")
					_play_anim("Looking around")
					state_timer.start(0)
				_stand_still()

		_:
			_stand_still()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0

func _update_busted_check(delta: float) -> void:
	if _busted:
		return


	if state != State.CHASE or player == null:
		_busted_proximity_time = 0.0
		return

	var distance := global_position.distance_to(player.global_position)
	if distance <= busted_radius:
		_busted_proximity_time += delta
		if _busted_proximity_time >= busted_time:
			_trigger_busted()
	else:
		_busted_proximity_time = 0.0


func _trigger_busted() -> void:
	_busted = true
	print("NPC: BUSTED")
	player_busted.emit()

	velocity = Vector3.ZERO


func _stand_still() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()


func _move(speed: float) -> void:
	if nav_agent.is_navigation_finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var next_pos := nav_agent.get_next_path_position()
	var to_next := next_pos - global_position
	to_next.y = 0.0

	if to_next.length() < 0.05:

		move_and_slide()
		return

	var direction := to_next.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	look_at(global_position + direction, Vector3.UP)
	move_and_slide()


func _on_arrived() -> void:
	match state:
		State.TO_DRAWING_SITE:
			_enter_state(State.AT_DRAWING_SITE)
		State.RETURN_TO_CAR:
			_enter_state(State.IN_CAR)
