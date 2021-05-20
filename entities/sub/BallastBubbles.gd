extends Particles2D


func _on_Player_show_damage():
	pass

func _on_BuoyancyInputController_buoyancy_down():
	self.emitting = true
