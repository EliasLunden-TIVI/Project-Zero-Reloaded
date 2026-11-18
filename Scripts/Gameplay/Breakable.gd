extends Area2D

@export_category("Prop Information")

@export var Prop_Name: String # The tracked name of the object
@export var Health: int # How much damage the object can take before breaking

# Node connections #

@onready var PropTexture = $PropTexture
@onready var Animator = $PropAnimator
@onready var Particles = $PropParticles
@onready var Audio = $PropSFX

@onready var Broken: bool = false

@onready var NavMesh = $"../../LevelNavigation"

var Breakable_Type: String

func _ready() -> void:
	
	# Sort prop type #
	
	if self.is_in_group("Wall"):
		Breakable_Type = "Wall"
	else:
		Breakable_Type = "Prop"
	
	print_debug(Breakable_Type)
	
	## OBSELETE DUE TO AUTOPLAY FUNCTION ##
	#Animator.play("%s_Idle" % Prop_Name[0])

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
		
		if Health <= 0 && Broken == false:
			Break()
		else:
			Particles.emitting = true

			Particles.emitting = false
	else:
		pass
	
# Activate breaking animation
func Break():
	if Breakable_Type == "Prop":
		Audio.pitch_scale = randf_range(0.8, 1.2)
		Animator.play("%s_Break" % Prop_Name)
		Broken = true
	
	elif Breakable_Type == "Wall":

		Audio.pitch_scale = randf_range(0.8, 1.2)
		$LightOccluder2D.visible = false
		Animator.play("%s_Break" % Prop_Name)
		
		Broken = true
		
		await get_tree().create_timer(15).timeout
		
		queue_free()
		
		# Update navigation
		#NavMesh.bake_navigation_polygon()
