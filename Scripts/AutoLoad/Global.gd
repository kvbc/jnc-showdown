extends Node;

onready var sfx_button_click = $Sound/Effects/button_click;
onready var sound_music_theme = $Sound/music_theme;

###########################################################
#
# Player
#
###########################################################

const PLAYER_SPEED : float = 30000.0;

enum Player_Character {
	GREG,
	KAMIL,
	CYRUL,
	LEH
};

enum PlayerState {
	WALK,
	IDLE
};

func Player_character_codename (code: int) -> String:
	match code:
		Player_Character.GREG:  return "greg";
		Player_Character.KAMIL: return "kamil";
		Player_Character.CYRUL: return "cyrul";
		Player_Character.LEH:   return "leh";
	return "undefined";
	
func Player_character_animname (character:int, animname:String) -> String:
	return Player_character_codename(character) + '-' + animname;

func Player_get_character_voiceline (character:int, name: String):
	return $Sound/Player/Voicelines.get_node(Player_character_codename(character)).get_node(name);

const PLAYER_SKILL_BURP_SPEED : float = 200.0;
const PLAYER_SKILL_BURP_SEGMENTS : int = 10;

###########################################################
#
# Networking
#
###########################################################

class NetPlayer:
	var peer : int;
	var nick : String;
	var character : int;
	var punching : bool = false;
	var state : int = PlayerState.IDLE;

var player : NetPlayer = NetPlayer.new();
var lobby : Array;

func Lobby_add_player (_player : NetPlayer) -> NetPlayer:
	lobby.append(_player);
	return _player;
