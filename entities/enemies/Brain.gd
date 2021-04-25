extends Node2D

var control_vector = Vector2()
var home = Vector2()
var body = null
var world = null
var user = null
var current_state = null
var threatened = false
onready var state_map = {
	'natural_behaviour': $States/NaturalBehaviour,
	'pursue': $States/Pursue,
	'return_home': $States/ReturnHome,
	'attack': $States/Attack
}
var state_stack = []

signal state_changed

onready var attack_range = $AttackRange
onready var attack_range_shape = $AttackRange/CollisionShape2D
onready var target_range = $ThreatRange
onready var threat_range_shape = $ThreatRange/CollisionShape2D
	
func _ready():
	self.body = self.get_parent()
	self.home = Vector2(self.body.position)
	current_state = state_map['natural_behaviour']
	current_state.enter(self)

func notify():
	pass

func think(delta):
	var new_state = current_state.update(delta)
	if new_state:
		self.change_state(new_state)
	return self.control_vector

func change_state(state):
	current_state.exit(self)
	
	if state == 'previous':
		state_stack.pop_front()
	elif state in state_map.keys():
		state_stack.push_front(state_map[state])
	else:
		var new_state = state_map[state]
		state_stack[0] = new_state
	
	current_state = state_stack[0]
	if state != 'previous':
		current_state.enter(self)
	emit_signal('state_changed', state_stack)

func _on_ThreatRange_body_entered(body):
	if body.name == 'Player':
		self.threatened = true

func _on_ThreatRange_body_exited(body):
	if body.name == 'Player':
		self.threatened = false

func move_and_steer_towards(target):
	var vector_to_target = self.body.position.direction_to(target)
	var angle_to_target = self.body.current_facing.angle_to(vector_to_target)
	self.control_vector = vector_to_target.normalized() * 0.5
