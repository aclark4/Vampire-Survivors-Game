extends Area2D
# I am hitting you (aggressive)

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

func tempdisable():
	collision.call_deferred("set", "disabled", true) #This sets the collision shape to be disabled, and will no longer collide with things
	disableTimer.start()


func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set", "disabled", false)
