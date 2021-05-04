extends AnimatedSprite

func _on_Brain_state_changed(current_state):
	var name = current_state.get_class()
	if name == "natural_behaviour" or name == "return_home" or name == "rest":
		self.animation = "idle"
		self.rotation = 0
	if name == "pursue" or name == "attack":
		self.animation = "start_move"
		self.rotation = PI/2

func _on_AnimatedSprite_animation_finished():
	if self.animation == "start_move":
		self.animation = "moving";

