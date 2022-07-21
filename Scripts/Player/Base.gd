###########################################################
#
# Player/Base.gd
#
# The most basic implementation of a visible player - a body with 2 animated sprites and an network interface
#
###########################################################

extends Node;
class_name BasePlayer

onready var __G : Node = AutoLoad_Global;
var __body : Node;
var animtop: AnimatedSprite; # top animation
var animbot: AnimatedSprite; # bottom animation
onready var net = __G.NetPlayer.new();

func _init (_body = self):
	__body = _body;
	animtop = __body.get_node("anim-top");
	animbot = __body.get_node("anim-bottom");

###########################################################
#
# Player
#
###########################################################

func BasePlayer_is_facing_left  () -> bool: return animtop.flip_h == true;
func BasePlayer_is_facing_right () -> bool: return animtop.flip_h == false;
