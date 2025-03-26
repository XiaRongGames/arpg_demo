extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")

@export var ACCELERATION = 500
@export var MAX_SPEED = 50
@export var BAT_KNOCKBACK_FRICTION = 200
@export var BAT_KNOCKBACK_POWER = 120
enum {
	IDLE,
	WANDER,
	CHASE
}
# init state
var state = IDLE

var knockback = Vector2.ZERO

@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var sprite = $AnimatedSprite

func _ready() -> void:
	print("bat max health: ", stats.max_health)

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, BAT_KNOCKBACK_FRICTION * delta)
	velocity = knockback
	move_and_slide()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				# old way using math
				# var direction = (player.global_position - global_position).normalized()
				var direction = position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				
	sprite.flip_h = velocity.x < 0
	move_and_slide()
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

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
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
