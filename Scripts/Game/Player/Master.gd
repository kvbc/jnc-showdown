###########################################################
#
# Game :: Player :: Master :: Base.gd
#
###########################################################

extends RigidBody2D;

onready var __G  : Node = $"/root/AutoLoad_Global";
onready var __SG : Node = $"/root/Game";

onready var Puppet = preload("res://Scripts/Game/Player/Puppet.gd").new(self);
onready var Base = Puppet.Base;

###########################################################
#
# Player Utility
#
###########################################################

func Player_is_on_floor () -> bool:
	return !get_world_2d().direct_space_state.intersect_ray(
		global_position,
		global_position + Vector2(0.0, 100.0),
		[self]
	).empty();

func Player_is_walking () -> bool: return Base.net.state == __G.PlayerState.WALK;
func Player_is_idlying () -> bool: return Base.net.state == __G.PlayerState.IDLE;

###########################################################
#
# General Networking
#
###########################################################

remotesync func __PlayerNET_impulse (dir: Vector2) -> void:
	apply_central_impulse(dir);

puppetsync func __PlayerNET_play_animation (animname_top: String, animname_bot: String) -> void:
	Base.animtop.play(animname_top);
	Base.animbot.play(animname_bot);

puppetsync func __PlayerNET_update_walking_animation (flip: bool, already_walking: bool) -> void:
	if flip:
		Base.animtop.flip_h = bool(int(Base.animtop.flip_h) ^ 1);
		Base.animbot.flip_h = bool(int(Base.animbot.flip_h) ^ 1);
	if not already_walking:
		Base.animtop.play(__G.Player_character_animname(Base.net.character, "static"));
		Base.animbot.play(__G.Player_character_animname(Base.net.character, "walk"));

###########################################################
#
# Skill
#
###########################################################

#
# PlayerLocal
#

func __Player_Skill_Guitar_on_body_enter (body) -> void:
	if body == self:
		return;
	yield(get_tree().create_timer(0.0), "timeout");
	apply_central_impulse(-_gtr_dir * 1000);

func __PlayerMasterLocal_Skill_Guitar_ready () -> void:
	gtr.connect("body_entered", self, "Player_skill_guitarpogo_on_body_enter");
	
#
# PlayerNET :: Burp
#

puppetsync func __Player_NET_skill_burp (mouse_pos:Vector2) -> void:
	var plr = Game_get_player(id);
	var burp = plr.get_node("Burp");
	burp.reset();
	burp.enable();
	var dir = (mouse_pos - burp.global_position).normalized();
	burp.direction = dir;
	burp.update_rotation(mouse_pos);

#
# PlayerNET :: GraplingHook
#

remotesync func Game_NET_Player_skill_gh (id: int, mouse_pos: Vector2) -> void:
	var plr = get_node("player-" + str(id));
	gh.reset();
	gh.global_position = plr.global_position;
	ghline.set_point_position(0, gh.global_position);

	var dir = (mouse_pos - gh.global_position).normalized();
	var collision = plr.get_world_2d().direct_space_state.intersect_ray(gh.global_position, gh.global_position + dir * 500, [plr]);
	if collision.empty():
		var pos = mouse_pos;
		if mouse_pos.x > dir.x*500: pos.x = gh.global_position.x + dir.x*500;
		if mouse_pos.y > dir.y*500: pos.y = gh.global_position.y + dir.y*500;
		gh.throw(plr.global_position, pos);
		return;

	gh.hook(plr.global_position, collision.position);

remotesync func Game_NET_Player_skill_gh_update (id: int, delta: float) -> void:
	var plr = get_node("player-" + str(id));
	ghline.set_point_position(0, plr.global_position);
	
	if gh.is_hooked():
		gh.direction = (gh.target_point - plr.global_position - Vector2(0.0, 50.0)).normalized();
		if get_tree().get_network_unique_id() == id:
			plr.linear_velocity += gh.direction * E_gh_pull_speed * delta;
		var distance = (plr.global_position - gh.target_point).abs();
		if distance.x <= 30.0:
			gh.reset();
	
	if gh.state == gh.State.pulling_back:
		gh.target_point = plr.global_position;
		gh.update_direction();

