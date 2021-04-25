extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Player_astern():
	# engine quiets
	if !self.playing:
		self.play(0.0)
	var level = 33
	var vol = 100 - ( level - 10 ) * ( 100 / 15 )
	self.volume_db = ( -10 * vol / 100 ) - 7
	self.pitch_scale = 0.75

func _on_Player_stop():
	# engine off
	if self.playing:
		self.stop()

func _on_Player_ahead_slow():
	# engine quiets
	if !self.playing:
		self.play(0.0)
	var level = 33
	var vol = 100 - ( level - 10 ) * ( 100 / 15 )
	self.volume_db = ( -10 * vol / 100 ) - 7
	self.pitch_scale = 0.75

func _on_Player_ahead_fast():
	# engine quiets
	if !self.playing:
		self.play(0.0)
	var level = 66
	var speed = ( level - 25 ) * ( 100 / 75 )
	self.volume_db = -7
	self.pitch_scale = 0.75 + ( 0.75 * speed / 100 )

func _on_Player_ahead_flank():
	var level = 100
	var speed = ( level - 25 ) * ( 100 / 75 )
	self.volume_db = -7
	self.pitch_scale = 0.75 + ( 0.75 * speed / 100 )
