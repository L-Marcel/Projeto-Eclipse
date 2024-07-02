class_name Bullet
extends RigidBody2D

func _ready():
	pass;
	#var tween = get_tree().create_tween();
	#tween.tween_property(self, "modulate.a", 0.0, 10.0);
	#tween.tween_callback(self.queue_free);

func configure_as_ally(body : Node2D):
	add_collision_exception_with(body);
	var allies = body.get_tree().get_nodes_in_group("player");
	for ally in allies:
		if ally != body:
			add_collision_exception_with(ally);

func configure_as_enemy(body : Node2D):
	add_collision_exception_with(body);
	var mobs = body.get_tree().get_nodes_in_group("mob");
	for mob in mobs:
		if !mob is Player && mob != body:
			add_collision_exception_with(mob);

func _physics_process(delta):
	var collision = move_and_collide(linear_velocity * delta);
	if collision:
		queue_free();
