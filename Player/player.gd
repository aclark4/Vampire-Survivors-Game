extends CharacterBody2D

var hp = 80
var movement_speed = 40.0
var last_movement = Vector2.UP

var experience = 0
var experience_level = 1
var collected_experience = 0

#ATTACKS
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

#ATTACK NODES
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#Ice Spear
var icespear_ammo = 0
var icespear_baseammo = 1 # Could increase number of spears shot in a single burst
var icespear_attackspeed = 1.5
var icespear_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 1 # Could increase number of spears shot in a single burst
var tornado_attackspeed = 3
var tornado_level = 0

#Javelin
var javelin_ammo = 1
var javelin_level = 1

#Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lbllevel = get_node("%lbl_level")

func _ready():
	attack()
	set_expbar(experience, calculate_experiencecap())
	
func _physics_process(delta): # This runs every 1/60th of a second. Delta controls that I believe.
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left") # Pretty much determines if you are only holding one of the buttons or not
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov) # This is literally just a direction
	if mov.x > 0: # Determines what direction you are moving in.
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	
	if mov != Vector2.ZERO: #means there is movement
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes -1:
				sprite.frame = 0 # These are the indiv setting of the frame
			else:
				sprite.frame += 1
			walkTimer.start()
	
	velocity = mov.normalized()*movement_speed #Makes the player always go in the same speed (movementspeed per movement function run
	move_and_slide()  #GODOT FUNCTION. ALLOWS THE CHARACTER TO MOVE


func _on_hurt_box_hurt(damage: Variant, _angle, _knockback) -> void:
	hp -= damage
	if hp <= 0:
		print("DEAD")
		
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped(): # This means it just shot.
			iceSpearTimer.start() #
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped(): # This means it just shot.
			tornadoTimer.start() #
	if javelin_level > 0:
		spawn_javelin()

func _on_ice_spear_timer_timeout() -> void:
	icespear_ammo += icespear_baseammo #This is loading the ammo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout() -> void: #This is like shooting the machine gun!
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornando_timer_timeout() -> void:
	tornado_ammo += tornado_baseammo #This is loading the ammo
	tornadoAttackTimer.start()


func _on_tornado_attack_timer_timeout() -> void:
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if  tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()
			
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = javelin_ammo - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1

	
func get_random_target():
	if enemy_close.size() > 0: #Checks array
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if not enemy_close.has(body): # Adds close body to the array that stores close enemies
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"): # Checks if the thing you just got close to is loot
		area.target = self # If it is loot, set it to target(zoom towards) you


func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect() #If you touch the gem of experience, collect it
		calculate_experience(gem_exp)
		
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if (experience + collected_experience) >= exp_required: # This means you have enough exp to level up
		collected_experience -= exp_required  # removes the current level req experience (ready to level up now)
		experience_level += 1
		lbllevel.text = str("Level: ", experience_level)
		exp_required = calculate_experiencecap()
		calculate_experience(0) # This allows for the remaining collected experience to be used
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)
	
func calculate_experiencecap(): # gives the experience currently required
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 * (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39) *12
	return exp_cap
	
	
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
