extends CanvasLayer

onready var brain = $".."

onready var label = $"Label"

func _ready():
	if brain == null:
		self.queue_free()

func _process(delta):
	if brain.current_state != null:
		label.text = brain.current_state.state_name()
	else:
		label.text = "[:]"
