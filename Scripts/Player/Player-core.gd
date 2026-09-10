extends CharacterBody2D

### MOVEMENT ###

# CURRENT PLAYER SPEED
var SPEED: float
# PRECENT % BASED MODIFIER THAT DECREASES / INCREASES MOVEMENT. ITS APPLIED TO ALL MOVEMENT!
@export var SPEEDMODIFIER: float = 1.0
# DEFAULT WALKSPEED
@export var BASEWALKSPEED: float = 750
# DEFAULT RUNSPEED
@export var BASESPRINTSPEED: float = 1500
# IF PLAYER MOVEMENT IS ENABLED
@export var MovementActive: bool = true

func _ready() -> void:
	pass

func get_input() -> Vector2:	
	var input := Vector2.ZERO
	
	# CALCULATE MOVEMENT STRENGHT ON THE X AXIS
	input.x = Input.get_action_strength("Movement_Left") - Input.get_action_strength("Movement_Right")
	# CALCULATE MOVEMENT STRENGHT ON THE Y AXIS
	input.y = Input.get_action_strength("Movement_Down") - Input.get_action_strength("Movement_Up")
	
	if Input.is_action_pressed("Movement_Sprint"):
		SPEEDMODIFIER = 1.25
	else:
		SPEEDMODIFIER = 1
		
	return input.normalized()

		
func _process(delta):
	var playerInput = get_input()
	
	if Input.is_action_pressed("Movement_Sprint"):
		SPEED = BASESPRINTSPEED
	else:
		SPEED = BASEWALKSPEED
		
	velocity = playerInput * SPEED * SPEEDMODIFIER 
		
	move_and_slide()

	

		# Independent aim direction
	var mouse_position = get_global_mouse_position()
		# TURN PLAYER TO FACE CURSOR 
	rotation = global_position.direction_to(mouse_position).angle() + PI / 2 # PI / 2 fixes rotation offset
		
