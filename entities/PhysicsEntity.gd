extends RigidBody2D

var depth : float = -INF

const air_density   = 1.225  # kg / m3
const water_density = 997.0  # kg / m3
var fluid_density   = 997.0  # kg / m3

var water_linear_damp : float
var air_linear_damp : float

var water_angular_damp : float
var air_angular_damp : float

var default_mass : float = self.mass
export(float) var volume : float = 1  # m3

export(bool) var auto_neutral_buoyancy : bool = true
export(bool) var auto_angular_dampen   : bool = true

export(float) var drag_coefficient : float = 0.005
export(float) var perpendicular_drag_ratio : float = 1 # perpendicular drag = parallel drag * drag_ratio 
export(float) var drag_friction_amount : float = 10.0

var linear_parallel_drag_coefficient : float
var linear_perpendicular_drag_coefficient : float
var linear_friction_coefficient : float
var angular_drag_coefficient : float
var angular_friction_coefficient : float

func _init():
	set_linear_damp(get_linear_damp())
	set_angular_damp(get_angular_damp())

func _ready():
	if auto_neutral_buoyancy:
		self.mass = water_density * volume
	self.default_mass = self.mass
	if auto_angular_dampen:
		water_angular_damp = water_angular_damp * perpendicular_drag_ratio
		air_angular_damp = air_angular_damp * perpendicular_drag_ratio
	recalculate_drag_coefficients()

var force_integrators = []
func register_force_integrator(integrator):
	force_integrators.append(integrator)

func _integrate_forces(state):
	update_depth()
	
	# Add gravity, buoyancy, and drag
	state.add_central_force(calculate_gravity(state))
	state.add_central_force(calculate_buoyancy(state))
	state.add_central_force(calculate_drag(state))
	
	# Add angular drag
	state.add_torque(calculate_torque_drag(state))
	
	for integrator in force_integrators:
		integrator.integrate_forces(state)
	
	state.linear_velocity  = state.linear_velocity  + (state.step * self.applied_force  * state.inverse_mass )
	var av_delta = (state.step * self.applied_torque * state.inverse_inertia )
	state.angular_velocity = state.angular_velocity + av_delta

var underwater = false

func update_depth():
	depth = self.global_position.y
	
	# Disable buoyancy above water
	if depth <= -10:
		underwater = false
		fluid_density = air_density
		self.angular_damp = air_angular_damp
		self.linear_damp  = air_linear_damp
		recalculate_drag_coefficients()
	elif depth <= 0:
		underwater = false
		var ratio = max(10 + depth, 0) / 10.0;
		fluid_density = lerp(air_density, water_density, ratio)
		self.angular_damp = water_angular_damp
		self.linear_damp  = water_linear_damp
		recalculate_drag_coefficients()
	elif !underwater:
		underwater = true
		fluid_density = water_density;
		self.angular_damp = water_angular_damp
		self.linear_damp  = water_linear_damp
		recalculate_drag_coefficients()

var gravity_force = Vector2()
func calculate_gravity(state : Physics2DDirectBodyState):
	var total = state.total_gravity * self.mass
	var delta = total - gravity_force
	gravity_force = total
	return delta
	
var buoyancy_force = Vector2()
func calculate_buoyancy(state : Physics2DDirectBodyState):
	var total = fluid_density * volume * -state.total_gravity
	var delta = total - buoyancy_force
	buoyancy_force = total
	return delta

func set_linear_damp(value):
	.set_linear_damp(value)
	if value < 0:
		value = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	water_linear_damp = value
	air_linear_damp = value * 0.1
	recalculate_drag_coefficients()

func set_angular_damp(value):
	.set_angular_damp(value)
	if value < 0:
		value = ProjectSettings.get_setting("physics/2d/default_angular_damp")
	water_angular_damp = value
	air_angular_damp = value * 0.1
	if auto_angular_dampen:
		water_angular_damp = water_angular_damp * perpendicular_drag_ratio
		air_angular_damp = air_angular_damp * perpendicular_drag_ratio
	recalculate_drag_coefficients()

func get_linear_damp():
	if linear_damp < 0:
		return ProjectSettings.get_setting("physics/2d/default_linear_damp")
	else:
		return linear_damp

func get_angular_damp():
	if angular_damp < 0:
		return ProjectSettings.get_setting("physics/2d/default_angular_damp")
	else:
		return angular_damp

func recalculate_drag_coefficients():
	var l_damp = get_linear_damp()
	var a_damp = get_angular_damp()
	linear_parallel_drag_coefficient = drag_coefficient * l_damp * -1
	linear_perpendicular_drag_coefficient = drag_coefficient * perpendicular_drag_ratio * l_damp * -1
	linear_friction_coefficient = drag_friction_amount * l_damp * -1
	
	angular_drag_coefficient = drag_coefficient * perpendicular_drag_ratio * a_damp * 10.0 * -1
	angular_friction_coefficient = drag_friction_amount * a_damp * -1

func set_linear_damp_for_max_speed(thrust_scalar : float, max_speed : float):
	#	linear_parallel_drag_coefficient = drag_coefficient * self.linear_damp
	#	linear_friction_coefficient = drag_friction_amount * self.linear_damp
	#	drag_force = speed * speed * linear_parallel_drag_coefficient
	#	friction_force = linear_friction_coefficient
	#	thrust = drag_force + friction_force
	#	t = (s * s * (d * l)) + (f * l)
	#	l = t / (s*s*d+f)
	var damp = thrust_scalar / ( max_speed * max_speed * self.drag_coefficient + self.drag_friction_amount ) 
	self.set_linear_damp(damp)
	
var drag_force = Vector2()
func calculate_drag(state : Physics2DDirectBodyState):
	
	var total = Vector2()
	
	if state.linear_velocity.x != 0 or state.linear_velocity.y != 0:
		# Dynamic drag
		var current_facing = Vector2(1.0, 0.0).rotated(state.transform.get_rotation())
		var parallel_velocity = current_facing * current_facing.dot(state.linear_velocity)
		var perpendicular_velocity = state.linear_velocity - parallel_velocity
		var parallel_drag_force = parallel_velocity.normalized() * parallel_velocity.length_squared() * linear_parallel_drag_coefficient
		var perpendicular_drag_force = perpendicular_velocity.normalized() * perpendicular_velocity.length_squared() * linear_perpendicular_drag_coefficient

		# Friction
		var friction_force = linear_friction_coefficient * state.linear_velocity.normalized()

		total = parallel_drag_force + perpendicular_drag_force + friction_force
		
		# Maximum drag possible is the amount of force required to come to a complete stop in one step
		var max_drag_force = -state.linear_velocity * self.mass / state.step
		if total.length_squared() > max_drag_force.length_squared():
			total = max_drag_force

	var delta = total - drag_force
	drag_force = total
	return delta

var drag_torque = 0.0
func calculate_torque_drag(state : Physics2DDirectBodyState):
	
	var total = 0.0
	
	if state.angular_velocity != 0:
		# Dynamic drag
		var dynamic_drag_torque = state.angular_velocity * state.angular_velocity * angular_drag_coefficient * sign(state.angular_velocity)
		
		# Friction
		var friction_torque = angular_friction_coefficient * sign(state.angular_velocity)

		total = dynamic_drag_torque + friction_torque

		# Maximum friction possible is the amount of force required to come to a complete stop in one step
		var max_torque = state.angular_velocity * -self.inertia / state.step

		if abs(total) > abs(max_torque):
			total = max_torque

	var delta = total - drag_torque
	drag_torque = total
	return delta
