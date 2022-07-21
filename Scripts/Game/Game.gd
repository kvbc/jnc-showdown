###########################################################
#
# Game.gd
#
###########################################################

extends Node2D;

onready var __G : Node = $"/root/AutoLoad_Global";

export (float) var E_gh_pull_speed = 6000.0;


onready var gh     : Sprite = $gh;
onready var ghline : Line2D = $"gh-line";
onready var jojo : StaticBody2D = $jojo;
onready var jojoline : Line2D = $"jojo-line";

###########################################################
#
# Game
#
###########################################################

var player_actors: Array; #PlayerActor

###########################################################
#
# PlayerActor
#
###########################################################

class PlayerActor:
	var net_player;
	var body: KinematicBody2D; #local body
	var target_pos: Vector2 = Vector2.ZERO; #target position, updated by the player
	
	func _init (_body: KinematicBody2D, _net_player) -> void:
		net_player = _net_player;
		body = _body;

###########################################################
#
# Player Actors
#
###########################################################

# TO-DO error handling, when actor with given ID does not exist
func Game_get_player_actor_by_id (id:int):
	for player_actor in player_actors:
		if player_actor.net_player.peer == id:
			return player_actor;

# Update player actors on network 
remote func Game_NET_update_player_actors (id:int, pos:Vector2) -> void:
	Game_get_player_actor_by_id(id).target_pos = pos;

# Update player actors locally	
func Game_update_player_actors () -> void:
	for player_actor in player_actors:
		player_actor.body.position = lerp(player_actor.body.position, player_actor.target_pos, 0.3);

func Game_register_player_actor (player_actor:PlayerActor) -> void:
	player_actors.append(player_actor);

###########################################################
#
# Player
#
###########################################################

func Game_get_player (id: int):
	return get_node("player-" + str(id));

###########################################################
#
# 
#
###########################################################

func __add_player (body, player):
	body.name = "player-" + str(player.peer);
	body.set_network_master(player.peer);
	add_child(body);
	return body;
	
func add_player (): # __G.Player
	var body = preload("res://Scenes/Player.tscn").instance();
	var camera = preload("res://Scenes/Camera.tscn").instance();
	body.script = preload("res://Scripts/Game/Player/Master.gd");
	__add_player(body, __G.player);
	body.notification(NOTIFICATION_READY);
	body.add_child(camera);
	body.Puppet.PlayerPuppet.Player_character_set(__G.player.character);
	camera.make_current();
	return body;
	
func add_player_actor (player) -> void: # __G.Player
	var rigid_player = preload("res://Scenes/Player.tscn").instance();
	var body = KinematicBody2D.new();
	body.add_to_group("players");
	body.script = preload("res://Scripts/Game/Player/Puppet.gd");
	body.collision_layer = rigid_player.collision_layer;
	body.collision_mask = rigid_player.collision_mask;
	for child in rigid_player.get_children():
		body.add_child(child.duplicate());
	__add_player(body, player);
	body.notification(NOTIFICATION_READY);
	body.init(__G, body);
	body.PlayerPuppet.Player_character_set(player.character);
	Game_register_player_actor(PlayerActor.new(body, player));

func _ready():
	$"/root/AutoLoad_UI/TransitionBackground".visible = false;
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(1024.0, 600.0));
	add_player();
	for player in __G.lobby:
		add_player_actor(player);

func _process (delta: float) -> void:
	Game_update_player_actors();
