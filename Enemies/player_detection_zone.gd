extends Area2D

var player = null

func can_see_player() -> bool:
	return player != null

func _on_body_entered(body: Node2D) -> void:
	player = body # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	player = null # Replace with function body.
