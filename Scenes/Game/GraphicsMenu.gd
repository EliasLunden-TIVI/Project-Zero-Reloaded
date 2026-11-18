extends Control

func _on_displaymode_item_selected(index: int) -> void:

	# All supported displaymodes
	
	var modes = [
		Window.MODE_FULLSCREEN,
		Window.MODE_EXCLUSIVE_FULLSCREEN,
		Window.MODE_WINDOWED,
		Window.MODE_MAXIMIZED
	]

	if index >= 0 && index < modes.size():
		get_window().mode = modes[index]
	else:
		print_debug("Index out of range")
		
		
# Saved settings tweaks here when I get to it
