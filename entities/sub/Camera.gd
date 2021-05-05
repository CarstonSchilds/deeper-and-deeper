extends Camera2D


const MIN_ZOOM = 0.1
const MAX_ZOOM = 1.25

func _on_Player_zoom_in():
	if self.zoom.length() > MIN_ZOOM:
		self.zoom = self.zoom - Vector2(0.25, 0.25)


func _on_Player_zoom_out():
	if self.zoom.length() < MAX_ZOOM:
		self.zoom = self.zoom + Vector2(0.25, 0.25)
