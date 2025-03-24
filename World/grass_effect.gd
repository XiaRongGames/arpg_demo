extends Node2D

@onready var animatedSprite = $AnimatedSprite2D

func _ready() -> void:
	animatedSprite.play("GrassAnimate")

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free() # Replace with function body.
