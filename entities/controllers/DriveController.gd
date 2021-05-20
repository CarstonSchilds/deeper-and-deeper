extends Node

onready var player : Node2D = $".."
onready var body = $"../PhysicsEntity"

var control_vector = Vector2(1.0,1.0)

export(float) var auto_max_speed : float = -1
export(float) var max_turn_rate : float = 1
export(float) var thrust_scalar : float = 0.1
export(float) var torque_scalar : float = 1
export(bool) var scale_thrust_with_mass : bool = true
export(bool) var scale_thrust_with_fluid_density : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "DriveController"
	assert(player.get_node("DriveController") == self)
	body.register_force_integrator(self)
	if auto_max_speed > 0:
		var effective_thrust_scalar = thrust_scalar
		if scale_thrust_with_mass:
			effective_thrust_scalar *= body.mass
		if scale_thrust_with_fluid_density:
			effective_thrust_scalar *= body.water_density
		body.set_linear_damp_for_max_speed(effective_thrust_scalar, auto_max_speed)

func _process(_delta):
	if control_vector != Vector2.ZERO and body.sleeping:
		# Wake body
		body.apply_central_impulse(Vector2(0.0, 0.0))

func integrate_forces(state : Physics2DDirectBodyState):
	var right = Vector2(1, 0)
	right *= body.scale
	var current_facing = right.rotated(state.transform.get_rotation())
	
	do_thrust(state,current_facing)
	if control_vector.x != 0:
		do_torque(state)
	else:
		stop_rotation(state)

var thrust = Vector2()

func do_thrust(state : Physics2DDirectBodyState, current_facing : Vector2):
	var target_force = current_facing * thrust_scalar * control_vector.y
	if scale_thrust_with_mass:
		target_force *= body.mass
	if scale_thrust_with_fluid_density:
		target_force *= body.fluid_density

	state.add_central_force(target_force - thrust)
	thrust = target_force

var torque = 0.0

func do_torque(state : Physics2DDirectBodyState):
	var target_torque = torque_scalar * control_vector.x
	if scale_thrust_with_mass:
		target_torque *= body.mass
	if scale_thrust_with_fluid_density:
		target_torque *= body.fluid_density

	# scale target_torque against max_turn_rate
	if sign(state.angular_velocity) == sign(target_torque):
		var abs_turn_rate = abs(state.angular_velocity)
		if abs_turn_rate > max_turn_rate:
			target_torque = 0.0
		else:
			var weight = 1 - (max_turn_rate - abs_turn_rate) / max_turn_rate
			var damp = sqrt(1 - weight)
			target_torque *= damp

	state.add_torque(target_torque - torque)
	torque = target_torque

func stop_rotation(state : Physics2DDirectBodyState):
	var target_torque = torque_scalar * -state.angular_velocity / max_turn_rate
	if scale_thrust_with_mass:
		target_torque *= body.mass
	if scale_thrust_with_fluid_density:
		target_torque *= body.fluid_density

	state.add_torque(target_torque - torque)
	torque = target_torque
