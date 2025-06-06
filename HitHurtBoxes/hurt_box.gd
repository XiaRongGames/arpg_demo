extends Area2D

const HitEffect = preload("res://Effects/hit_effect.tscn")

signal invincibility_started
signal invincibility_ended

@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D

var invincible = false: set = set_invincible
		
func set_invincible(value):
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
		
func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect() -> void:
	var effect = HitEffect.instantiate()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position


func _on_timer_timeout() -> void:
	self.invincible = false


func _on_invincibility_started() -> void:	
	set_deferred("monitoring", false)
	
	# alternative to avoid double damage with 2 bats
	collisionShape.set_deferred("disabled", true)


func _on_invincibility_ended() -> void:
	monitoring = true
	
	collisionShape.disabled = false
