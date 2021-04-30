extends Particles2D

func _on_Player_buoyancy_down():
	self.emitting = true


func _on_Player_show_damage():
	self.emitting = true
