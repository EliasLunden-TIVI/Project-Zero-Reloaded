extends Node2D

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
		"capacity": 6,
		"reload_speed": 0.6,
		"reload_type": "singular",
		"ammo_type": "HeavyAmmo",
		"max_spread": 8,
		"projectile_count": 8,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	}
}

@onready var WeaponAnimator = $WeaponAnimator

signal ammo_changed(current_capacity: int, capacity: int)
signal weapon_changed(current_weapon: String)
#signal weapon_changed(currentWeapon: String)

func _ready() -> void:
	
	Loadout = ["92FSX", "SPS-7", "870-TS"]
	LoadoutIndex = 0
	current_weapon = Loadout[0] # Allways equips the first weapon in the loadout
	current_capacity = WEAPONS[current_weapon]["capacity"] # Set the ammo count to the max count
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	# Small delay to allow the GUI element to be instantiated
	await get_tree().create_timer(0.1).timeout
	
	weapon_changed.emit(current_weapon)
	ammo_changed.emit(current_capacity, capacity)
	

func Swap_Weapon(Weapon_Name: String) -> void:
	
	if LoadoutIndex != Loadout.size() -1:
		LoadoutIndex += 1
	else:
		LoadoutIndex = 0
	
	print_debug(LoadoutIndex)
	
	current_weapon = Loadout[LoadoutIndex]
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	# Update stats
	
	current_capacity = WEAPONS[current_weapon]["capacity"]
	capacity = WEAPONS[current_weapon]["capacity"]
	
	# Send signals
	
	weapon_changed.emit(Weapon_Name)
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	# Update GUI
	
	weapon_changed.emit(current_weapon)
	ammo_changed.emit(current_capacity, capacity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Swapped to is_action_pressed to allow holding down button to fire
	if Input.is_action_pressed("Combat_Attack") && Canfire && current_capacity > 0:
		Attack()

# Called when the player presses something
func _input(_event: InputEvent) -> void:
	# Reload if the player Can fire (Not mid animation) and if the weapon is not fully loaded
	if Input.is_action_just_pressed("Combat_Reload") && Canfire && current_capacity < WEAPONS[current_weapon]["capacity"]:
		Reload(WEAPONS[current_weapon]["reload_type"])
		
	if Input.is_action_just_pressed("Combat_Swapweapon") && Canfire == true:
		current_weapon = Loadout[LoadoutIndex]
		Swap_Weapon(current_weapon)
		

func Attack():
	Canfire = false
	
	# Animation variations
	
	if current_capacity > 1:
		WeaponAnimator.play("%s_Attack" % current_weapon)
	elif current_capacity == 1:
		WeaponAnimator.play("%s_Attack_Empty" % current_weapon)
		
	# Remove 1 bullet	
		
	current_capacity -= 1
	
	# Signal and update UI with new data
	
	ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
	
	# Spawning bullet #
	
	var weapon_data = WEAPONS[current_weapon]
	
	var projectiles_to_spawn = WEAPONS[current_weapon]["projectile_count"]
	
	# Multi projectile spawning system for weapons #
	
	while projectiles_to_spawn != 0:


		var projectile_scene: PackedScene = weapon_data["projectile"]
		var projectile = projectile_scene.instantiate()
		
		# Calculating spread angle #
		
		var accuracy_offset = deg_to_rad(randf_range(-weapon_data["max_spread"],weapon_data["max_spread"]))

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
	
	
	
	# Spawning gunsmoke effect #
	
	var smoke = smoke_scene.instantiate()
	
	smoke.global_position = $Core/MuzzleParticles.global_position
	smoke.global_rotation = $Core/MuzzleParticles.global_rotation

	get_tree().current_scene.add_child(smoke)
	
	await get_tree().create_timer(weapon_data["fire_rate"]).timeout

	Canfire = true
	
	# Animation variations
	
	if current_capacity > 0:
		WeaponAnimator.play("%s_Idle" % current_weapon)
	else:
		WeaponAnimator.play("%s_Idle_Empty" % current_weapon)
	
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
		
		# Signal and update UI with new data
		
		ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
		
		WeaponAnimator.play("%s_Idle" % current_weapon)
		
		Canfire = true
	
	elif Reload_Type == "singular":
		while current_capacity <= capacity:
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
				
			# Signal GUI update #
			ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
			
		Canfire = true
		
		WeaponAnimator.play("%s_Idle" % current_weapon)
		
	else:
		
		# Failsafe #
		
		print_debug("ERROR: Reload type out of range!")
		current_capacity = WEAPONS[current_weapon]["capacity"]
		ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
	
	
