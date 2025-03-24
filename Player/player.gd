extends CharacterBody2D

const PLAYER_ACCELERATION = 500
const PLAYER_FRICTION = 500
const PLAYER_ATTACK_FRICTION = 3
const MAX_SPEED = 80

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var player_velocity = Vector2.ZERO

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
	
func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	animationTree.active = true
	
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)

	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	#print(input_vector)
	
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
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
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
func attack_state(delta):
	
	# next two lines enable attack and slide
	velocity = player_velocity.move_toward(Vector2.ZERO, PLAYER_FRICTION * delta) / PLAYER_ATTACK_FRICTION
	move_and_slide()
	animationState.travel("Attack")
	
	

func attack_animation_finished():
	state = MOVE
	# to zero out extra movement after attacking
	player_velocity = Vector2.ZERO
