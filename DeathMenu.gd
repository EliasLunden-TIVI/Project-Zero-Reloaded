extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Intro")
	await get_tree().create_timer(9).timeout
	$AnimationPlayer.play("Loop")
	


func _on_reload_save_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Testing/Testing.tscn")


func _on_main_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game/Mainmenu.tscn")
