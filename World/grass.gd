extends Node2D

const GrassEffect = preload("res://Effects/grass_effect.tscn")
	
func create_grass_effect():
	var grassEffect = GrassEffect.instantiate();
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_hurt_box_area_entered(_area: Area2D) -> void:
	create_grass_effect()
	# free at the end of the frame
	queue_free()
