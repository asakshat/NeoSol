class_name Player extends CharacterBody2D

#region // export variables
@export var gravity_scale: float = 1.0
@export var move_speed : float = 220.0
@export var max_fall_velocity : float = 400.0
@export var dash_cooldown = 1.0 

#endregion

#region // state Machine Variables
var states : Array[PlayerState]
var current_state : PlayerState:
	get: return states.front()
var previous_state : PlayerState:
	get: return states[1]
#endregion

#region // standard variables
var direction : Vector2 = Vector2.ZERO
var gravity : float = 980
var facing_direction : float = 1.0
var dash_available : bool = true
var dash_cooldown_timer : float = 0.0
var air_dash_used : bool = false
#endregion


#region // on ready variables
#endregion

func _ready() -> void:
	initialize_states()

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))

func _process(delta: float) -> void:
	update_direction()
	update_dash_cooldown(delta)
	change_state( current_state.process(delta))
	pass

func _physics_process(delta: float) -> void:
	velocity.y += gravity * gravity_scale * delta
	velocity.y = clampf(velocity.y, -1000, max_fall_velocity)
	move_and_slide()
	change_state(current_state.physics_process(delta))
	pass

func initialize_states() -> void:
	states = []
	for s in $States.get_children():
		if s is PlayerState:
			states.append(s)
			s.player = self
	
	if states.size() == 0:
		return 
	
	for state in states:
		state.init()
	
	change_state(current_state)
	current_state.enter()
	$Lable.text = current_state.name

	pass

func change_state(new_state: PlayerState) -> void:
	if new_state == null or new_state == current_state:
		return
	elif new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)
	$Lable.text = current_state.name
	
func update_direction() -> void:
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")
	var deadzone: float = 0.3
	
	x_axis = 0.0 if abs(x_axis) < deadzone else sign(x_axis)
	y_axis = 0.0 if abs(y_axis) < deadzone else sign(y_axis)
	direction = Vector2(x_axis, y_axis)
	if direction.x != 0:
		facing_direction = direction.x

func update_dash_cooldown(delta: float) -> void:
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			dash_available = true
