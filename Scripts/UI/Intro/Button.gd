extends Control;

export (int) var E_delay:int = 1000; # in ms

onready var __click_sound : AudioStreamPlayer = $AudioStreamPlayer;

var __clicked : bool = false;
var __enabled : bool = false;
var __fade_in : bool = false;

func enable  () -> void: __enabled = true;
func disable () -> void: __enabled = false;

func fade_in () -> void: __fade_in = true;

func __press () -> void:
	var shdw = duplicate();
	shdw.script = null;
	shdw.rect_position += Vector2(-10.0, 10.0);
	shdw.modulate.a = 0.3;
	get_parent().add_child(shdw);
	__click_sound.play();
	__clicked = true;
	__fade_in = false;
	
	yield(get_tree().create_timer(0.1), "timeout");
	shdw.rect_position = rect_position - Vector2(-10.0, 10.0);
	
	yield(get_tree().create_timer(0.2), "timeout");
	get_parent().remove_child(shdw);

func _input (event):
	if not __enabled:
		return;
	if ((event is InputEventKey) or
		(event is InputEventMouseButton)):
		if event.pressed and not __clicked:
			__press();

func _process (delta: float) -> void:
	if not __enabled:
		return;
	if __clicked:
		modulate.a -= 2 * delta;
	elif __fade_in and (modulate.a < 1.0):
		modulate.a += 1 * delta;
