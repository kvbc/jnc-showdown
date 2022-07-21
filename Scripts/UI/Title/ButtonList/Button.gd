extends ColorRect;

var offset = 25.0;
var lerp_speed = 0.1;

var __org_color : Color = color;

onready var __G = $"/root/AutoLoad_Global";

onready var __hover_sound : AudioStreamPlayer = $"/root/UI/button_hover";
onready var __text_label  : RichTextLabel = $RichTextLabel;

var __pressed : bool = false;
var __org_x : float;
var __lerp : bool = false;
var __lerp_x_offs : float = 0.0;

func __ready () -> void:
	__org_x = rect_position.x;
	__lerp = true;

func __select () -> void:
	__lerp_x_offs = offset;

func __play_select_sound () -> void:
	__hover_sound.play();

func __deselect () -> void:
	__pressed = false;
	__lerp_x_offs = 0.0;
	color = __org_color;
	__text_label.modulate = Color.white;

func __unpress () -> void:
	__pressed = false;
	__play_select_sound();
	color = __org_color;
	__text_label.modulate = Color.white;

func __press () -> void:
	__pressed = true;
	color = Color.white;
	__text_label.modulate = Color.black;
	__G.sfx_button_click.play();

func _ready () -> void:
	call_deferred("__ready");

func _process (delta: float) -> void:
	if __lerp:
		rect_position.x = lerp(rect_position.x, __org_x + __lerp_x_offs, lerp_speed);
