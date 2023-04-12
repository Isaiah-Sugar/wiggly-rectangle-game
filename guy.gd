extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const fall_speed = 30
const horizontal_acceleration = 20
const quick_stop_speed = 80

const duck_speed = .16
const duck_stand_speed = .05

const slow_fall_resistance = Vector2(1,.92)
const normal_air_resistance = Vector2(.99,.99)
const pressed_air_resistance = Vector2(.95,.95)



var air_resistance = normal_air_resistance

var spawn_pos = Vector2(0,0)

var bone_duck_scale = .6


@onready var bone_foot = get_node("Skeleton2D/foot")
@onready var bone_head = get_node("Skeleton2D/foot/head")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	spawn_pos = position

func _physics_process(delta):
	var old_velocity = velocity
	
	air_resistance = normal_air_resistance
	var duck_release_buff = Vector2(1,1)
	#release duck
	if not Input.is_action_pressed("move_down") and bone_foot.scale.y != 1:
		bone_foot.scale.y = move_toward(bone_foot.scale.y, 1, duck_stand_speed)
		#y axis multiplier based on how much you're ducking:
		duck_release_buff.y = lerpf(1.4,1,bone_foot.scale.y)
	
	if not is_on_floor(): 
		velocity.y += gravity * delta #gravity
		if Input.is_action_pressed("jump"): #jump is being held
			air_resistance = pressed_air_resistance
			if velocity.y > 0: #if you're falling
				#higher air resistance while falling & jump button is held
				air_resistance = slow_fall_resistance 
		elif Input.is_action_pressed("move_down"):
			velocity.y += fall_speed #fall faster if ducking
		velocity *= air_resistance
		velocity *= duck_release_buff
	else:  #if you are on the floor
		#duck
		if Input.is_action_pressed("move_down") and bone_foot.scale.y != bone_duck_scale:
			bone_foot.scale.y = move_toward(bone_foot.scale.y, bone_duck_scale, duck_speed)
		
		#jump
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")

	if sign(velocity.x) == -1 * sign(direction):
		velocity.x = move_toward(velocity.x, 0, quick_stop_speed)
	else:
		velocity.x = move_toward(velocity.x, direction * SPEED, horizontal_acceleration)

	move_and_slide()
	
#	var acceleration = velocity-old_velocity
	bone_head.position.x = velocity.x/50
	bone_foot.scale.x = 1
		
	if velocity.y > 0:
		bone_foot.scale.x = min(1,inverse_lerp(2000,150,clamp(velocity.y,0,10000)))
	


func _kill(body):
	print("kill :)")
	position = spawn_pos
	
