extends Control

@onready var MainMenu = load("res://Scenes/Game/Mainmenu.tscn")

var CurrentLevel

@onready var WeaponName = $"WeaponPanel/Weapon-Name-Card/Weapon-Name"
@onready var WeaponAmmo = $"WeaponPanel/Weapon-Ammo-Card/Weapon-Ammo"
@onready var WeaponImage = $"WeaponPanel/Weapon-Image-Card/Weapon-Image"

@onready var Animator = $AnimationPlayer

@onready var weapon_manager = get_node("../../Player/WeaponManager")
@onready var player_manager = get_node("../../Player")
@onready var game_manager = get_node("../../")

@onready var DeathGUI = load("res://Resources/GUI/DeathScreen.tscn")
#@onready var GameEnd_GUI = load("")

@onready var WeaponPanel = $WeaponPanel
@onready var PausePanel = $PausePanel
#@onready var ScorePanel = $ScorePanel

var Paused: bool = false

var Completion_Time: float
var Performance_Score: int
var Performance_Grade: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Animator.play("Bootup")
	
	PausePanel.hide()
	#ScorePanel.hide()
	
	# CONNECT SIGNALS #
	
	game_manager.Game_End.connect(_game_end)
	weapon_manager.ammo_changed.connect(_on_ammo_changed)
	weapon_manager.weapon_changed.connect(_on_weapon_changed)
	player_manager.health_changed.connect(_on_health_changed)



func _input(event) -> void:	
	if event.is_action_pressed("GUI_Pause"):
		pause()

# PAUSE TOGGLE FUNCTION #

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
		WeaponAmmo.text = "▬▬▬▬▬"
		WeaponAmmo.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	elif ammo_percent >= 0.8:
		WeaponAmmo.text = "▬▬▬▬▭"
		WeaponAmmo.add_theme_color_override("font_color", Color(1.0, 1.0, 0.608, 1.0))
	elif ammo_percent >= 0.6: 
		WeaponAmmo.text = "▬▬▬▭▭"
		WeaponAmmo.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0, 1.0))
	elif ammo_percent >= 0.4: 
		WeaponAmmo.text = "▬▬▭▭▭"
		WeaponAmmo.add_theme_color_override("font_color", Color(1.0, 0.333, 0.0, 1.0))
	elif ammo_percent >= 0.2:
		WeaponAmmo.text = "▬▭▭▭▭"
		WeaponAmmo.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))
	elif ammo_percent <= 0:
		WeaponAmmo.text = "▭▭▭▭▭"
		WeaponAmmo.add_theme_color_override("font_color", Color(0.608, 0.0, 0.0, 1.0))
	else:
		#print_debug("ERROR: Ammo_percent out of range")
		pass

func _on_weapon_changed(current_weapon: String):
	
	#DEBUG feature
	#print_debug(current_weapon)
	
	var weapon_path = "res://Textures/Weapons/ICONS/%s_Icon.png" % current_weapon
	var weapon_texture = load(weapon_path)
	
	WeaponImage.texture = weapon_texture
	
	WeaponName.text = str(current_weapon)
	

func _on_health_changed(Health: int, MaxHealth: int):
	
	if Health > 75:
		$HealthOverlay.texture = load("res://Textures/GUI/HUD/Blank.png")
	elif Health <= 75 && Health > 50:
		$HealthOverlay.texture = load("res://Textures/GUI/HUD/HealthOverlay4.png")
	elif Health <= 50 && Health > 25:
		$HealthOverlay.texture = load("res://Textures/GUI/HUD/HealthOverlay5.png")
	elif Health <= 25 && Health > 0:
		$HealthOverlay.texture = load("res://Textures/GUI/HUD/HealthOverlay6.png")
	elif Health <= 0:
		# Spawns Death GUI on death
		var deathgui = DeathGUI.instantiate()
		
		get_tree().current_scene.add_child(deathgui)


func _on_pausemenu_quit_button_down() -> void:
	get_tree().change_scene_to_packed(MainMenu)

func _on_pausemenu_continue_button_down() -> void:
	pause()
	
func _on_restart_button_button_down() -> void:
	# Restarts current scene #
	get_tree().reload_current_scene()
	
func _game_end(levelname, time, score, grade):
	
	Animator.play("Exit")
	
	await get_tree().create_timer(6).timeout
	
	Animator.play("PerformanceReport")
	
	$"BlackScreen/BlackScreenText".text = """// SUBJECT PERFORMANCE REPORT - %s //
	
	> COMPLETION TIME - %s
	
	> OPERATION PERFORMANCE SCORE - %s
	
	> OPERATION PERFORMANCE RANK - %s""" % [str(levelname), (time), str(score), str(grade)]
	
	
	


func _on_restart_button_down() -> void:
	# Restarts current scene #
	get_tree().reload_current_scene()


func _on_exit_button_down() -> void:
	Animator.play("FadeOut")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_packed(MainMenu)
