extends Area2D

var level: int = 1
var hp: int = 1 # Determines how many enemies the fireball can pass through before breaking
var speed: int = 150
var damage: int = 3
var knockback_amount: int = 100
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("Player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	match level:
		1:  # base level
			hp = 1
			speed = 150
			damage = 3
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		2: # hp upgrade +3 damage
			hp = 3
			speed = 150
			damage = 6
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		3: # Multiple fireballs
			hp = 3
			speed = 150
			damage = 6
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		4: # speed upgrade + fireball
			hp = 3
			speed = 200
			damage = 6
			knockback_amount = 100
			attack_size = 1 * (1 + player.spell_size)
		5: # size upgrade + 4 damage + 1 more fireball
			hp = 6
			speed = 180
			damage = 10
			knockback_amount = 125
			attack_size = 2 * (1 + player.spell_size)
			
	var tween: Tween = create_tween() #setparallel(true) for same time animations
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
