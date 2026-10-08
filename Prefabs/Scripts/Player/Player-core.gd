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

var Health: int
var MaxHealth: int = 100

var Controllable: bool

signal health_changed(Health: int, MaxHealth: int)

func _ready() -> void:
	
	health_changed.emit(Health, MaxHealth)
	
	Health = MaxHealth
	
	Controllable = true
	
	pass

func get_input() -> Vector2:	
	# Check if player should be able to controll the character
	if Controllable == true:
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
	else:
		var input := Vector2.ZERO
		return input.normalized()

		
func _process(_delta):
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
	
	# Function for testing purposes
	if Input.is_action_just_pressed("Combat_Hotkey_Medical"):
		Health += 25
		health_changed.emit(Health, MaxHealth)

# When a projectile enters the hitbox area
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.has_method("Get_Damage"):
			# GET DAMAGE FROM PROJECTILE
			var Damage: int = area.Get_Damage()
			take_damage(Damage)
			
			print_debug("Player hit for %s damage" % Damage)

# Transfer projectile damage to player
func take_damage(Damage):
	Health = Health - Damage
	
	if Health <= 0:
		die()
	else:
		pass
	
	# Signal GUI to update
	health_changed.emit(Health, MaxHealth)
		

func die():
	
	print_debug("Player dead")
	Controllable = false
	# Delete player during deathscreen
	await get_tree().create_timer(0.1).timeout
	queue_free()
