extends Control


@onready var WeaponName = $"Weapon-Panel/Weapon-Name-Card/Weapon-Name"
@onready var WeaponAmmo = $"Weapon-Panel/Weapon-Ammo-Card/Weapon-Ammo"
@onready var WeaponImage = $"Weapon-Panel/Weapon-Image-Card/Weapon-Image"

@onready var weapon_manager = get_node("../../Player/WeaponManager")

var Paused: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$"Pause-Panel".hide()
	
	weapon_manager.ammo_changed.connect(_on_ammo_changed)
	weapon_manager.weapon_changed.connect(_on_weapon_changed)


func _input(event) -> void:	
	if event.is_action_pressed("GUI_Pause"):
		pause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func pause():
	if Paused == true:
		$"Pause-Panel".hide()
		Paused = false
	elif Paused == false:
		$"Pause-Panel".show()
		Paused = true

	


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

func _on_weapon_changed(current_weapon: String):
	
	#DEBUG feature
	#print_debug(current_weapon)
	
	var weapon_path = "res://Textures/Weapons/%s/GUI/%s.png" % [current_weapon, current_weapon]
	var weapon_texture = load(weapon_path)
	
	WeaponImage.texture = weapon_texture
	
	WeaponName.text = str(current_weapon)
	


func _on_quit_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game/Mainmenu.tscn")


func _on_continue_button_down() -> void:
	pause()
