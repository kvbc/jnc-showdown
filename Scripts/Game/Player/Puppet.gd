###########################################################
#
# Game :: Player :: Puppet.gd
#
###########################################################

extends KinematicBody2D;

var Puppet = self;

onready var __G : Node = $"/root/AutoLoad_Global";
var __body : Node;
var Base : Node;

var handarea;
var handhb;
var handpe;
var handcr;

func __load_body_parts () -> void:
	handarea = __body.get_node("hand-area");
	handhb = handarea.get_node("hitbox");
	handpe = handarea.get_node("smoke");
	handcr = handarea.get_node("ColorRect");

func _init (_body = self):
	__body = _body;
	__load_body_parts();
	Base = preload("res://Scripts/Player/Base.gd").new(__body);
	Base.net.peer = __body.get_network_master();
	return self;

func hand_disable ():
	handarea.monitoring = false;
	handhb.disabled = true;
	handcr.visible = false;
	
func hand_enable ():
	handarea.monitoring = true;
	handhb.disabled = false;
	handcr.visible = true;
