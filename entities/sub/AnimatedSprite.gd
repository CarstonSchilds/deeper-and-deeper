extends AnimatedSprite

onready var player = $"../../"

var moving = false
var rolling_over = false
var rolling_back = false

func set_idle():
	moving = false
	do_animation()
	
func set_moving():
	moving = true
	do_animation()

func start_roll_over():
	self.scale.y = -1
	rolling_over = true
	do_animation()
	
func start_roll_back():
	rolling_back = true
	do_animation()

func _on_AnimatedSprite_animation_finished():
	if self.animation == "roll over":
		rolling_over = false
		self.scale.y = 1
		player.invert(true)
		player.done_rolling()
		do_animation()
		
	elif self.animation == "roll back":
		rolling_back = false
		player.invert(false)
		player.done_rolling()
		do_animation()

func do_animation():
	if rolling_over:
		self.animation = "roll over"
	elif rolling_back:
		self.animation = "roll back"
	elif moving:
		self.animation = "move"
	else:
		self.animation = "idle"
