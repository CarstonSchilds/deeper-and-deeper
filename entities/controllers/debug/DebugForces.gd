extends Position2D

onready var body = $"../.."

onready var gravity_line      = $"Gravity"
onready var drag_line         = $"Drag"
onready var buoyancy_line     = $"Buoyancy"
onready var angular_drag_line = $"AngularDrag"
const PIby2 = PI / 2

func _process(delta):
	if body.mass == 0.0 or body.inertia == 0.0:
		return
	gravity_line.scale.y = body.gravity_force.length() / body.mass
	gravity_line.rotation = body.gravity_force.angle() + PIby2
	drag_line.scale.y = body.drag_force.length() / body.mass
	drag_line.rotation = body.drag_force.angle() + PIby2
	buoyancy_line.scale.y = body.buoyancy_force.length() / body.mass
	buoyancy_line.rotation = body.buoyancy_force.angle() + PIby2
	angular_drag_line.scale.y = body.drag_torque / body.inertia
