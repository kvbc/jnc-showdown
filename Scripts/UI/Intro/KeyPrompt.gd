extends "res://Scripts/UI/Intro/Button.gd";

var __y : float = 0.0;
var __org_y : float;

func __ready ():
	__org_y = rect_position.y;

func _ready ():
	call_deferred("__ready");
	modulate.a = 0.0;

func __press () -> void:
	.__press();
	get_parent().__on_key_prompt_press();
	yield(get_tree().create_timer(1.0), "timeout");
	get_tree().change_scene("res://Scenes/UI/Title.tscn");

func _process (delta: float) -> void:
	__y += 10 * delta;
	rect_position.y = __org_y + (3 * sin(__y));
