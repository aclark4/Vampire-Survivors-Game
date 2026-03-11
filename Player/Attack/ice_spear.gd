extends Area2D

var level = 1
var hp = 1 # Determines how many enemies the Spear can pass through before breaking
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("Player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:  # base level
			hp = 1
			speed = 100
			damage = 5
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		2: # hp upgrade +3 damage
			hp = 3
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		3: # Multiple ice spear Upgrade
			hp = 3
			speed = 100
			damage = 8
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		4: # speed upgrade
			hp = 3
			speed = 135
			damage = 8
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		5: # size upgrade + 4 damage
			hp = 3
			speed = 100
			damage = 12
			knockback_amount = 100
			attack_size = 1.5 * (1 + player.spell_size)
		6: # knockback upgrade, + 2 more ice spears
			hp = 3
			speed = 100
			damage = 12
			knockback_amount = 150
			attack_size = 1.5 * (1 + player.spell_size)
			
	var tween = create_tween() #setparallel(true) for same time animations
	tween.tween_property(self, "scale", Vector2(1,1)*attack_size,1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Tween is a animation. The parameters are node to alter, name of attribute, end result of the property, and time for it to complete.
	# Tween can change the color of things w teen property(self, modulate, color(would need to look up), 
	tween.play()
			
func _physics_process(delta: float):
	position += angle*speed*delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0: #This will destroy the spear when it has a 0 hp
		queue_free()
			


func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()
