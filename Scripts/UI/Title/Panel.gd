extends Control;

var offset = -400.0;
var lerp_speed = 0.1;

var __org_x : float;
var __lerp : bool = false;
var __lerp_x_offs : float = 0.0;

onready var __host : Control = $Host;
onready var __join : Control = $Join;

func __ready () -> void:
	__org_x = rect_position.x;
	__lerp = true;

func set_host () -> void:
	__host.visible = true;
	__join.visible = false;

func set_join () -> void:
	__join.visible = true;
	__host.visible = false;

func tween () -> void:
	__lerp_x_offs = offset;

func untween () -> void:
	__lerp_x_offs = 0.0;

func _ready () -> void:
	call_deferred("__ready");

func _process (delta: float) -> void:
	if __lerp:
		rect_position.x = lerp(rect_position.x, __org_x + __lerp_x_offs, lerp_speed);
