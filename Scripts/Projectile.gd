extends Node2D

# How much damage the projectile deals to objects and enemies
var Damage: int 
# How fast the projectile moves
var Velocity: int 
# How far a projectile penetrates walls and armor
var Penetration: int
# How many projectiles are fired in a single shot
var ProjectileCount: int
# How long before the projectile is deleted
var Lifetime: int = 3

var Caliber: String

var Direction: Vector2

var BloodHitAssets = load("res://VFX/Gore/BloodSplatter/VFX_Bloodsplatter.tscn")

# DATASHEET FOR ALL CALIBERS

const CALIBERS = {
	"9x19mm": {
		"damage": 25,
		"velocity": 150,
		"penetration": 2,
		"projectilecount": 1
	},
	
	"4.6x30mm": {
		"damage": 20,
		"velocity": 250,
		"penetration": 3,
		"projectilecount": 1
	}
}

func _ready() -> void:
	# Currently a testing system. Will be replaced by a dynamic "Caliber" variable trough Weaponmanager.gd
	Instantiate("9x19mm")
	
func Instantiate(Caliber):
	# Feeding Caliber data to new bullet
	Direction = Vector2.RIGHT.rotated(global_rotation)
					
	Damage = CALIBERS[Caliber]["damage"]
	Velocity = CALIBERS[Caliber]["velocity"]
	Penetration = CALIBERS[Caliber]["penetration"]
	ProjectileCount = CALIBERS[Caliber]["projectilecount"]
	
	# Projectile lifetime culling
	await get_tree().create_timer(Lifetime).timeout
	queue_free()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	# Move the projectile forward according to its Velocity stat
	position += Direction.normalized() * Velocity

# Send damage and penetration stats to the target object
func Get_Damage() -> int:
	return Damage
	

# Hit Effects & Penetration #

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Humanoid"):
		var Effect = BloodHitAssets.instantiate()	
		Effect.global_position = $"Projectile_Texture".global_position
		Effect.global_rotation = $"Projectile_Texture".global_rotation
		
		get_tree().current_scene.add_child(Effect)
	
		print_debug("Hit effect spawned")

# Limiting wall penetration with penetration stat #
	#elif area.is_in_group("Wall"):
		#if Penetration >= 1:
			#Penetration = Penetration - 1
		#elif Penetration <= 0:
			#queue_free()
		
	
