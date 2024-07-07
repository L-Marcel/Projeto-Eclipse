class_name Bullet
extends RigidBody2D

@export var stream : Sprite2D;

var soundwave : PackedScene = Scenes.get_resource("Soundwave");
var impact : PackedScene = Scenes.get_resource("BulletImpact");

func _ready():
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.75);
	tween.tween_callback(queue_free);
	tween.play();
	await get_tree().create_timer(0.1).timeout;
	stream.visible = true;

func configure_as_ally(body : Node2D):
	add_collision_exception_with(body);
	var invisible_walls = body.get_tree().get_nodes_in_group("invisible_wall");
	for wall in invisible_walls:
		add_collision_exception_with(wall);
	var allies = body.get_tree().get_nodes_in_group("player");
	for ally in allies:
		if ally != body:
			add_collision_exception_with(ally);

func configure_as_enemy(body : Node2D):
	add_collision_exception_with(body);
	var invisible_walls = body.get_tree().get_nodes_in_group("invisible_wall");
	for wall in invisible_walls:
		add_collision_exception_with(wall);
	var mobs = body.get_tree().get_nodes_in_group("mob");
	for mob in mobs:
		if !mob is Player && mob != body:
			add_collision_exception_with(mob);

func _physics_process(delta):
	var collision = move_and_collide(linear_velocity * delta, true);
	if collision:
		var collider = collision.get_collider();
		if collider.has_node("Hurtbox"):
			var hurtbox = collider.get_node("Hurtbox");
			damage(hurtbox);
		var soundwave_instance = soundwave.instantiate() as Soundwave;
		soundwave_instance.global_position = collision.get_position();
		get_parent().add_child(soundwave_instance);
		var impact_instance = impact.instantiate() as BulletImpact;
		impact_instance.global_position = collision.get_position();
		impact_instance.rotation = collision.get_normal().angle();
		get_parent().add_child(impact_instance);
		soundwave_instance.set_danger(1);
		soundwave_instance.play(
			16.0,
			48.0
		);
		queue_free();

func damage(target : Hurtbox):
	target.health.hurt(max(randi_range(2, 4), 0));
