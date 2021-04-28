extends "res://entities/enemies/Brain.gd"

func _init():
	self.light_sensitive = true
	self.no_patrol = true
	self.normal_patrol_time = 5.0
	self.leash_range = 500
	$"States/Rest/Timer".wait_time = 3
