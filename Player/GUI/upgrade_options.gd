extends VBoxContainer


signal click_end()


func _on_mouse_entered() -> void:
	mouse_over = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	$snd_hover.play()
	
func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
