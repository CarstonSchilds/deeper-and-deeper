extends AnimatedSprite

onready var swim_controller = $"../../SwimController"

func _on_Brain_state_changed(current_state):
	var name = current_state.state_name()
	if name == "natural_behaviour" or name == "return_home" or name == "rest":
		self.animation = "idle"
		swim_controller.rotation_offset = 0
	if name == "pursue" or name == "attack":
		self.animation = "start_swim"
		swim_controller.rotation_offset = PI/2

func _on_AnimatedSprite_animation_finished():
	if self.animation == "start_swim":
		self.animation = "swim";