remotesync func Game_NET_Player_skill_gh_cancel () -> void:
	var gh = get_node("gh");
	gh.reset();

#
# PlayerNET :: Guitar
#

remotesync func Game_NET_Player_skill_guitarpogo (id:int) -> void:
	var plr = Game_get_player(id);
	var gtr = plr.get_node("Guitar");
	gtr.enable(not gtr.is_enabled());
	
remotesync func Game_NET_Player_skill_guitarpogo_update (id:int, mouse_pos:Vector2) -> void:
	var plr = Game_get_player(id);
	var gtr = plr.get_node("Guitar");
	gtr.look_at(mouse_pos);

#
# PlayerNET :: Yoyo
#

remotesync func Game_NET_Player_skill_jojo (id: int, mouse_pos: Vector2) -> void:
	var plr = get_node("player-" + str(id));
	jojo.reset();
	jojo.global_position = plr.global_position;
	jojoline.set_point_position(0, jojo.global_position);
	jojo.line = jojoline; #bruh
	jojo.get_node("CollisionShape2D").disabled = true;
	
	var dir = (mouse_pos - jojo.global_position).normalized();
	var collision = plr.get_world_2d().direct_space_state.intersect_ray(jojo.global_position, jojo.global_position + dir * 100, [plr]);
	if collision.empty():
		var pos = mouse_pos;
		if mouse_pos.x > dir.x*100: pos.x = jojo.global_position.x + dir.x*100;
		if mouse_pos.y > dir.y*100: pos.y = jojo.global_position.y + dir.y*100;
		jojo.hook(plr.global_position, pos);
		return;
	
	jojo.throw(plr.global_position, collision.position);
	
remotesync func Game_NET_Player_skill_jojo_update (id: int, delta: float) -> void:
	var plr = get_node("player-" + str(id));
	jojoline.set_point_position(0, plr.global_position);
	
	if jojo.is_hooked ():
		jojo.get_node("CollisionShape2D").disabled = false;

#
# Player
#

func Player_skill_ready () -> void:
	match Puppet.PlayerPuppet.character:
		__G.Player_Character.CYRUL: Player_skill_guitarpogo_ready();
	
###########################################################
#
# Punch
#
###########################################################

func __Player_Punch_on_body_enter (body):
	if body == self:
		return;
	if not body.is_in_group("players"):
		return;
	__SG.rpc("Game_NET_Player_on_punch", body.Puppet.PlayerPuppet._peer);

#
# PlayerNET
#

remotesync func Game_NET_Player_on_punch (id: int):
	var plr = Game_get_player(id); 
	plr.Puppet.PlayerPuppet.animtop.material.set_shader_param("flash", true);
	plr.Puppet.PlayerPuppet.animbot.material.set_shader_param("flash", true);
	yield(get_tree().create_timer(0.15), "timeout");
	plr.Puppet.PlayerPuppet.animtop.material.set_shader_param("flash", false);
	plr.Puppet.PlayerPuppet.animbot.material.set_shader_param("flash", false);

remotesync func Game_NET_Player_punch (id: int):
	var plr = Game_get_player(id);
	plr.Puppet.punching = true;
	plr.Puppet.hand_enable();
	
	var mouse_pos = plr.get_global_mouse_position();
	var dir = (mouse_pos - plr.global_position).normalized();
	var pos_before = plr.Puppet.handarea.position;
	plr.Puppet.handarea.look_at(mouse_pos);
	plr.Puppet.handarea.position += dir * 30.0;
	
	yield(get_tree().create_timer(0.25), "timeout");
	
	plr.Puppet.hand_disable();
	plr.Puppet.handarea.rotation = 0.0;
	plr.Puppet.handarea.position = pos_before;
	plr.Puppet.punching = false;

###########################################################
#
# Movement
#
###########################################################

var last_vel = Vector2.ZERO;

func __Player_move (impulse: Vector2, delta: float, flip: bool) -> void:
	friction = 0.0;
	last_vel = impulse * delta;
	linear_velocity += last_vel;
	state = State.WALK;
	rpc("__Player_NET_move", flip, Player_is_walking());

