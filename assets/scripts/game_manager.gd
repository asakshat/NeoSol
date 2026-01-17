extends Node


var player 
var playerOriginalPos

func PlayerEnteredResetArea():
	player.position = playerOriginalPos

func SpawnVFX(vfxToSpawn: Resource, position: Vector2) ->void :
	var vfxInstance = vfxToSpawn.instantiate()  
	vfxInstance.global_position = position
	get_tree().current_scene.add_child(vfxInstance)
