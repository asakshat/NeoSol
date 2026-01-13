extends Node2D

@onready var effect_animation_one_shot: AnimationPlayer = %EffectAnimationOneShot

func play(anim_name: String) -> void:
	if effect_animation_one_shot.has_animation(anim_name):
		effect_animation_one_shot.play(anim_name)
		effect_animation_one_shot.animation_finished.connect(_on_finished)

func _on_finished(_anim: String) -> void:
	queue_free()
