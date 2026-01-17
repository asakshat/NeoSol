extends Node2D


@onready var vfx_animation: AnimatedSprite2D = %vfx_animation

func _ready() -> void:
	vfx_animation.play("start")

func _process(delta: float) -> void:
	if vfx_animation.is_playing() == false:
		queue_free()
