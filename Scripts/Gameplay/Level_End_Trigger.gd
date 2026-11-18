extends Area2D

signal End_Level


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		End_Level.emit()
