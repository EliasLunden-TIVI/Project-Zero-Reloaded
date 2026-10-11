extends Control


@onready var MainMenu = preload("res://Scenes/Game/Mainmenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MainMenuAnimator.play("Intro")
	await get_tree().create_timer(20.1).timeout
	
	# Go to main menu after animation is played
	
	get_tree().change_scene_to_packed(MainMenu)

func _on_skip_button_down() -> void:
	# Skip animation and go to mainmenu
	get_tree().change_scene_to_packed(MainMenu)
