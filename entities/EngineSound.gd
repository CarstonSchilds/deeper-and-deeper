extends AudioStreamPlayer2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_engine_level(level : float):
	level = abs(level)
	if level < 10:
		# 0 - 10
		# engine off
		if !self.playing:
			self.stop()

	elif level < 25:
		# 10 - 25
		# engine quiets
		if !self.playing:
			self.play(0.0)
		var vol = 100 - ( level - 10 ) * ( 100 / 15 )
		self.volume_db = ( -10 * vol / 100 ) - 7
		self.pitch_scale = 0.75

	else:
		# 10 - 25
		# engine speeds up / down
		if !self.playing:
			self.play(0.0)
		var speed = ( level - 25 ) * ( 100 / 75 )
		self.volume_db = -7
		self.pitch_scale = 0.75 + ( 1.25 * speed / 100 )

