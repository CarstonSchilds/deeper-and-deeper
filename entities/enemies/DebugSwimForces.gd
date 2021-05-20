extends Position2D

onready var body   = $"../../../PhysicsEntity"
onready var swim_controller = $"../../../SwimController"

onready var target_line = $"Target"
onready var thrust_line = $"Thrust"
onready var torque_line = $"Torque"
const PIby2 = PI / 2

func _ready():
	if swim_controller == null:
		self.queue_free()

func _process(delta):
	
	var target = swim_controller.get_target()
	if target != null:
		target_line.scale.y =  (target - body.global_position).length()
		target_line.rotation = (target - body.global_position).angle() + PIby2
	else:
		target_line.scale.y =  0.0
		target_line.rotation = 0.0
		
	thrust_line.scale.y =  swim_controller.thrust.length() / body.mass
	thrust_line.rotation = swim_controller.thrust.angle() + PIby2
	
#	torque_line.scale.y =  swim_controller.torque / body.inertia
