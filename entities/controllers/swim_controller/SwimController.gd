extends Node

onready var parent : Node2D = $".."
onready var body : RigidBody2D = $"../PhysicsEntity"

var target = null setget set_target, get_target
var ram_target = true
var flee = false

export(float) var auto_max_speed : float = -1
export(float) var thrust_scalar : float = 1
export(bool) var scale_thrust_with_mass : bool = true
export(bool) var scale_thrust_with_fluid_density : bool = true

export(float) var rotation_offset = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Be sure that this node is the only "SwimController"
	assert(parent.get_node("SwimController") == self)
	body.register_force_integrator(self)
	if auto_max_speed > 0:
		var effective_thrust_scalar = thrust_scalar
		if scale_thrust_with_mass:
			effective_thrust_scalar *= body.mass
		if scale_thrust_with_fluid_density:
			effective_thrust_scalar *= body.water_density
		body.set_linear_damp_for_max_speed(effective_thrust_scalar, auto_max_speed)

func _process(_delta):
	if target != null and body.sleeping:
		# Wake body
		body.apply_central_impulse(Vector2(0.0, 0.0))

func set_target(value):
	target = value

func get_target():
	if target is Vector2:
		return target
	elif target != null and target.global_position is Vector2:
		return target.global_position
	else:
		return null

func integrate_forces(state : Physics2DDirectBodyState):
	
	var target = get_target()
	var current_facing = Vector2.ZERO
	var to_target = Vector2.ZERO
	
	if target != null:
		to_target = target - body.global_position
	
	if target != null:
		move_towards(state, to_target, target)
	else:
		stop_move(state)
		
	flip_and_scale()
		
	if target != null:
		look_follow(state, to_target)
	else:
		stop_rotation(state)

var thrust = Vector2()

func move_towards(state : Physics2DDirectBodyState, to_target : Vector2, target : Vector2):
	
	var effective_thrust_scalar = thrust_scalar
	if scale_thrust_with_mass:
		effective_thrust_scalar *= body.mass
	if scale_thrust_with_fluid_density:
		effective_thrust_scalar *= body.fluid_density
	if flee:
		effective_thrust_scalar *= -1
		
	var target_force = to_target.normalized() * effective_thrust_scalar

	if !ram_target:
		# Slow down before hitting target
		var distance_to_target = to_target.length()
		var speed = state.linear_velocity.length()

		var a = -body.linear_friction_coefficient * state.inverse_mass
		var b = -body.linear_parallel_drag_coefficient * state.inverse_mass

		# var c = 0
		# var stop_distance = -(log(cos(atan(-speed/sqrt(a/b)))) - sqrt(a*b)*c)/b
		var stop_distance = -(log(cos(atan(-speed/sqrt(a/b)))))/b

		# Remove target if we will arrive within 
		if distance_to_target <= stop_distance:
			target_force = Vector2()

	state.add_central_force(target_force - thrust)
	thrust = target_force
	
func stop_move(state : Physics2DDirectBodyState):
	state.add_central_force(-thrust)
	thrust = Vector2()

const normal = Vector2( 1.0, 1.0)
const flip_h = Vector2(-1.0, 1.0)
var last_scale = null

func flip_and_scale():
	if thrust.x < 0:
		last_scale = flip_h
	if thrust.x > 0:
		last_scale = normal
		
	if last_scale != null:
		body.set_scale(last_scale)

# Use to set angle in one step
func look_follow(state : Physics2DDirectBodyState, to_target : Vector2):
	var right = Vector2(1, 0)
	right *= body.scale
	var ofs = rotation_offset
	if last_scale == flip_h:
		ofs *= -1
	var current_facing = right.rotated(state.transform.get_rotation() + ofs)
	var desired_angular_velocity = current_facing.angle_to(to_target) / state.step / 16
	var desired_change_in_angular_velocity = desired_angular_velocity - state.angular_velocity
	state.angular_velocity = state.angular_velocity + desired_change_in_angular_velocity

func stop_rotation(state : Physics2DDirectBodyState):
	state.angular_velocity = 0.0
