extends CharacterBody2D

var knockback = Vector2.ZERO
const BAT_KNOCKBACK_FRICTION = 200
const BAT_KNOCKBACK_POWER = 120

@onready var stats = $Stats

func _ready() -> void:
	print("bat max health: ", stats.max_health)

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, BAT_KNOCKBACK_FRICTION * delta)
	velocity = knockback
	move_and_slide()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	
	# eight direction knockback
	#knockback = area.knockback_vector * BAT_KNOCKBACK_POWER
	
	# normalized direction knockback
	var direction = ( position - area.owner.position ).normalized()
	knockback = direction * BAT_KNOCKBACK_POWER
	print("bat current health: ", stats.health)

func _on_stats_no_health() -> void:
	queue_free()
