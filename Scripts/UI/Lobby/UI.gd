###########################################################
#
# Lobby :: UI.gd
# Scene Globals (SG)
#
###########################################################

extends Node;

# AutoLoads
onready var __G : Node = $"/root/AutoLoad_Global"; # Project globals

###########################################################
#
# Scene Globals
#
###########################################################

#
# Constants
#

const STAND_PLAYER_PATH      : String = "player";
const STAND_PLAYER_NICK_PATH : String = "nick";
const STAND_PLAYER_CHAR_PATH : String = "char";
const STAND_LIGHT_PATH       : String = "light";
const STAND_STAND_PATH       : String = "Stand";

const SCENE_PATH_TITLE : String = "res://Scenes/UI/Title.tscn";
const SCENE_PATH_GAME  : String = "res://Scenes/Game.tscn";

const SCANCODE_READY : int = KEY_ENTER;
const SCANCODE_START : int = KEY_SPACE;
const SCANCODE_EXIT  : int = KEY_ESCAPE;

export (float) var STAND_ARROW_OFFSET    : float = 100.0;
export (float) var STAND_ARROW_SCALE     : float = 2.0;
export (float) var STAND_PLR_NICK_OFFSET : float = 70.0;
export (float) var STAND_PLR_CHAR_OFFSET : float = 60.0;

#
# Nodes
#

onready var background : Control = $"/root/AutoLoad_UI/TransitionBackground".duplicate();
onready var stands : HBoxContainer = $"Stands";

onready var sfx_change_char  : AudioStreamPlayer = $"SoundEffects/change_char";
onready var sfx_spotlight    : AudioStreamPlayer = $"SoundEffects/spotlight";

onready var txtlbl_ready : RichTextLabel = $"TextLabels/ready";
onready var txtlbl_start : RichTextLabel = $"TextLabels/start";
onready var txtlbl_esc   : RichTextLabel = $"TextLabels/esc";

#
# Resources
#

onready var stand_rigid_player : RigidBody2D = preload("res://Scenes/Player.tscn").instance();

var scene_arrow       : PackedScene = preload("res://Scenes/Arrow.tscn"); 
var scene_txtlbl_nick : PackedScene = preload("res://Scenes/Nick.tscn");
var scene_txtlbl_char : PackedScene = preload("res://Scenes/Character.tscn");

var script_PlayerPuppet : Script = preload("res://Scripts/UI/Lobby/PlayerPuppet.gd");
var script_PlayerMaster : Script = preload("res://Scripts/UI/Lobby/PlayerMaster.gd");

###########################################################
#
# SG
#
###########################################################

export (int) onready var Player_starting_character : int = __G.Player_Character.GREG;
var Host_can_start : bool = false;

func __SG_Host_can_start (yes : bool):
	Host_can_start = yes;
	txtlbl_start.visible = yes;

###########################################################
#
# Networking
#
###########################################################

#
# Update the flag that determines, if the host can start the game (all the players are ready) 
#
remotesync func __SG_NET_update_can_start () -> void:
	# -1, the host must ready up if he's playing solo (kinda stupid)
	var ready: int = -1;

	var peers: PoolIntArray = get_tree().get_network_connected_peers();
	for i in range(peers.size() + 1):
		var plr = stands.Stands_get_stand(i).Stand_get_player();
		ready += int(plr.ready);

	__SG_Host_can_start(ready == peers.size());

#
# Stop processing user input (the _input() function)
#
remotesync func __SG_NET_block_input () -> void:
	set_process_input(false);

#
# Change the scene to |path|
#
remote func __SG_NET_change_scene (path: String) -> void:
	background.fade_in();
	yield(get_tree().create_timer(2.0), "timeout");
	get_tree().change_scene(path);

#
# Called only on the server, when an client disconnects
#
func __on_network_peer_disconnected (id: int) -> void:
	if get_tree().is_network_server():
		for peer in get_tree().get_network_connected_peers():
			if peer == id:
				rpc_id(id, "__SG_NET_change_scene", SCENE_PATH_TITLE);
				break;
		__SG_NET_update_can_start();
	for i in range(stands.get_child_count()):
		var stand : Control = stands.Stands_get_stand(i);
		var plr : Node = stand.Stand_get_player_or_null();
		if plr == null:
			break;
		if stand.get_network_master() == id:
			stand.Stand_refresh();
			break;

###########################################################
#
# Godot
#
###########################################################

func _ready () -> void:
	add_child(background);
	move_child(background, stands.get_index() + 1);
	background.fade_out();

	if get_tree().is_network_server():
		get_tree().connect("network_peer_disconnected", self, "__on_network_peer_disconnected");

func _input (event) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == SCANCODE_EXIT:
				__SG_NET_change_scene(SCENE_PATH_TITLE);
				set_process_input(false);
			elif Host_can_start and (event.scancode == SCANCODE_START):
				__G.sfx_button_click.play();
				rpc("__SG_NET_block_input");
				rpc("__SG_NET_change_scene", SCENE_PATH_GAME);
				__SG_NET_change_scene(SCENE_PATH_GAME);
