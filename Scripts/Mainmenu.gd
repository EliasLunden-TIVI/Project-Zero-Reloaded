extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelSelectWindow.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_scene_1_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Testing/Testing.tscn") # Testing scene


func _on_command_button_down() -> void:
	$LevelSelectWindow.show()
	
func _on_command_shortcut_button_down() -> void:
	$LevelSelectWindow.show()


func _on_level_select_window_close_requested() -> void:
	$LevelSelectWindow.hide()
