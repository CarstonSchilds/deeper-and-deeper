extends Particles2D


func _on_Player_ahead_flank():
	self.emitting = true

func _on_Player_ahead_fast():
	self.emitting = true

func _on_Player_ahead_slow():
	self.emitting = false

func _on_Player_stop():
	self.emitting = false

func _on_Player_astern():
	self.emitting = false
