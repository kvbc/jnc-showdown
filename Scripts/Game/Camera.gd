extends Camera2D

func _process (delta: float) -> void:
	var mouse_pos:Vector2 = get_global_mouse_position();
	var offs:Vector2 = mouse_pos - get_camera_screen_center();
	offset = offs / 10;
