extends CharacterBody2D

const EnemyDeathEffect = preload("res://Effects/enemy_death_effect.tscn")

@export var ACCELERATION = 300
@export var MAX_SPEED = 50
@export var BAT_KNOCKBACK_FRICTION = 200
@export var BAT_KNOCKBACK_POWER = 150
@export var BAT_SOFT_COLLISION_POWER = 400
@export var BAT_WANDER_BUFFER = 4
@export var BAT_INVINCIBILITY_TIME = 0.4

enum {
	IDLE,
	WANDER,
	CHASE
}
# init state
var state = CHASE

var bat_velocity = Vector2.ZERO
var knockback = Vector2.ZERO

@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var sprite = $AnimatedSprite
@onready var hurtbox = $HurtBox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var animationPlayer = $AnimationPlayer

func _ready() -> void:
	# randomize bat behavior, instead of seeding
	randomize()
	print("bat max health: ", stats.max_health)
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, BAT_KNOCKBACK_FRICTION * delta)
	velocity = knockback
	move_and_slide()
	knockback = velocity

	match state:
		IDLE:
			bat_velocity = bat_velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				start_wander_or_idle()
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				start_wander_or_idle()
				
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= BAT_WANDER_BUFFER:
				start_wander_or_idle()
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				# old way using math
				# var direction = (player.global_position - global_position).normalized()
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		bat_velocity += softCollision.get_push_vector() * delta * BAT_SOFT_COLLISION_POWER
		
	velocity = bat_velocity
	move_and_slide()
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	bat_velocity = bat_velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = bat_velocity.x < 0
	
func start_wander_or_idle():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(randf_range(1, 3))
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	
	# eight direction knockback
	#knockback = area.knockback_vector * BAT_KNOCKBACK_POWER
	
	# normalized direction knockback
	var direction = ( position - area.owner.position ).normalized()
	knockback = direction * BAT_KNOCKBACK_POWER
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(BAT_INVINCIBILITY_TIME)
	
	print("bat current health: ", stats.health)

func _on_stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_hurt_box_invincibility_started() -> void:
	animationPlayer.play("Start")


func _on_hurt_box_invincibility_ended() -> void:
	animationPlayer.play("Stop")
