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

func _ready() -> void:
	
	Loadout = ["92FSX", "SPS-7"]
	current_weapon = Loadout[0] # Allways equips the first weapon in the loadout
	current_capacity = WEAPONS[current_weapon]["capacity"]
	
	WeaponAnimator.play("%s_Idle" % current_weapon)
	

func swap_weapon(Weapon_Name: String) -> void:
	if current_weapon == Weapon_Name:
		return
	
	current_weapon = Weapon_Name
	
	WeaponAnimator.play("%s_Idle" % current_weapon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Combat_Attack") && Canfire && current_capacity > 0:
		Attack()
	
	if Input.is_action_just_pressed("Combat_Reload"):
		Reload()
		

func Attack():
	Canfire = false
	
	if current_capacity > 1:
		WeaponAnimator.play("%s_Attack" % current_weapon)
	elif current_capacity == 1:
		WeaponAnimator.play("%s_Attack_Empty" % current_weapon)
		
	current_capacity -= 1
		
	var weapon_data = WEAPONS[current_weapon]
		
	var projectile_scene: PackedScene = weapon_data["projectile"]
	var projectile = projectile_scene.instantiate()

	projectile.global_position = $BulletOrigin.global_position
	projectile.global_rotation = $BulletOrigin.global_rotation

	get_tree().current_scene.add_child(projectile)

	await get_tree().create_timer(weapon_data["fire_rate"]).timeout

	Canfire = true
	
	if current_capacity > 0:
		WeaponAnimator.play("%s_Idle" % current_weapon)
	else:
		WeaponAnimator.play("%s_Idle_Empty" % current_weapon)
	
func Reload():
	
	Canfire = false
	
	if current_capacity > 1: # Retention reload
		WeaponAnimator.play("%s_Reload_Retention" % current_weapon)
	elif current_capacity == 1: # Empty reload with a bullet in the chamber
		WeaponAnimator.play("%s_Reload_Emmergency" % current_weapon)
	elif current_capacity == 0: # Empty reload
		WeaponAnimator.play("%s_Reload_Empty" % current_weapon)
	
	current_capacity = WEAPONS[current_weapon]["capacity"]
		
	WeaponAnimator.play("%s_Idle" % current_weapon)
	
	Canfire = true
		
		
