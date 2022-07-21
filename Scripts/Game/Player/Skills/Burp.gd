###########################################################
#
# Game/Player/Skills/Burp.gd
#
###########################################################

extends Node2D;

#
# Private
#

onready var __G : Node = AutoLoad_Global;
onready var __SG : Node = $"/root/Game";

onready var __hb : Area2D = $Hitbox;
onready var __hbshape : CollisionShape2D = __hb.get_node("shape");
onready var __sprite : Sprite = $Sprite;

onready var __org_sprite_size = __sprite.region_rect.size;
onready var __org_hbshape_size = __hbshape.shape.extents;
onready var __org_hbshape_position = __hbshape.position;
onready var __org_position = position;

#
# Public
#

var direction = Vector2.ZERO;

###########################################################
#
# Burp
#
###########################################################

func Burp_enable (yes: bool) -> void:
	set_process(yes);
	__hb.monitoring = yes;
	__hbshape.disabled = not yes;
	__sprite.visible = yes;

func Burp_look_at (pos: Vector2) -> void:
	direction = (pos - global_position).normalized();
	look_at(pos);

func Burp_reset () -> void:
	position = __org_position;
	direction = Vector2.ZERO;
	__sprite.region_rect.size = __org_sprite_size;
	__hbshape.shape.extents = __org_hbshape_size;
	__hbshape.position = __org_hbshape_position;
	
func __Burp_on_body_enter (body):
	if body == get_parent():
		return;
	body.rpc("__PlayerNET_impulse", direction * 1000);
	
###########################################################
#
# Godot
#
###########################################################
	
func _ready ():
	connect("body_entered", self, "__Burp_on_body_enter");
	
func _process (delta):
	if (__sprite.region_rect.size.x) > (__org_sprite_size.x * __G.PLAYER_SKILL_BURP_SEGMENTS):
		Burp_enable(false);
		return;
	__sprite.region_rect.size.x += __G.PLAYER_SKILL_BURP_SPEED * delta;
	__hbshape.position.x += __G.PLAYER_SKILL_BURP_SPEED * __sprite.scale.x * delta;
