extends Node

var brain = null

signal finished(next_state_name)

func enter(brain):
	self.brain = brain

func exit(brain):
	self.brain = null

func update(delta):
	return
