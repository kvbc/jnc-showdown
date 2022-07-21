extends Control;

onready var __ip   : LineEdit = $IP/LineEdit;
onready var __port : LineEdit = $Port/LineEdit;
onready var __nick : LineEdit = $Nick/LineEdit;
onready var __accept : Button = $Accept;

onready var __G = $"/root/AutoLoad_Global";

func __get_IP () -> String:
	return __ip.text;

func __get_port () -> int:
	return int(__port.text);

func __accept_press () -> void:
	var peer = NetworkedMultiplayerENet.new();
	var err = peer.create_client(__get_IP(), __get_port());
	assert(err == OK, "join error " + str(err));
	get_tree().network_peer = peer;
	__G.player.peer = get_tree().get_network_unique_id();
	__G.player.nick = __nick.text;
	get_tree().change_scene("res://Scenes/Lobby.tscn");
	__accept.disconnect("pressed", self, "__accept_press");

func _ready () -> void:
	__accept.connect("pressed", self, "__accept_press");
