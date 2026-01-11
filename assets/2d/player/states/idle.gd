
class_name PlayerStateIdle extends PlayerGroundedState

func init() -> void:
	pass

func enter() -> void:
	super.enter()

	pass

func exit() -> void:
	pass

# handles input events
func handle_input(event : InputEvent) -> PlayerState:
	var parent_state = super.handle_input(event)
	if parent_state:
		return parent_state
	return next_state

func process(delta:float) -> PlayerState:
	super.process(delta)
	if player.direction.x !=0:
		return run
	return next_state

func physics_process (delta:float) -> PlayerState:
	var parent_state = super.physics_process(delta)
	if parent_state:  
		return parent_state
	
	player.velocity.x = 0
	return next_state
