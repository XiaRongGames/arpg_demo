extends CharacterBody2D

@export var PLAYER_ACCELERATION = 500
@export var  PLAYER_FRICTION = 500
@export var  PLAYER_ATTACK_FRICTION = 3
@export var  MAX_SPEED = 80
@export var  ROLL_SPEED = 120

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var player_velocity = Vector2.ZERO
var roll_vector = Vector2.RIGHT
var stats = PlayerStats

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var swordHitbox = $HitboxPivot/SwordHitbox
@onready var playerSwordDamage = swordHitbox.damage
@onready var hurtbox = $HurtBox
	
func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	print("player sword damage: ", playerSwordDamage)
	stats.connect("no_health", Callable(self, "queue_free"))
	print("player max health: ", stats.health)
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	#print(input_vector)
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		player_velocity = player_velocity.move_toward(input_vector * MAX_SPEED, PLAYER_ACCELERATION * delta)
		# alternative movement
		#player_velocity += input_vector * PLAYER_ACCELERATION * delta
		#player_velocity = player_velocity.limit_length(MAX_SPEED)
	else:
		animationState.travel("Idle")
		player_velocity = player_velocity.move_toward(Vector2.ZERO, PLAYER_FRICTION * delta)
		
	#print(player_velocity)	
	velocity = player_velocity
	move_and_slide()
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move_and_slide()
	
func attack_state(delta):
	
	# next two lines enable attack and slide
	velocity = player_velocity.move_toward(Vector2.ZERO, PLAYER_FRICTION * delta) / PLAYER_ATTACK_FRICTION
	move_and_slide()
	animationState.travel("Attack")
	
func roll_animation_finished():
	state = MOVE
	# to zero out extra movement after rolling
	player_velocity = Vector2.ZERO

func attack_animation_finished():
	state = MOVE
	# to zero out extra movement after attacking
	player_velocity = Vector2.ZERO


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if hurtbox.invincible == false:
		stats.health -= 1
		hurtbox.start_invincibility(0.5)
		hurtbox.create_hit_effect()
