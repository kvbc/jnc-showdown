extends Control

onready var __G : Node = $"/root/AutoLoad_Global";

onready var __music_theme = __G.sound_music_theme;
onready var __background : Node = $"/root/AutoLoad_UI/TransitionBackground".duplicate();

var __lerp = false;
var __shake = false;
onready var __org_x = $top.rect_position.x;
onready var __x1 = __org_x;
onready var __x2 = __org_x;

func __on_key_prompt_press ():
	__shake = false;
	__x1 = -500.0;
	__x2 = 1500.0;

func _ready ():
	add_child(__background);
	move_child(__background, 0)
	__music_theme.play();
	__music_theme.seek(1.0);
	$KeyPrompt.enable();
	$KeyPrompt.visible = false;
	yield(get_tree().create_timer(18.0), "timeout");
	__lerp = true;
	__shake = true;
	$KeyPrompt.visible = true;
	$KeyPrompt.fade_in();

func _process (delta):
	if __lerp:
		if __shake and (abs($top.rect_position.x - __x1) < 10.0):
			__x1 = __org_x + (randi() % 100 - 50);
			__x2 = __x1;
		$top.rect_position = lerp($top.rect_position, Vector2(__x1, 150.0), 0.1);
		$bottom.rect_position = lerp($bottom.rect_position, Vector2(__x2, 150.0 + $"top/TextureRect".rect_size.y), 0.1);
