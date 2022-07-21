extends Control;

onready var __port : LineEdit = $Port/LineEdit;
onready var __nick : LineEdit = $Nick/LineEdit;
onready var __accept : Button = $Accept;

onready var __G = $"/root/AutoLoad_Global";

func __get_port () -> int:
	return int(__port.text);

func __accept_press () -> void:
	__accept.disconnect("pressed", self, "__accept_press");
	var peer = NetworkedMultiplayerENet.new();
	var err = peer.create_server(__get_port(), 4);
	assert(err == OK, "host error " + str(err));
	get_tree().network_peer = peer;
	$"/root/UI/TransitionBackground".fade_in();
	__G.player.peer = get_tree().get_network_unique_id();
	__G.player.nick = __nick.text;
	yield(get_tree().create_timer(3.0), "timeout");
	get_tree().change_scene("res://Scenes/Lobby.tscn");

func _ready () -> void:
	__accept.connect("pressed", self, "__accept_press");
