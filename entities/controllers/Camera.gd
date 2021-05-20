extends Camera2D

signal zoom_in
signal zoom_out

const MIN_ZOOM = 0.1
const MAX_ZOOM = 1.25

func _input(event):
	if event is InputEventMouseMotion :
		if event.button_mask & 2:
			var offset = self.offset - ( event.relative / 2.0 )
			var width  =  get_viewport_rect().size.x / 4.0
			var height =  get_viewport_rect().size.y / 4.0
			var x = min(max(round(offset.x), -width),  width)
			var y = min(max(round(offset.y), -height), height)
			self.offset = Vector2(x, y)
		if event.button_mask & 1:
			var offset = (event.position - (get_viewport_rect().size / 2.0) ) / 2.5
			self.offset = Vector2(round(offset.x), round(offset.y))

func _process(delta):
	# CAMERA ZOOM CONTROLS
	if Input.is_action_just_released("zoom_in"):
		emit_signal("zoom_in")
		if self.zoom.length() > MIN_ZOOM:
			self.zoom = self.zoom - Vector2(0.25, 0.25)
		
	if Input.is_action_just_released("zoom_out"):
		emit_signal("zoom_out")
		if self.zoom.length() < MAX_ZOOM:
			self.zoom = self.zoom + Vector2(0.25, 0.25)
