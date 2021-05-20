extends AudioStreamPlayer2D

func _on_Brain_state_changed(current_state):
	var name = current_state.state_name()
	if name == "pursue" or name == "attack":
		if !self.playing:
			self.play()
