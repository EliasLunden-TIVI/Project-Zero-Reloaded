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

#func _ready() -> void:
	#pass
	
func _on_end_trigger_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		
		CompletionTime = "N/A"
		
		CompletionScore = CurrentScore
		
		CompletionGrade = "N/A"
		
		Game_End.emit(Level_Name, CompletionTime, CompletionScore, CompletionGrade)
		
		#await get_tree().create_timer(5).timeout
		#get_tree().change_scene_to_file("res://Scenes/Game/Mainmenu.tscn")
		
var ReportedTransforms: Dictionary = {}

var CheckedNodes = {}

func _physics_process(_delta: float) -> void:

	for node in get_tree().current_scene.find_children("*", "Node2D", true, false):

		var local_det = node.transform.determinant()
		var global_det = node.global_transform.determinant()

		if absf(local_det) < 0.000001 or absf(global_det) < 0.000001:

			var path = str(node.get_path())

			if !CheckedNodes.has(path):

				CheckedNodes[path] = true

				print("SINGULAR TRANSFORM DETECTED!")
				print("Node: ", path)
				print("Local Transform: ", node.transform)
				print("Global Transform: ", node.global_transform)
				print("Local Determinant: ", local_det)
				print("Global Determinant: ", global_det)
				print("---------------------------")
