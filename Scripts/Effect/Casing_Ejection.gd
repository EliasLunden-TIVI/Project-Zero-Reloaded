extends RigidBody2D

@export_category("Settings")

@export var Lifetime: float
@export var Speed: float

func _ready() -> void:
	
	rotate(randf_range(169.5, 170.5))
	angular_velocity = randi_range(15, 50)
	
	await get_tree().create_timer(Lifetime).timeout
	queue_free()
