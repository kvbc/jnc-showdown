extends Control;

export (int) var __selected : int = 0;
var __pressed : int = -1;
var __on_mouse = null;
var __start : int = 0;
onready var __end : int = get_child_count();

func __select_raw (idx: int) -> void:
	if __selected != __pressed:
		get_child(__selected).__deselect();
	__selected = idx;
	var button = get_child(idx);
	button.__select();
	button.__play_select_sound();

func __select (idx:int, dir:int = 0) -> void:
	if idx == __pressed:
		idx += dir;
	__select_raw(wrapi(idx,__start,__end));

func __press () -> void:
	var button = get_child(__selected);
	if button.__pressed:
		__pressed = -1;
		if __on_mouse != button:
			button.__deselect();
		button.__unpress();
	else:
		__start = 0;
		__end = get_child_count();
		if __pressed >= 0:
			get_child(__pressed).__unpress();
			get_child(__pressed).__deselect();
		__pressed = __selected;
		if   __pressed == __start : __start += 1;
		elif __pressed == __end-1 : __end   -= 1;
		button.__press();

func _ready () -> void:
	get_children()[__selected].__select();

func _input (event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("up"):
			__select(__selected - 1, -1);
		elif event.is_action_pressed("down"):
			__select(__selected + 1, +1);
		elif event.is_action_pressed("ui_accept"):
			__press();
	elif event is InputEventMouse:
		for i in range(get_child_count()):
			if get_child(i).get_global_rect().has_point(get_global_mouse_position()):
				__on_mouse = get_child(i);
				if __selected != i:
					__select_raw(__on_mouse.get_index());
				break;
		if event is InputEventMouseButton:
			if not event.pressed:
				if __on_mouse != null:
					__press();
		__on_mouse = null;
