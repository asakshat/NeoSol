
class_name PlayerGroundedState extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.air_dash_used = false 
	pass

func exit() -> void:
	pass

# handles input events
func handle_input(event : InputEvent) -> PlayerState:
	var parent_state = super.handle_input(event)  
	if parent_state:
		return parent_state
	if event.is_action_pressed("jump"):
		return jump
	return next_state

func process(_delta:float) -> PlayerState:
	return next_state

func physics_process (_delta:float) -> PlayerState:
	if not player.is_on_floor():
		return fall
	return next_state
