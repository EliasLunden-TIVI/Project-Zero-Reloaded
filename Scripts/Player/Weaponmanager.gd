extends Node2D

var Canfire: bool = true

var Projectile

var current_weapon: String

var current_capacity: int

var Loadout: Array

var fire_rate: float

var capacity: int

var Equiped_Weapon: String

const WEAPONS = {
	"92FSX": {
		"fire_rate": 0.15,
		"fire_mode": 1,
		"capacity": 15,
		"reload_speed": 2.5,
		"reload_type": "magazine",
		"ammo_type": "lightAmmo",
		#"max_spread": 3, # Spread not implemented yet.
		"projectile_count": 1,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	},
	
	"SPS-7": {
		"fire_rate": 0.10,
		"fire_mode": 3,
		"capacity": 30,
		"reload_speed": 4,
		"reload_type": "magazine",
		"ammo_type": "lightAmmo",
		"max_spread": 6,
		"projectile_count": 1,
		"projectile": preload("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")
	}
}

@onready var WeaponAnimator = $WeaponAnimator

signal ammo_changed(current_capacity: int, capacity: int)
signal weapon_changed(current_weapon: String)
#signal weapon_changed(currentWeapon: String)

func _ready() -> void:
	
	Loadout = ["92FSX", "SPS-7"]
	current_weapon = Loadout[0] # Allways equips the first weapon in the loadout
	current_capacity = WEAPONS[current_weapon]["capacity"] # Set the ammo count to the max count
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	# Small delay to allow the GUI element to be instantiated
	await get_tree().create_timer(0.1).timeout
	
	weapon_changed.emit(current_weapon)
	ammo_changed.emit(current_capacity, capacity)
	

func Swap_Weapon(Weapon_Name: String) -> void:
	#if current_weapon == Weapon_Name:
		#return
	
	weapon_changed.emit(Weapon_Name)
	
	WeaponAnimator.play("%s_Idle" % current_weapon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Swapped to is_action_pressed to allow holding down button to fire
	if Input.is_action_pressed("Combat_Attack") && Canfire && current_capacity > 0:
		Attack()
	
	# Reload if the player Can fire (Not mid animation) and if the weapon is not fully loaded
	if Input.is_action_just_pressed("Combat_Reload") && Canfire && current_capacity < WEAPONS[current_weapon]["capacity"]:
		Reload()
		
	if Input.is_action_just_pressed("Combat_Swapweapon"):
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
	
	# Spawning bullet
	
	var weapon_data = WEAPONS[current_weapon]
		
	var projectile_scene: PackedScene = weapon_data["projectile"]
	var projectile = projectile_scene.instantiate()

	projectile.global_position = $BulletOrigin.global_position
	projectile.global_rotation = $BulletOrigin.global_rotation

	get_tree().current_scene.add_child(projectile)

	await get_tree().create_timer(weapon_data["fire_rate"]).timeout

	Canfire = true
	
	# Animation variations
	
	if current_capacity > 0:
		WeaponAnimator.play("%s_Idle" % current_weapon)
	else:
		WeaponAnimator.play("%s_Idle_Empty" % current_weapon)
	
	# Signal and update UI with new data
	
	ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
	
func Reload():
	
	Canfire = false
	
	if current_capacity > 1: # Retention reload
		WeaponAnimator.play("%s_Reload_Retention" % current_weapon)
	elif current_capacity == 1: # Empty reload with a bullet in the chamber
		WeaponAnimator.play("%s_Reload_Emmergency" % current_weapon)
	elif current_capacity == 0: # Empty reload
		WeaponAnimator.play("%s_Reload_Empty" % current_weapon)
	else:
		pass
	
	await get_tree().create_timer(2).timeout
	
	current_capacity = WEAPONS[current_weapon]["capacity"]
	
	# Signal and update UI with new data
	
	ammo_changed.emit(current_capacity, WEAPONS[current_weapon]["capacity"])
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	Canfire = true
		
		
