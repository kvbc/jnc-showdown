extends ColorRect

var __fade_out : bool = false;
var __fade_in  : bool = false;
var __fade_start_msec : float = 0.0;

func fade_out ():
	__fade_out = true;
	__fade_start_msec = OS.get_ticks_msec();

func fade_in ():
	__fade_out = false;
	__fade_in = true;
	__fade_start_msec = OS.get_ticks_msec();

func _process (delta: float):
	if __fade_out:
		material.set_shader_param("time", (OS.get_ticks_msec() - __fade_start_msec) / 800.0);
	elif __fade_in:
		material.set_shader_param("time", (800 - (OS.get_ticks_msec() - __fade_start_msec)) / 800.0);
