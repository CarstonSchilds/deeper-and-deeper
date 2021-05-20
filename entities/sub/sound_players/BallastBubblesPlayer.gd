extends AudioStreamPlayer

func _on_BuoyancyInputController_buoyancy_down():
	if !self.playing:
		self.play()
