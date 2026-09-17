extends Control


@onready var WeaponName = $"Weapon-Panel/Weapon-Name-Card/Weapon-Name"
@onready var WeaponAmmo = $"Weapon-Panel/Weapon-Ammo-Card/Weapon-Ammo"
@onready var WeaponImage = $"Weapon-Panel/Weapon-Image-Card/Weapon-Image"

@onready var weapon_manager = get_node("../../Player/WeaponManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	weapon_manager.ammo_changed.connect(_on_ammo_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### AMMO COUNTER SYSTEM ###
func _on_ammo_changed(current_capacity: int, capacity: int):
	var ammo_percent = (float(current_capacity) / capacity) 
	
	# DEBUG feature
	#print_debug(ammo_percent , current_capacity , capacity)
	
	if ammo_percent >= 1: 
		WeaponAmmo.text = "OOOOO"
	elif ammo_percent >= 0.8:
		WeaponAmmo.text = "OOOOX"
	elif ammo_percent >= 0.6: 
		WeaponAmmo.text = "OOOXX"
	elif ammo_percent >= 0.4: 
		WeaponAmmo.text = "OOXXX"
	elif ammo_percent >= 0.2:
		WeaponAmmo.text = "OXXXX"
	elif ammo_percent <= 0:
		WeaponAmmo.text = "XXXXX"
	else:
		print_debug("ERROR: Ammo_percent out of range")
	
