extends "res://Scripts/UI/Title/ButtonList/Button.gd"

onready var __panel : ColorRect = $"/root/UI/Panel";

func __unpress () -> void:
	.__unpress();
	__panel.untween();

func __press () -> void:
	.__press();
	__panel.set_host();
	__panel.tween();
