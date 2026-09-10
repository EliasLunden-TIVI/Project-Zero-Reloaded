extends Node2D

var Canfire: bool = true
var Remmainingammo: int
var Firedelay: float = 0.1

var Loadout: Array = ["92FSX"]

var Projectile = load("res://Resources/Weapons/Projectiles/Projectile_9x19.tscn")

@onready var WeaponAnimator = $WeaponAnimator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	WeaponAnimator.play("92FSX_Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Combat_Attack") && Canfire == true:
		WeaponAnimator.play("92FSX-Attack")
		Canfire == false
		var projectile = Projectile.instantiate()
		var base_direction = (get_global_mouse_position() - $BulletOrigin.global_position).normalized()
		
		projectile.global_position = $BulletOrigin.global_position
		projectile.global_rotation = $BulletOrigin.global_rotation
		
		get_tree().current_scene.add_child(projectile)

		await get_tree().create_timer(Firedelay).timeout
		Canfire == true
		
		WeaponAnimator.play("92FSX_Idle")
		
		