func Player_jump () -> void:
	apply_central_impulse(Vector2.UP * 800);

###########################################################
#
# Standard Godot procedures
#
###########################################################

func _ready () -> void:
	mode = RigidBody2D.MODE_CHARACTER; #lock body rotation
	friction = 0.0;
	Player_skill_ready();
	Puppet.handarea.connect("body_entered", self, "__Player_Punch_on_body_enter");
	
# As godot won't let me move a box 5 pixels to the right 
func _integrate_forces (state):
	if (abs(linear_velocity.x) > 1.0) or (abs(linear_velocity.y) > 1.0):
		get_parent().rpc_unreliable("Game_NET_update_player_actors", Puppet.PlayerPuppet._peer, position);
	if abs(linear_velocity.x) > 300.0:
		linear_velocity -= last_vel;
	last_vel = Vector2.ZERO;
	
func _input (event):
	if event is InputEventMouseMotion:
		if Puppet.PlayerPuppet.character == __G.Player_Character.CYRUL:
			var mouse_pos = get_global_mouse_position(); # i had trouble with event.global_position
			get_parent().rpc("Game_NET_Player_skill_guitarpogo_update", Puppet.PlayerPuppet._peer, mouse_pos);
			_gtr_dir = (mouse_pos - gtr.global_position).normalized();
	
func _physics_process (delta: float) -> void:
	if Input.is_action_pressed("left"):
		__Player_move(Vector2(-speed, 0.0), delta, Puppet.PlayerPuppet.Player_is_facing_right());
	elif Input.is_action_pressed("right"):
		__Player_move(Vector2(speed, 0.0), delta, Puppet.PlayerPuppet.Player_is_facing_left());
	elif not Player_is_idlying():
		state = State.IDLE;
		rpc(
			"__Player_NET_play_animation",
			__G.Player_character_animname(Puppet.PlayerPuppet.character, "idle"),
			__G.Player_character_animname(Puppet.PlayerPuppet.character, "idle")
		);
		
	var on_floor = Player_is_on_floor();
		
	if (Input.is_action_just_released("left") or
		Input.is_action_just_released("right")):
		friction = 1.0;
		
	if Input.is_action_just_pressed("jump"):
		if Puppet.PlayerPuppet.character == __G.Player_Character.GREG:
			get_parent().rpc("Game_NET_Player_skill_gh_cancel");
		if on_floor:
			Player_jump();
				
	if Input.is_action_just_pressed("skill"):
		match Puppet.PlayerPuppet.character:
			__G.Player_Character.GREG:  get_parent().rpc("Game_NET_Player_skill_gh", Puppet.PlayerPuppet._peer, get_global_mouse_position());
			__G.Player_Character.KAMIL:
				get_parent().rpc("Game_NET_Player_skill_burp", Puppet.PlayerPuppet._peer, get_global_mouse_position());
				var dir = (get_global_mouse_position() - $Burp.global_position).normalized();
				if Input.is_action_pressed("skill_burp_rocketjump_trigger"):
					apply_central_impulse(-dir * 1000);
			__G.Player_Character.CYRUL:
				get_parent().rpc("Game_NET_Player_skill_guitarpogo", Puppet.PlayerPuppet._peer);
			__G.Player_Character.LEH:
				get_parent().rpc("Game_NET_Player_skill_jojo", Puppet.PlayerPuppet._peer, get_global_mouse_position());
		
	match Puppet.PlayerPuppet.character:
		__G.Player_Character.GREG: get_parent().rpc("Game_NET_Player_skill_gh_update", Puppet.PlayerPuppet._peer, delta);
		__G.Player_Character.LEH:
			get_parent().rpc("Game_NET_Player_skill_jojo_update", Puppet.PlayerPuppet._peer, delta);

	if Input.is_action_just_pressed("punch") and not Puppet.PlayerPuppet.punching:
		__SG.rpc("Game_NET_Player_punch", Puppet.PlayerPuppet._peer);
