###########################################################
#
# Lobby :: PlayerPuppet.gd
#
###########################################################

extends "res://Scripts/PlayerPuppet.gd";

onready var __SG : Control = $"/root/UI";

var ready = false;

###########################################################
#
# PlayerPuppet
#
###########################################################

func PlayerPuppet_set_character (_character : int) -> void:
	Player_character_set(_character);
	get_node(__SG.STAND_PLAYER_CHAR_PATH).bbcode_text = "[center]" + __SG.__G.Player_character_codename(_character) + "[center]";
	animtop.play(__SG.__G.Player_character_animname(_character, "idle"));
	animbot.play(__SG.__G.Player_character_animname(_character, "idle"));

###########################################################
#
# Godot
#
###########################################################

func _ready () -> void:
	init(__SG.__G, self);
	PlayerPuppet_set_character(__SG.Player_starting_character);
