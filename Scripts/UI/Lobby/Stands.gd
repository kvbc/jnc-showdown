###########################################################
#
# Lobby :: Stands.gd
#
# TO-DO:
# * handle players disconnecting
#
###########################################################

extends Node;

onready var __SG = $"/root/UI";

###########################################################
#
# Stands
#
###########################################################

func Stands_get_stand (stand_idx: int) -> Node:
	return get_child(stand_idx);

###########################################################
#
# Networking
#
###########################################################

#
# Loads a player puppet onto the stand of index |stand_idx| (Lobby/PlayerPuppet.gd)
# an networking expansion of Stand_load_PlayerPuppet
# -> Returns the loaded body.
#
remote func __Stands_NET_load_PlayerPuppet (stand_idx: int, character: int, nick: String, ready: bool, network_master: int) -> KinematicBody2D:
	var stand : Control = Stands_get_stand(stand_idx);
	stand.name = nick;
	stand.set_network_master(network_master);

	var player = stand.Stand_load_PlayerPuppet(nick);
	player.script = __SG.script_PlayerPuppet;
	player.notification(NOTIFICATION_READY);
	player.PlayerPuppet_set_character(character);

	if ready:
		stand.__Stand_NET_Player_ready();
	
	var net_player = __SG.__G.NetPlayer.new();
	net_player.peer = network_master;
	net_player.nick = nick;
	net_player.character = character;
	__SG.__G.Lobby_add_player(net_player);

	return player;

#
# Loads a player master onto the stand of index |stand_idx| (Lobby/PlayerMaster.gd),
# an networking expansion of Stand_load_PlayerMaster
# -> Returns the loaded body
#
remote func __Stands_NET_load_PlayerMaster (stand_idx: int) -> KinematicBody2D:
	var stand : Control = Stands_get_stand(stand_idx);
	stand.name = __SG.__G.player.nick;
	stand.set_network_master(get_tree().get_network_unique_id());
	
	var player = stand.Stand_load_PlayerMaster(__SG.__G.player.nick);
	player.script = __SG.script_PlayerMaster;
	player.notification(NOTIFICATION_READY);

	return player;
	
#
# Request from the server to an specific client, to load the puppets for the client on all the other peers.
# Required, because the server doesn't know client's plrdata.
#
remote func __Stands_NET_redistribute_master_puppet (stand_idx: int) -> void:
	rpc("__Stands_NET_load_PlayerPuppet",
		stand_idx,
		__SG.Player_starting_character,    # character
		__SG.__G.player.nick,              # nick
		false,                             # ready
		get_tree().get_network_unique_id() # network_master
	);

#
# Called (only on the server), when a peer connects.
#
func __on_network_peer_connected (id: int) -> void:
	var peers = get_tree().get_network_connected_peers();
	rpc_id(id, "__Stands_NET_load_PlayerMaster", peers.size()); #load master on client
	rpc_id(id, "__Stands_NET_redistribute_master_puppet", peers.size()); #load puppets for everyone, besides client

	# Load the already connected players, for the new client
	for i in range(peers.size()):
		var stand = Stands_get_stand(i);
		var plr = stand.Stand_get_player();
		rpc_id(id, "__Stands_NET_load_PlayerPuppet", i, plr.character, stand.name, plr.ready, stand.get_network_master());

	__SG.__SG_Host_can_start(false);

###########################################################
#
# Godot
#
###########################################################

func _ready ():
	if get_tree().is_network_server():
		yield(__SG, "ready"); #why is plrdata null???
		set_network_master(0);
		__Stands_NET_load_PlayerMaster(0);
		get_tree().connect("network_peer_connected", self, "__on_network_peer_connected");
