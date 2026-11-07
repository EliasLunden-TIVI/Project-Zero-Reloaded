extends CharacterBody2D

@export_category("NPC-Stats")

@export var MaxHealth: int
@export var Armor: int

var Torso_Armor: int
var Head_Armor: int

@export_category("NPC-Data")

@export var EnemyName: String

var CorpseRemovalDelay: float = 15

var State: String

var Health

var turning: bool = false

@onready var Target = $"../Player"

@onready var Animator = $NPC_Animator

@onready var BloodAssets = load("res://VFX/Gore/BloodSplatter/VFX_Bloodsplatter.tscn")

@onready var LOS_Ray: RayCast2D = $LOS_Ray

var target: Node2D = null
var target_visible: bool = false
var player_in_range: bool = false

var LOS_Scan_Interval: float = 0.001
var LOS_Scan_Timer: float = 0.0

signal Attack

signal UpdateState(State: float)


func _ready() -> void:

	Health = MaxHealth
	State = "Idle"

	# Configure persistent LOS ray
	LOS_Ray.enabled = true
	LOS_Ray.collide_with_areas = true
	LOS_Ray.collide_with_bodies = true

	# Exclude the NPC's own collision body
	LOS_Ray.add_exception(self)

	# Exclude the NPC's own detection area if necessary
	LOS_Ray.add_exception($TargetingArea)
	
	#LOS_Ray.clear_collision_mask()

	LOS_Ray.set_collision_mask_value(2, true)
	LOS_Ray.set_collision_mask_value(5, true)
	LOS_Ray.set_collision_mask_value(6, true)

# When something enter the collision area
func _on_npc_hurtbox_torso_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.has_method("Get_Damage"):
			# GET DAMAGE FROM PROJECTILE
			var Damage: int = area.Get_Damage()
			Take_Damage(Damage)
	

func Take_Damage(Damage):
	if State != "Dead":
		Health -= Damage
		
		if Health <= 0:
			Die()
		
			print_debug("NPC killed")

func Die():
	
	State = "Dead"
	
	UpdateState.emit(State)
	
	print_debug("NPC Killed")
	
	Animator.play("NPC_%s_Death" % EnemyName)
	await get_tree().create_timer(CorpseRemovalDelay).timeout
	queue_free()


# Player enters detection area

func _on_view_area_area_entered(area: Area2D) -> void:

	if area.is_in_group("Player"):

		target = area
		player_in_range = true


# Player exits detection area

func _on_view_area_area_exited(area: Area2D) -> void:

	if area == target:

		target = null
		player_in_range = false
		target_visible = false


# Periodic perception scan

func _physics_process(delta: float) -> void:

	if State == "Dead":
		pass

	elif player_in_range == false or is_instance_valid(target) == false:
		target_visible = false
		pass

	LOS_Scan_Timer += delta

	if LOS_Scan_Timer >= LOS_Scan_Interval:

		LOS_Scan_Timer = 0.0
		target_visible = HasLineOfSight(target)


# Line of sight

func HasLineOfSight(target_node: Node2D) -> bool:

	if !is_instance_valid(target_node):
		return false

	LOS_Ray.target_position = LOS_Ray.to_local(target_node.global_position)

	LOS_Ray.force_raycast_update()

	if LOS_Ray.is_colliding():

		var collider = LOS_Ray.get_collider()

		if collider.is_in_group("Player"):
			return true

	return false


# NPC turning

func _process(delta: float) -> void:
	
	
	if target_visible and is_instance_valid(target):
		
		turn_towards_target(delta)
		
	else:
		pass


func turn_towards_target(delta: float) -> void:

	var target_angle = global_position.direction_to(target.global_position).angle() + deg_to_rad(90)

	rotation = rotate_toward(rotation, target_angle, 3.0 * delta)
