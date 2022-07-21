extends Node2D

enum State {
	throwing,
	hooking,
	pulling_back,
	pulling_in,
	idle
};

export var throwing_speed = 1.0;

var origin_point = Vector2.ZERO;
var target_point = Vector2.ZERO;
var velocity = Vector2.ZERO;
var direction = Vector2.ZERO;
var state = State.idle;
var enabled = false;

var __last_state = State.idle;
var _throwing = false;

onready var line = get_tree().root.get_node("Game").get_node("gh-line");

func set_state (_state):
	__last_state = state;
	state = _state;

###########################################################
#
# Check
#
###########################################################

func is_hooked () -> bool:
	return state == State.pulling_in;

func is_just_hooked () -> bool:
	return is_hooked() and (__last_state != state);

###########################################################
#
# Update
#
###########################################################

# Update the direction, given the target and hook position 
func update_direction ():
	direction = (target_point - global_position).normalized();

###########################################################
#
# Visibility
#
###########################################################

func show ():
	self.visible = true;
	line.visible = true;
	
func hide ():
	self.visible = false;
	line.visible = false;

###########################################################
#
# Modify
#
###########################################################

# Throw the grappling hook - does not collide at all
func throw (_origin_point, _target_point):
	show();
	enabled = true;
	origin_point = _origin_point;
	target_point = _target_point;
	update_direction();
	_throwing = true;
	set_state(State.throwing);

# Hook the grappling hook - will collide at some point (no pun intended)
func hook (_origin_point, _target_point):
	show();
	enabled = true;
	origin_point = _origin_point;
	target_point = _target_point;
	update_direction();
	_throwing = false;
	set_state(State.hooking);

func reset () -> void:
	origin_point = Vector2.ZERO;
	target_point = Vector2.ZERO;
	direction = Vector2.ZERO;
	velocity = Vector2.ZERO;
	set_state(State.idle);
	_throwing = false;
	enabled = false;
	hide();

###########################################################
#
# Physics
#
###########################################################

# Will the sprite pass through the target point, at the next physics iteration?
func _will_pass () -> bool:
	var will = false;
	if (direction < Vector2.ZERO): will = (global_position + velocity <= target_point - velocity);
	else:                          will = (global_position + velocity >= target_point - velocity);
	return will;

func _physics_process (delta):
	if not enabled:
		return;
	
	velocity += direction * throwing_speed;
	
	if _will_pass():
		if _throwing:
			if state == State.pulling_back:
				global_position = origin_point;
				reset();
				return;
			target_point = origin_point;
			velocity = Vector2.ZERO;
			update_direction();
			set_state(State.pulling_back);
		else:
			global_position = target_point;
			line.set_point_position(1, target_point);
			set_state(State.pulling_in);
			return;
	position += velocity;
	line.set_point_position(1, global_position);
