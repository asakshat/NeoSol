extends CharacterBody2D
enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	FLOAT,
	WALL_SLIDE,
	WALL_JUMP,
	DASH,
	Turning,
}
@onready var effect_sprite: Sprite2D = $EffectSprite
@onready var player_animation: AnimationPlayer = %PlayerAnimation
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var float_cooldown: Timer = %FloatCooldown
@onready var wall_slide_ray_cast: RayCast2D = %WallSlideRayCast
@onready var dash_cooldown: Timer = %DashCooldown
@onready var umbrella: AnimatedSprite2D = $AnimatedSprite2D
@onready var horizontal_attack_effect: AnimatedSprite2D = $HorizontalAttackEffect
@onready var vertical_attack_effect: AnimatedSprite2D = $VerticalAttackEffect



const FALL_GRAVITY : float = 1500.0
const FALL_VELOCITY : float = 500.0
const WALK_VELOCITY : float = 200.0
const JUMP_VELOCITY : float = -600.0
const JUMP_DECELERATION : float = 1500.0
const DOUBLE_JUMP_VELOCITY : float = -450.0
const FLOAT_GRAVITY : float = 200.0
const FLOAT_VELOCITY : float = 100.0
const WALL_SLIDE_GRAVITY : float = 300.0
const WALL_SLIDE_VELOCITY : float = 500.0
const WALL_JUMP_LENGTH := 30.0
const WALL_JUMP_VELOCITY := -500.0
const DASH_LENGTH := 100.0
const DASH_VELOCITY := 600.0
const SPRINT_VELOCITY := 400.0
const SPRINT_ACCELERATION := 1800.0


var active_state : STATE = STATE.FALL
var can_double_jump : bool = false
var facing_direction : float = 1.0
var saved_position : Vector2 = Vector2.ZERO
var can_dash : bool = false
var dash_jump_buffer : bool = false
var is_sprinting : bool = false

func _ready() -> void:
	umbrella.visible = false
	umbrella.stop()
	horizontal_attack_effect.visible=false
	horizontal_attack_effect.stop()
	vertical_attack_effect.visible=false
	vertical_attack_effect.stop()
	switch_state(active_state)

func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func switch_state(to_state: STATE) -> void:
	
	if active_state == to_state:
		return
	var previous_state = active_state
	
	if previous_state == STATE.FLOAT:
		umbrella.visible = false
		umbrella.stop()

	active_state = to_state
	match active_state:
		STATE.FALL:
			player_animation.play("fall")
			if previous_state == STATE.FLOOR:
				coyote_timer.start()
		STATE.FLOOR:
			can_double_jump = true
			can_dash = true
		
		STATE.JUMP:
			player_animation.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
		
		STATE.DOUBLE_JUMP:
			player_animation.play("double_jump")
			velocity.y = DOUBLE_JUMP_VELOCITY
			can_double_jump = false
		
		STATE.FLOAT:
			if float_cooldown.time_left > 0:
				active_state = previous_state
				return
			player_animation.play("float")
			umbrella.visible = true
			umbrella.play("umbrella")
			velocity.y = 0
		
		STATE.WALL_SLIDE:
			player_animation.play("wall_slide")
			velocity.y = 0
			can_double_jump = true
			can_dash = true
			
		STATE.WALL_JUMP:
			player_animation.play("jump")
			velocity.y = WALL_JUMP_VELOCITY
			set_facing_direction(-facing_direction)
			saved_position = position
			
		STATE.DASH:
			if dash_cooldown.time_left > 0:
				active_state = previous_state
				return
			player_animation.play("dash")
			velocity.y = 0
			set_facing_direction(signf(Input.get_axis("left","right")))
			velocity.x = facing_direction * DASH_VELOCITY
			saved_position = position
			can_dash = previous_state == STATE.FLOOR or previous_state == STATE.WALL_SLIDE
			dash_jump_buffer = false


