extends AudioStreamPlayer2D

func _on_Brain_state_changed(current_state):
	var name = current_state.get_class()
	if name == "pursue":
		if !self.playing:
			self.play()
