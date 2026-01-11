class_name PlayerStateDash extends PlayerState

@export var dash_speed : float = 300
@export var dash_duration : float = 0.25


var dash_timer : float = 0

func enter() -> void:
	var dash_dir = player.direction.x if player.direction.x != 0 else player.facing_direction
	player.velocity.x = dash_dir * dash_speed
	player.velocity.y = 0
	player.gravity = 0
	dash_timer = dash_duration
	player.dash_available = false

	if not player.is_on_floor():
		player.air_dash_used = true
	
	pass

func exit() -> void:
	player.gravity = 980
	player.dash_cooldown_timer = player.dash_cooldown
	pass

# handles input events
func handle_input(_event : InputEvent) -> PlayerState:
	return next_state

func physics_process(delta: float) -> PlayerState:
	dash_timer -= delta
	if dash_timer <= 0:
		if player.is_on_floor():
			if player.direction.x != 0:
				return run
			else:
				return idle
		else:
			return fall
	return next_state

func set_jump_frame() -> void:
	pass
