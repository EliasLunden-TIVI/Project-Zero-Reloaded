extends Node2D

@export_category("Core information")

@export var Level_Name: String

@export var Level_End_Enabled: bool

@export var Player_Spawn: Node2D

@export_category("Player Systems")

@export_category("Scoring criteria")

var CurrentScore = "N/A"

var CompletionTime

var CompletionScore

var CompletionGrade

var LevelTime

signal Game_End(Level_Name: String, CompletionTime: float, CompletionScore: int, CompletionGrade: String)

func _ready() -> void:
	pass
	
func _on_end_trigger_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		
		CompletionTime = "N/A"
		
		CompletionScore = CurrentScore
		
		CompletionGrade = "N/A"
		
		Game_End.emit(Level_Name, CompletionTime, CompletionScore, CompletionGrade)
		
		#await get_tree().create_timer(5).timeout
		#get_tree().change_scene_to_file("res://Scenes/Game/Mainmenu.tscn")
		
