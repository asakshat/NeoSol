
class_name PlayerStateFall extends PlayerAirredState


func init() -> void:
	pass

func enter() -> void:
	player.gravity_scale = 2.2
	pass

func exit() -> void:
	player.gravity_scale = 1.0
	pass

# handles input events
func handle_input(event : InputEvent) -> PlayerState:
	#inputs
	var parent_state = super.handle_input(event)
	if parent_state:
		return parent_state
	return next_state

func process(_delta:float) -> PlayerState:
	#set_jump_frame()
	print(player.velocity.y)
	return next_state

func physics_process(_delta:float) -> PlayerState:	
	# air control
	if player.direction.x != 0:
		player.velocity.x = player.direction.x * player.move_speed
	
	#  transition based on movement
	if player.is_on_floor():
		if player.direction.x != 0:
			return run
		else:
			return idle
		
	return next_state
	
func set_jump_frame() -> void:
	var frame: float = remap(player.velocity.y , 0.0 , player.max_fall_velocity, 0.5,1.0 )
	player.animation_player.seek(frame,true)
	pass
