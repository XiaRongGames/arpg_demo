extends Node2D

var GrassEffect = preload("res://World/grass_effect.tscn")
	
func create_grass_effect():
	var grassEffect = GrassEffect.instantiate();
	var world = get_tree().current_scene	
	world.add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	create_grass_effect()
	# free at the end of the frame
	queue_free()
