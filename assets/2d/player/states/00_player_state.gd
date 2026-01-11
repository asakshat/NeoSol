@icon("res://assets/2d/player/states/state.svg")
class_name PlayerState extends Node

var player : Player
var next_state : PlayerState = null

#region // state preferences
@onready var run: PlayerStateRun = %Run
@onready var idle: PlayerStateIdle = %Idle

@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall
@onready var dash: PlayerStateDash = %Dash

#endregion

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

# handles input events
func handle_input(_event : InputEvent) -> PlayerState:
	if _event.is_action_pressed("dash"):
		if player.dash_available:
			if player.is_on_floor() or not player.air_dash_used:
				return dash
	return next_state

func process(_delta:float) -> PlayerState:
	return next_state

func physics_process (_delta:float) -> PlayerState:
	return next_state
