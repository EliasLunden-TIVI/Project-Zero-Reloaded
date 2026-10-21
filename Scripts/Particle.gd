extends GPUParticles2D



func _ready() -> void:
	$".".emitting = true
	await get_tree().create_timer(15).timeout
	queue_free()