func process_state(delta: float) -> void:
	match active_state:
		STATE.FALL:
			velocity.y = move_toward(velocity.y , FALL_VELOCITY , FALL_GRAVITY * delta)
			handle_movement()
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_pressed("jump"):
				if coyote_timer.time_left>0:
					switch_state(STATE.JUMP)
				elif  can_double_jump:
					switch_state(STATE.DOUBLE_JUMP)
				else:
					switch_state(STATE.FLOAT)
			elif is_input_toward_facing() and can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
			elif Input.is_action_just_pressed("dash") and can_dash:
				switch_state(STATE.DASH)

		STATE.FLOOR:
			if Input.get_axis("left", "right"):
				player_animation.play("run")
			else:
				player_animation.play("idle")
			handle_movement()
			if not is_on_floor():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			elif Input.is_action_just_pressed("dash"):
				switch_state(STATE.DASH)
		
		STATE.JUMP, STATE.DOUBLE_JUMP, STATE.WALL_JUMP:
			velocity.y = move_toward(velocity.y,0,JUMP_DECELERATION * delta)
			if active_state == STATE.WALL_JUMP:
				var distance := absf(position.x - saved_position.x)
				if distance >= WALL_JUMP_LENGTH or can_wall_slide():
					active_state = STATE.JUMP
				else : 
					handle_movement(facing_direction)
			if active_state != STATE.WALL_JUMP:
				handle_movement()
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("dash") and can_dash:
				switch_state(STATE.DASH)
		
		STATE.FLOAT:
			velocity.y = move_toward(velocity.y , FLOAT_VELOCITY , FLOAT_GRAVITY * delta)
			handle_movement()
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif Input.is_action_just_released("jump"):
				float_cooldown.start()
				switch_state(STATE.FALL)
			elif is_input_toward_facing() and can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
			elif Input.is_action_just_pressed("dash") and can_dash:
				switch_state(STATE.DASH)
		
		STATE.WALL_SLIDE:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCITY, WALL_SLIDE_GRAVITY * delta)
			handle_movement()
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif not can_wall_slide():
				switch_state(STATE.FALL)
			elif Input.is_action_just_pressed("jump"):
				switch_state(STATE.WALL_JUMP)
			elif  Input.is_action_just_pressed("dash"):
				if not is_input_toward_facing():
					set_facing_direction(-facing_direction)
					switch_state(STATE.DASH)
				
		STATE.DASH:
			dash_cooldown.start()
			if is_on_floor():
				coyote_timer.start()
			if Input.is_action_just_pressed("jump"):
				dash_jump_buffer = true
			var distance := absf(position.x - saved_position.x)
			if distance >= DASH_LENGTH or signf(get_last_motion().x) !=  facing_direction:
				if dash_jump_buffer and coyote_timer.time_left > 0:
					switch_state(STATE.JUMP)
				elif is_on_floor():
					switch_state(STATE.FLOOR)
				else:
					switch_state(STATE.FALL)
			elif can_wall_slide():
				switch_state(STATE.WALL_SLIDE)



func handle_movement(input_direction: float = 0) -> void:
	if input_direction == 0:
		input_direction = signf(Input.get_axis("left" , "right"))
	set_facing_direction(input_direction)
	velocity.x = input_direction * WALK_VELOCITY

func set_facing_direction(direction: float) -> void:
	if direction:
		facing_direction = direction
		player_sprite.flip_h = direction < 0
		wall_slide_ray_cast.position.x = direction * abs(wall_slide_ray_cast.position.x)
		wall_slide_ray_cast.target_position.x = direction * abs(wall_slide_ray_cast.target_position.x)
		wall_slide_ray_cast.force_raycast_update()

func is_input_toward_facing() -> bool:
	return signf(Input.get_axis("left", "right")) == facing_direction

func is_input_against_facing() -> bool:
	return signf(Input.get_axis("left", "right")) == -facing_direction

func can_wall_slide() -> bool:
	return is_on_wall_only() and wall_slide_ray_cast.is_colliding()
