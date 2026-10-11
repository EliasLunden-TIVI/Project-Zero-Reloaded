extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LevelSelectWindow.hide()
	$SettingsWindow.hide()
	$ErrorPopup.hide()
	


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

# SETTINGS

func _on_settings_button_down() -> void:
	$SettingsWindow.show()

func _on_settings_shortcut_button_down() -> void:
	$SettingsWindow.show()

func _on_settings_window_close_requested() -> void:
	$SettingsWindow.hide()

# FILES

func _on_files_button_down() -> void:
	$ErrorPopup.show()

func _on_files_shortcut_button_down() -> void:
	$ErrorPopup.show()

# DATABASE

func _on_database_button_down() -> void:
	$ErrorPopup.show()

func _on_database_shortcut_button_down() -> void:
	$ErrorPopup.show()

# ERROR POPUP 

func _on_error_popup_close_requested() -> void:
	$ErrorPopup.hide()


func _on_button_button_down() -> void:
	$ErrorPopup.hide()
