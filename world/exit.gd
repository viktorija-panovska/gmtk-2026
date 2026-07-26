extends Area3D

var _player: Player
@onready var _prompt: Label = %ExitPrompt as Label
@onready var _score_screen: ScoreScreen = %ScoreScreen as ScoreScreen


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and _player:
		_player.toggle_pause_input()
		_score_screen.show_scores(GameManager.get_reward())


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_prompt.visible = true
		_player = body


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_prompt.visible = false
		_player = null
