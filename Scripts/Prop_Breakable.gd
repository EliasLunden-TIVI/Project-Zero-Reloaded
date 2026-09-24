extends Area2D

# Shared health for ALL props
var Health: int = 15

@onready var PropTexture = $PropTexture
@onready var Animator = $PropAnimator
@onready var Collision = $CollisionShape2D
@onready var Particles = $PropParticles
@onready var Audio = $PropSFX

@onready var PropName = get_groups()

@onready var Broken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Animator.play("%s_Idle" % PropName[0])

# When something enter the collision area
func _on_area_entered(area: Area2D) -> void:

	if area.is_in_group("Projectile"):
		if area.has_method("Get_Damage"):
			# GET DAMAGE FROM PROJECTILE
			var Damage: int = area.Get_Damage()
			Take_Damage(Damage)

func Take_Damage(Damage):
	if Broken != true:
		Health =- Damage
		
		# Check if prop is broken ( Health = 0 )
		if Health <= 0 && Broken == false:
			Break()
		else:
			Particles.emitting = true
			# Reseting particles for Oneshot to work
			Particles.emitting = false
			
	
# Activate breaking animation
func Break():
	Animator.play("%s_Break" % PropName[0])
	Broken = true
