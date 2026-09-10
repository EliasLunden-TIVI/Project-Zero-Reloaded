extends Node2D

# How fast the projectile moves
var Velocity: int = 5
# How much damage the projectile deals to objects and enemies
var Damage: int = 15
# How far a projectile penetrates walls and armor
var Penetration: int = 2
# How many projectiles are fired in a single shot
var ProjectileAmount: int = 1
# How long before the projectile is deleted
var Lifetime: int = 5

var Direction: Vector2

func _ready() -> void:

	Direction = Vector2.RIGHT.rotated(global_rotation)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the projectile forward according to its Velocity stat
	position += Direction.normalized() * Velocity
	
