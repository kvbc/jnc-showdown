extends Area2D;

onready var collision_shape: CollisionShape2D = $CollisionShape2D;

func enable (yes: bool = true) -> void:
	visible = yes;
	monitoring = yes;
	collision_shape.disabled = not yes;
func disable () -> void: enable(false);

func is_enabled () -> bool: return monitoring;
