###########################################################
#
# Lobby :: Stand.gd
#
###########################################################

extends Control;

onready var __SG : Control = $"/root/UI";

onready var light : TextureRect = get_node(__SG.STAND_LIGHT_PATH);
onready var stand : TextureRect = get_node(__SG.STAND_STAND_PATH);

###########################################################
#
# Stand
#
###########################################################

func Stand_refresh () -> void:
	light.visible = false;
	var plr : Node = Stand_get_player_or_null();
	if plr != null:
		plr.queue_free();

func Stand_get_player () -> Node:
	return get_node(__SG.STAND_PLAYER_PATH);

func Stand_get_player_or_null () -> Node:
	return get_node_or_null(__SG.STAND_PLAYER_PATH);

#
# Loads a player puppet onto the stand with a nickname |nick|.
# -> Returns the loaded body.
#
func Stand_load_PlayerPuppet (nick: String) -> KinematicBody2D:
	var player = KinematicBody2D.new();
	player.name = __SG.STAND_PLAYER_PATH;
	player.scale = Vector2(2.0, 2.0);
	player.position = rect_pivot_offset;
	
	for child in __SG.stand_rigid_player.get_children():
		if child is AnimatedSprite:
			player.add_child(child.duplicate());

	var txtlbl_nick: RichTextLabel = __SG.scene_txtlbl_nick.instance();
	txtlbl_nick.name = __SG.STAND_PLAYER_NICK_PATH;
	txtlbl_nick.bbcode_text = "[center]" + nick + "[center]";
	txtlbl_nick.rect_position.y -= __SG.STAND_PLR_NICK_OFFSET;
		
	var txtlbl_char: RichTextLabel = __SG.scene_txtlbl_char.instance();
	txtlbl_char.name = __SG.STAND_PLAYER_CHAR_PATH;
	txtlbl_char.rect_position.y -= __SG.STAND_PLR_CHAR_OFFSET;
	
	player.add_child(txtlbl_nick);
	player.add_child(txtlbl_char);
	add_child(player);
	
	return player;

#
# Loads a player muster onto the stand with a nickname |nick|.
# -> Returns the loaded body.
#
func Stand_load_PlayerMaster (nick: String) -> KinematicBody2D:
	var player = Stand_load_PlayerPuppet(nick);

	var left_arrow = __SG.scene_arrow.instance();
	var right_arrow = __SG.scene_arrow.instance();
	add_child(left_arrow);
	add_child(right_arrow);
	left_arrow.flip_h = true;
	left_arrow.rect_scale = Vector2(__SG.STAND_ARROW_SCALE, __SG.STAND_ARROW_SCALE);
	right_arrow.rect_scale = left_arrow.rect_scale;
	left_arrow.rect_position.x = -__SG.STAND_ARROW_OFFSET + stand.rect_pivot_offset.x;
	right_arrow.rect_position.x = __SG.STAND_ARROW_OFFSET + stand.rect_pivot_offset.x;

	return player;

###########################################################
#
# Networking
#
###########################################################

#
# Called on all the peers, when the client "switches his readiness"
#
remotesync func __Stand_NET_Player_ready () -> void:
	var plr : Node = Stand_get_player();
	plr.ready = not plr.ready;
	light.visible = not light.visible;

#
# Called on all the other peers, when the client changes his character to |character|
#
remote func __Stand_NET_Player_set_character (peer: int, character: int) -> void:
	Stand_get_player().PlayerPuppet_set_character(character);
	for player in __SG.__G.lobby:
		if player.peer == peer:
			player.character = character;

###########################################################
#
# Godot
#
###########################################################

func __Stand_advance_character (by: int) -> void:
	var character = Stand_get_player().character;
	
	__SG.sfx_change_char.play();

	__SG.__G.Player_get_character_voiceline(character, "select").stop();
	
	character = posmod(character + by, 4);
	Stand_get_player().PlayerPuppet_set_character(character);
	__SG.__G.player.character = character;
	rpc("__Stand_NET_Player_set_character", __SG.__G.player.peer, character);
	
	__SG.__G.Player_get_character_voiceline(character, "select").play();

func _input (event: InputEvent) -> void:
	if not is_network_master():
		return;
	if event is InputEventKey:
		if event.pressed:
			if event.is_action_pressed("left"): __Stand_advance_character(-1);
			elif event.is_action_pressed("right"): __Stand_advance_character(1);
			elif event.scancode == __SG.SCANCODE_READY:
				__SG.sfx_spotlight.play();
				rpc("__Stand_NET_Player_ready");
				__SG.rpc_id(1, "__SG_NET_update_can_start");
