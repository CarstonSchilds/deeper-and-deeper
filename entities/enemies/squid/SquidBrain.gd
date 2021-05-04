extends "res://entities/enemies/Brain.gd"

func _init():
	self.light_sensitive = true
	self.no_patrol = true
	self.normal_patrol_time = 5.0
	self.leash_range = 750
	$"States/Rest/Timer".wait_time = 1.4
	$"States/Pursue/Timer".wait_time = 4.5
