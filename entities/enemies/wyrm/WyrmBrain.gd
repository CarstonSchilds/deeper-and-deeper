extends "res://entities/enemies/Brain.gd"

func _init():
	self.sonar_sensitive = true
	self.light_sensitive = true
	self.normal_patrol_time = 4.0
	self.leash_range = 750
	$"States/Rest/Timer".wait_time = 1.5
	$"States/Pursue/Timer".wait_time = 5.0
