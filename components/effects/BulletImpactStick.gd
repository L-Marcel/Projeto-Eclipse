class_name BulletImpactStick
extends RigidBody2D

func configure(angle : float, external_angle : float):
	var radians = deg_to_rad(angle);
	rotation = radians;
	linear_velocity = Vector2.from_angle(rotation + external_angle) * 400;
func _ready():
	await get_tree().create_timer(0.05 + randf_range(-0.02, 0.01)).timeout;
	queue_free();
