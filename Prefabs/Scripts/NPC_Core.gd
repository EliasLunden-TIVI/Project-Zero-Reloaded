extends CharacterBody2D

var Health: int
var Armor: int

var Torso_Armor: int
var Head_Armor: int

var Alive: bool

var CorpseRemovalDelay: float = 15

var EnemyName: String

@onready var Animator = $NPC_Animator

func _ready() -> void:
	
	# Get the first group name to be set as the name and "ID" of the enemy.
	EnemyName = get_groups()[0]
	
	Health = 100
	Alive = true

# When something enter the collision area
func _on_npc_hurtbox_torso_area_entered(area: Area2D) -> void:
	if area.is_in_group("Projectile"):
		if area.has_method("Get_Damage"):
			# GET DAMAGE FROM PROJECTILE
			var Damage: int = area.Get_Damage()
			Take_Damage(Damage)
	

func Take_Damage(Damage):
	if Alive == true:
		Health =- Damage
		
		if Health <= 0:
			Die()
	
func Die():
	Alive = false
	print_debug("NPC Killed")
	
	Animator.play("NPC_%s_Death" % EnemyName)
	await get_tree().create_timer(CorpseRemovalDelay).timeout
	queue_free()
