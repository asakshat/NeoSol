class_name PlayerAirredState extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

# handles input events
func handle_input(event : InputEvent) -> PlayerState:
	var parent_state = super.handle_input(event)  
	if parent_state:
		return parent_state
	return next_state

func process(_delta:float) -> PlayerState:
	return next_state

func physics_process (_delta:float) -> PlayerState:
	if player.direction.x != 0:
		player.velocity.x = player.direction.x * player.move_speed
	return next_state
