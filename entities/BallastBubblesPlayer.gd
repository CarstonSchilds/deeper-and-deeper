extends AudioStreamPlayer


func _on_Player_buoyancy_down():
	if !self.playing:
		self.play()
