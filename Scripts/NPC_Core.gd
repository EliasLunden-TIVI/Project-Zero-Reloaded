extends CharacterBody2D

@export_category("NPC-Stats")

@export var MaxHealth: int
@export var Armor: int

var Torso_Armor: int
var Head_Armor: int

var Alive: bool

var CorpseRemovalDelay: float = 15

var EnemyName: String

var State: String

var Health

@onready var Animator = $NPC_Animator

@onready var BloodAssets = load("res://VFX/Gore/BloodSplatter/VFX_Bloodsplatter.tscn")

func _ready() -> void:
	
	# Get the first group name to be set as the name and "ID" of the enemy.
	EnemyName = get_groups()[0]
	
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


func _on_view_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		var ray = RayCast2D.new()
		add_child(ray)

		ray.global_position = global_position
		ray.target_position = to_local(area.global_position)
		ray.enabled = true
		ray.collision_mask = 3 # Layer 1 + Layer 2
		ray.collide_with_areas = true
		ray.collide_with_bodies = true
		ray.force_raycast_update()

		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.is_in_group("Player"):
				print_debug("Player Detected!")
			else:
				pass
