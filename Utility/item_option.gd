extends ColorRect

@onready var lblName = $lbl_name
@onready var lblDescription = $lbl_description
@onready var lblLevel = $lbl_level
@onready var itemIcon = $ColorRect/ItemIcon

var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("Player")

signal selected_upgrade(upgrade)
signal clicked()

func _ready(): # When an item option is created
	pivot_offset = custom_minimum_size / 2
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == null: # sets food to the default item if nothing is loading in
		item = "food"
	lblName.text = UpgradeDb.UPGRADES[item]["displayname"] # The item references what dictionary to check, then displayname is an individual attribute within that
	lblDescription.text = UpgradeDb.UPGRADES[item]["details"]
	lblLevel.text = UpgradeDb.UPGRADES[item]["level"]
	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])
	
func _input(event):
	if event.is_action("click"): # Will be true if player just clicked
		if mouse_over:
			$snd_click.play()

func _on_mouse_entered() -> void:
	$snd_hover.play()
	mouse_over = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited() -> void:
	mouse_over = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)


func _on_snd_click_finished() -> void:
	emit_signal("selected_upgrade", item)
