extends Node2D

@onready var WeaponAnimator = $NPCWeaponAnimator

@onready var NPC_Core = $".."

var Canfire: bool = true

var Projectile

var current_weapon: String

var current_capacity: int

var Loadout: Array

var fire_rate: float

var capacity: int

var Equiped_Weapon: String

var LoadoutIndex: int

var casing_scene = load("res://VFX/Weapons/Casing_Assets/Casing-9mm.tscn")

var smoke_scene = load("res://VFX/Weapons/Muzzle_Smoke.tscn")




# I should look into making weapon configuration files a single external file #

const WEAPONS = {
	"92FSX": {
		"fire_rate": 0.2,
		"fire_mode": 1,
		"capacity": 15,
		"reload_speed": 2,
		"reload_type": "magazine",
		"ammo_type": "lightAmmo",
		"max_spread": 3, 
		"projectile_count": 1,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	},
	
	"SPS-7": {
		"fire_rate": 0.10,
		"fire_mode": 3,
		"capacity": 30,
		"reload_speed": 2.5,
		"reload_type": "magazine",
		"ammo_type": "lightAmmo",
		"max_spread": 4,
		"projectile_count": 1,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	},
	"870-TS": {
		"fire_rate": 1,
		"fire_mode": 1,
		"capacity": 5,
		"reload_speed": 0.6,
		"reload_type": "singular",
		"ammo_type": "HeavyAmmo",
		"max_spread": 5,
		"projectile_count": 8,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	}
}

func _ready() -> void:
	
	NPC_Core.Attack.connect(Attack)

	Loadout = ["92FSX"]
	LoadoutIndex = 0
	current_weapon = Loadout[0] # Allways equips the first weapon in the loadout
	current_capacity = WEAPONS[current_weapon]["capacity"] # Set the ammo count to the max count
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	
func Attack():
	
	if current_capacity >= 1 && Canfire == true:
		Canfire = false
			
		# Animation variations
			
		if current_capacity > 1:
			WeaponAnimator.play("%s_Attack" % current_weapon)
		elif current_capacity == 1:
			WeaponAnimator.play("%s_Attack_Empty" % current_weapon)

		# Remove 1 bullet	
				
		current_capacity -= 1
			
		# Spawning bullet #
		
		var projectiles_to_spawn = WEAPONS[current_weapon]["projectile_count"]
			
		# Multi projectile spawning system for weapons #
			
		while projectiles_to_spawn != 0:


			var projectile_scene = load("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
			var projectile = projectile_scene.instantiate()
						
			# Calculating spread angle #
						
			var accuracy_offset = deg_to_rad(randf_range(-WEAPONS[current_weapon]["max_spread"],WEAPONS[current_weapon]["max_spread"]))

			projectile.global_position = $Core/BulletOrigin.global_position
			projectile.global_rotation = $Core/BulletOrigin.global_rotation + accuracy_offset

			get_tree().current_scene.add_child(projectile)
						
			projectiles_to_spawn -= 1
				
			# Spawning bulletcasing effect #
			
			var casing = casing_scene.instantiate()
			
			casing.global_position = $Core/CasingEjection.global_position
			casing.global_rotation = $Core/CasingEjection.global_rotation
			
			get_tree().current_scene.add_child(casing)
			
			var local_right = Vector2.RIGHT.rotated(casing.global_rotation)
				
			casing.apply_central_impulse(local_right * randi_range(750, 1250))
				
			## Spawning gunsmoke effect #
				
			var smoke = smoke_scene.instantiate()
				
			smoke.global_position = $Core/MuzzleParticles.global_position
			smoke.global_rotation = $Core/MuzzleParticles.global_rotation
			
			get_tree().current_scene.add_child(smoke)
			
			await get_tree().create_timer(WEAPONS[current_weapon]["fire_rate"] * 2).timeout
			
			# Animation variations
				
			if current_capacity > 0:
				WeaponAnimator.play("%s_Idle" % current_weapon)
			else:
				WeaponAnimator.play("%s_Idle_Empty" % current_weapon)

			Canfire = true
	
	if current_capacity <= 0 && Canfire == true:
		await Reload(WEAPONS[current_weapon]["reload_type"])
	

@onready var Target: Node2D = $"../../Player"
var PlayerInRange: bool = false
var CombatLoopRunning: bool = false

# Player enters targeting area #

func TargetingAreaEntered(body: Node2D):

	if body.is_in_group("Player"):

		Target = body
		PlayerInRange = true

		if CombatLoopRunning == false:
			CombatLoop()


func TargetingAreaExited(body: Node2D):

	if body == Target:

		PlayerInRange = false
		Target = null


func CombatLoop():

	CombatLoopRunning = true

	while PlayerInRange and is_instance_valid(Target):

		# Check line of sight #
		if NPC_Core.HasLineOfSight(Target) == false:
			await get_tree().create_timer(0.05).timeout
			continue


		if Canfire == false:
			await get_tree().create_timer(0.05).timeout
			continue

			# Reload if empty #
		if current_capacity <= 0:
			await Reload(WEAPONS[current_weapon]["reload_type"])
			continue

		# Fire weapon #
		await Attack()

	CombatLoopRunning = false


## NPC RELOADING ##

func Reload(Reload_Type):
	
	Canfire = false
	
	# Reload for Magazine type weapons (Full reload in one input) #
	
	if Reload_Type == "magazine":
		if current_capacity == 1 || Input.is_action_just_pressed("Combat_Reload_Emergency") && current_capacity != 0 : # Empty reload with a bullet in the chamber or when requested 
			WeaponAnimator.play("%s_Reload_Emergency" % current_weapon)
			await get_tree().create_timer(WEAPONS[current_weapon]["reload_speed"] - 0.5).timeout
		elif current_capacity > 1: # Retention reload
			WeaponAnimator.play("%s_Reload_Retention" % current_weapon)
			await get_tree().create_timer(WEAPONS[current_weapon]["reload_speed"]).timeout
		elif current_capacity <= 0: # Empty reload
			WeaponAnimator.play("%s_Reload_Empty" % current_weapon)
			await get_tree().create_timer(WEAPONS[current_weapon]["reload_speed"]).timeout
		else:
			print_debug("Reload failed. Capacity out of range.")
			pass
		
		current_capacity = WEAPONS[current_weapon]["capacity"]		
		
		WeaponAnimator.play("%s_Idle" % current_weapon)
		
		Canfire = true
	
	elif Reload_Type == "singular":
		while current_capacity < capacity:
			if current_capacity >= 1:
				Canfire = false
				WeaponAnimator.play("%s_Reload" % current_weapon)
				await get_tree().create_timer(WEAPONS[current_weapon]["reload_speed"]).timeout
				current_capacity += 1
				
			elif current_capacity == 0:
				Canfire = false
				WeaponAnimator.play("%s_Reload_Empty" % current_weapon)
				await get_tree().create_timer(WEAPONS[current_weapon]["reload_speed"] * 2).timeout
				current_capacity += 1
			
		Canfire = true
		
		WeaponAnimator.play("%s_Idle" % current_weapon)
		
	else:
		
		# Failsafe #
		
		print_debug("ERROR: Reload type out of range!")
	
