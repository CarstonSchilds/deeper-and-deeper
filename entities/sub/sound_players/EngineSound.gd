extends AudioStreamPlayer2D

func _on_ThrottleInputController_throttle_change(level):
	
	var absolute_level = abs(level)

	if absolute_level < 10:
		# engine off
		if self.playing:
			self.stop()

	elif absolute_level < 50:
		# engine quiets
		if !self.playing:
			self.play(0.0)
		var vol = 100 - ( absolute_level - 10 ) * ( 100 / 15 )
		self.volume_db = ( -10 * vol / 100 ) - 7
		self.pitch_scale = 0.75

	elif absolute_level < 75:
		# engine louder
		if !self.playing:
			self.play(0.0)
		var speed = ( absolute_level - 25 ) * ( 100 / 75 )
		self.volume_db = -7
		self.pitch_scale = 0.75 + ( 0.75 * speed / 100 )

	else:
		# engine loudest
		var speed = ( absolute_level - 25 ) * ( 100 / 75 )
		self.volume_db = -3
		self.pitch_scale = 0.75 + ( 0.75 * speed / 100 )
