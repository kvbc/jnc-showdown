extends Control;

onready var __background : Node = $"/root/AutoLoad_UI/TransitionBackground".duplicate();

func _ready () -> void:
	add_child(__background);
	__background.fade_out();
