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

# DATASHEET FOR ALL CALIBERS

const CALIBERS = {
	"9x19mm": {
		"damage": 15,
		"velocity": 15,
		"penetration": 2,
		"projectilecount": 1
	},
	
	"45ACP": {
		"damage": 15,
		"velocity": 30,
		"penetration": 2,
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
func _process(_delta) -> void:
	# Move the projectile forward according to its Velocity stat
	position += Direction.normalized() * Velocity

# Send damage and penetration stats to the target object
func Get_Damage() -> int:
	return Damage
