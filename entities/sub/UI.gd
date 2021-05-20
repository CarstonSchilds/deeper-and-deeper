extends CanvasLayer

onready var player = $".."
onready var body                      = player.get_node("PhysicsEntity")
onready var player_controller         = player.get_node("PlayerController")
onready var health_controller         = player.get_node("HealthController")
onready var throttle_input_controller = player.get_node("ThrottleInputController")
onready var buoyancy_input_controller = player.get_node("BuoyancyInputController")

onready var depth_label    = $"Depth"
onready var throttle_label = $"Throttle"
onready var buoyancy_label = $"Buoyancy"
onready var hull_label     = $"Hull"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "UI"
	assert(player.get_node("UI") == self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if health_controller.hit_points <= 25:
		self.hull_label.set("custom_colors/font_color", ColorN("red", 1))
		self.buoyancy_label.set("custom_colors/font_color", ColorN("red", 1))
	elif health_controller.hit_points <= 50:
		self.hull_label.set("custom_colors/font_color", ColorN("orange", 1))

	self.hull_label.text = "Hull %0.0f" % [health_controller.hit_points]
	self.buoyancy_label.text = "Buoyancy %0.0f" % [buoyancy_input_controller.control_buoyancy]
	self.throttle_label.text = "Throttle %s" % [throttle_input_controller.get_named_throttle_state()]
	depth_label.text = "Depth %0.0f\nMax %0.0f" % [body.depth, player_controller.max_depth]
