extends "res://entities/enemies/Brain.gd"

func _init():
	self.sonar_sensitive = true
	self.normal_patrol_time = 2.0
	self.leash_range = 250
	$"States/Rest/Timer".wait_time = 3.5
