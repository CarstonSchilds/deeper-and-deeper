extends CheckBox

onready var fullscreen_controller = $"/root/FullscreenController"

func _ready():
	updateColor()
	$"/root/FullscreenController".connect("fullscreen",self,"_on_FullscreenController_change")

var hover = false
var click = false

func _on_FullscreenCheckBox_mouse_entered():
	hover = true
	updateColor()

func _on_FullscreenCheckBox_mouse_exited():
	hover = false
	updateColor()

func _on_FullscreenCheckBox_gui_input(event):
	if event is InputEventMouseButton and event.button_index == 1:
		click = event.pressed
		updateColor()
		if !click:
			doClick()

func updateColor():
	if click:
		self.modulate = Color("8cff79")
	elif hover:
		self.modulate = Color("e5e678")
	else:
		self.modulate = Color("ffffff")

func _on_FullscreenController_change(is_fullscreen):
	self.pressed = is_fullscreen

func _on_Fullscreen_button_up():
	doClick()

func doClick():
	fullscreen_controller.toggle()
