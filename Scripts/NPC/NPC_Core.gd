extends CharacterBody2D

@export_category("NPC-Stats")

@export var MaxHealth: int
@export var Armor: int

var Torso_Armor: int
var Head_Armor: int

@export_category("NPC-Data")

@export var EnemyName: String

var Alive: bool

var CorpseRemovalDelay: float = 15

var State: String

var Health

var target: Node2D = null

var target_visible: bool = false

var player_in_range: bool = false

var turning: bool = false

@onready var Target = $"../Player"

@onready var Animator = $NPC_Animator

@onready var BloodAssets = load("res://VFX/Gore/BloodSplatter/VFX_Bloodsplatter.tscn")

signal Attack()

func _ready() -> void:
	
	# Get the first group name to be set as the name and "ID" of the enemy.
	#EnemyName = get_groups()[0]
	
	Health = MaxHealth
	Alive = true

# When something enter the collision area
func _on_npc_hurtbox_torso_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.has_method("Get_Damage"):
			# GET DAMAGE FROM PROJECTILE
			var Damage: int = area.Get_Damage()
			Take_Damage(Damage)
	

func Take_Damage(Damage):
	if Alive == true:
		Health -= Damage
		
		if Health <= 0:
			Die()
		
			print_debug("NPC killed")

func Die():
	Alive = false
	print_debug("NPC Killed")
	
	Animator.play("NPC_%s_Death" % EnemyName)
	await get_tree().create_timer(CorpseRemovalDelay).timeout
	queue_free()

@onready var BulletOrigin = $WeaponManager/Core/BulletOrigin
@onready var Projectile = load("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")


func _on_view_area_area_entered(area: Area2D) -> void:

	# Only checks for Player #

	if area.is_in_group("Player"):
		target = area
		target_visible = true
		player_in_range = true

		# Check line of sight
		check_line_of_sight()
		

func _on_view_area_area_exited(area: Area2D) -> void:

	if area.is_in_group("Player"):
		target_visible = false
		player_in_range = false
		target = null


func check_line_of_sight():

	# Check if player is visible with Raycast #

	var ray = RayCast2D.new()
	add_child(ray)

	ray.position = Vector2.ZERO
	ray.target_position = ray.to_local(target.global_position)
	ray.collision_mask = 3
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.enabled = true
	
#	ray.add_exception(self)
	ray.add_exception($TargetingArea)
	
	ray.force_raycast_update()

	if ray.is_colliding():

		var collider = ray.get_collider()

		if collider.is_in_group("Player"):
			target_visible = true
			$TargetingArea.monitoring = true
		else:
			target_visible = false
			$TargetingArea.monitoring = false

	else:

		target_visible = false

	ray.queue_free()
	var collider = ray.get_collider()

	if collider.is_in_group("Player"):

		target_visible = true
	else:
		target_visible = false
	
	ScanForTargets()
	
	ray.queue_free()
	

func _process(delta):

	if target_visible == true and is_instance_valid(target):
		turn_towards_target(delta)


func turn_towards_target(delta):

	var target_angle = global_position.direction_to(target.global_position).angle() + deg_to_rad(90)

	rotation = rotate_toward(rotation, target_angle, 3.0 * delta)
				
func HasLineOfSight(target: Node2D) -> bool:
	
	var LOS_Ray = RayCast2D.new()
	add_child(LOS_Ray)
	
	if !is_instance_valid(target):
		return false

	LOS_Ray.target_position = LOS_Ray.to_local(target.global_position)
	LOS_Ray.force_raycast_update()

	if LOS_Ray.is_colliding():

		var collider = LOS_Ray.get_collider()

		if collider.is_in_group("Player"):
			return true

	return false

func ScanForTargets():

	while true:

		if is_instance_valid(target) && player_in_range == true:

			target_visible = HasLineOfSight(target)

			if target_visible:
				print_debug("Player visible!")
			elif player_in_range == false: 
				print_debug("Player exited area!")
				break
			else:
				print_debug("Player not visible!")

		await get_tree().create_timer(0.1).timeout
