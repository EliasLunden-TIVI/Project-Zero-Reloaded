extends Sprite2D

@export_category("VFX Properties")

# How long the VFX lasts before being removed #

@export var Lifetime: int

# How many VFX textures are in the texture sheet #

@export var TextureRange: int

func _ready() -> void:
	# Set texture to a random texture in range #
	self.frame = randi_range(0, TextureRange)
	
	await get_tree().create_timer(Lifetime).timeout
	
	queue_free()

	# NOTE #
	# All movement and spawning velocity ETC are managed trough the spawning system
