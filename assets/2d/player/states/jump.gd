class_name PlayerStateJump extends PlayerAirredState

@export var jump_force : float = -460
func init() -> void:
	pass

func enter() -> void:
	player.velocity.y = jump_force
	if player.previous_state == fall and not Input.is_action_pressed("jump"):
		await get_tree().physics_frame
		player.velocity.y *= 0.5
		player.change_state(fall)
		pass
	pass

func exit() -> void:
	pass

# handles input events
func handle_input(event : InputEvent) -> PlayerState:
	var parent_state = super.handle_input(event)
	if parent_state:
		return parent_state
	if event.is_action_released("jump"):
		player.velocity.y *= 0.5
	return next_state

func process(_delta:float) -> PlayerState:
	#set_jump_frame()
	return next_state
 
func physics_process (_delta:float) -> PlayerState: 
	if player.direction.x != 0:
		player.velocity.x = player.direction.x * player.move_speed
	if player.velocity.y > 0:
		return fall
	return next_state

func set_jump_frame() -> void:
	var frame: float = remap(player.velocity.y , jump_force , 0.0, 0.0,0.5 )
	player.animation_player.seek(frame,true)
	pass
