extends Node

onready var parent = $".."

func _ready():
	var debugView = $"/root/DebugView"
	debugView.connect("debug_on", self, "_on_DebugView_debug_on")
	debugView.connect("debug_off", self, "_on_DebugView_debug_off")

func _on_DebugView_debug_on():
	parent.visible = true

func _on_DebugView_debug_off():
	parent.visible = false
