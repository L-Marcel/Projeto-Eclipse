@tool
class_name Enemy
extends CharacterBody2D

@export var yellow : bool = false;
@export var yellow_sprite_frames : SpriteFrames;

@export_group("Components")
@export var sprite : AnimatedSprite2D;
@export var states : StateChart;
@export var hurtbox : Hurtbox;
@export var fire_point : FirePoint;
@export var view : View;
@export var flash : Flash;
@export var health : Health;
@export var interaction : Interaction;

@export_group("Sound")
@export var alert_sound : AudioStreamPlayer;
@export var gun_fire_sound : AudioStreamPlayer;

@export_group("Patrol")
@export var with_light : bool = true;
@export var patrol : bool = false;
@export var patrol_delay_range : Vector2 = Vector2(3.0, 5.0);
@export var walk_in_patrol : bool = false;
@export var max_walk_distance : float = 124.0;
var walked_distance : float = 0.0;
@export var always_crouch_when_stop : bool = false :
	set(value):
		always_crouch_when_stop = value;
		if Engine.is_editor_hint() && always_crouch_when_stop:
			sprite.animation = "crouch";
			sprite.frame = 2;
		elif Engine.is_editor_hint():
			sprite.animation = "idle";
			sprite.frame = 0;
var target_direction : float = 0.0;

@export var flipped : bool = false :
	set(value):
		if flipped != value && !Engine.is_editor_hint() && flash:
			flash.on = false;
		flipped = value;
		if Engine.is_editor_hint():
			flip(flipped);
var step_frame : int = 0;

var target : Player = null;
var soundwave : PackedScene = Scenes.get_resource("Soundwave");
var bullet : PackedScene = Scenes.get_resource("Bullet");

const SPEED = 100.0;
const JUMP_VELOCITY = -400.0;

var alerted : bool = false :
	set(value):
		alerted = value;
		if alerted && alert_sound:
			alert_sound.play();
		if alerted && interaction && sprite && sprite.animation != "death":
			interaction.unregistry();
var fire_delay : float = 0.25;
var can_fire : bool = true :
	set(value):
		can_fire = value;
		if !can_fire:
			await get_tree().create_timer(fire_delay).timeout;
			can_fire = true;

func _ready():
	if Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_DISABLED;
	else:
		Mobs.registry(self);
		if yellow:
			health._limit = 24;
			health._base = 24;
			health.set_total(24);
			sprite.sprite_frames = yellow_sprite_frames;
		hurtbox.shape = hurtbox.shape.duplicate();
		process_mode = Node.PROCESS_MODE_INHERIT;
		interaction.registry(on_green_phantom_interact);
		view.target_changed.connect(on_target_changed);
		view.without_light = !with_light;
		start_patrol();

#region Control
func on_target_changed():
	stop_patrol();
	if sprite.animation == "death" || !is_instance_valid(view):
		return;
	if view.target && !alerted:
		await get_tree().create_timer(0.5).timeout;
		if sprite.animation == "death" || !is_instance_valid(view):
			return;
		target = view.target;
		if target && !alerted:
			alerted = true;
			Game.enemies_alerted += 1;
	elif view.target:
		target = view.target;
	else:
		target = null;
func on_green_phantom_interact(_by : Node2D):
	if !alerted:
		states.send_event("knockout");
		interaction.unregistry();
		interaction.registry(on_second_green_phantom_interact);
func on_second_green_phantom_interact(_by : Node2D):
	fire_point.queue_free();
	interaction.unregistry();
func alert(_danger : int, origin : Vector2):
	if !alerted:
		await get_tree().create_timer(1.0).timeout;
	if sprite.animation != "death" && !target:
		flip(origin.x - global_position.x < 0);
func fire(precision : float = randf_range(0.0, 1.0)):
	if can_fire && is_instance_valid(view) && is_instance_valid(flash) && view.is_danger() && target:
		flash.on = true;
		var soundwave_instance = soundwave.instantiate() as Soundwave;
		soundwave_instance.global_position = fire_point.global_position;
		get_parent().add_child(soundwave_instance);
		var bullet_instance = bullet.instantiate() as Bullet;
		bullet_instance.configure_as_enemy(self);
		var angle_diff = randf_range(-10, 10) * (1.0 - precision);
		if scale.y == -abs(scale.y):
			bullet_instance.global_position = fire_point.global_position;
			bullet_instance.rotation_degrees = 180 + angle_diff;
		else:
			bullet_instance.rotation_degrees = angle_diff;
			bullet_instance.global_position = fire_point.global_position;
		bullet_instance.linear_velocity = Vector2.from_angle(bullet_instance.rotation) * 800;
		soundwave_instance.set_danger(2);
		soundwave_instance.play(
			32.0,
			124.0
		);
		gun_fire_sound.play();
		get_parent().add_child(bullet_instance);
		can_fire = false;
func flip(yes : bool):
	if sprite.animation == "death":
		return;
	if yes:
		scale.y = -abs(scale.y);
		rotation_degrees = 180;
		if !Engine.is_editor_hint():
			flipped = true;
	else:
		scale.y = abs(scale.y);
		rotation_degrees = 0;
		if !Engine.is_editor_hint():
			flipped = false;
func move():
	var direction = target_direction;
	if direction:
		velocity.x = direction * SPEED;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED);
	if direction != 0:
		flip(direction < 0);
	if target:
		flip(target.global_position.x - global_position.x < 0);
	return direction;
func apply_gravity(delta : float):
	if !is_on_floor():
		velocity += get_gravity() * delta;
func crouch():
	if target || (always_crouch_when_stop && target_direction == 0.0):
		states.send_event("crouch");
func death():
	if health.is_dead():
		states.send_event("death");
func blink():
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("whitten", !sprite.material.get_shader_parameter("whitten"));
func stop_blink():
	if sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("whitten", false);
#endregion
#region Patrol
func stop_patrol():
	target_direction = 0.0;
func start_patrol():
	if patrol && !alerted && sprite.animation != "death":
		await get_tree().create_timer(randf_range(patrol_delay_range.x, patrol_delay_range.y)).timeout;
		if !walk_in_patrol || (walk_in_patrol && randi() % 100 >= 50):
			flip(!flipped);
		else:
			target_direction = 1.0 if flipped else -1.0;
		start_patrol();
#endregion

func _physics_process(delta):
	walked_distance += abs(velocity.x) * delta;
	if walked_distance >= max_walk_distance:
		walked_distance = 0.0;
		target_direction = 0.0;
	apply_gravity(delta);
	move_and_slide();

#region Entered
func _on_idle_state_entered():
	sprite.play("idle");
func _on_run_state_entered():
	sprite.play("run");
func _on_jump_state_entered():
	sprite.play("jump");
func _on_fall_state_entered():
	sprite.play("fall");
func _on_crouch_state_entered():
	sprite.play("crouch");
func _on_death_state_entered():
	Game.enemies_alerted -= 1;
	interaction.unregistry();
	interaction.registry(on_second_green_phantom_interact);
	sprite.play("death");
	set_collision_layer_value(1, false);
	view.enemy_can_be_furtive = true;
func _on_knockout_state_entered():
	Game.enemies_alerted -= 1;
	sprite.play("death");
	set_collision_layer_value(1, false);
	view.enemy_can_be_furtive = true;
#endregion
#region Processing
func _on_idle_state_processing(_delta):
	death();
	fire(0.75);
	crouch();
	var direction = move();
	if direction != 0:
		states.send_event("run");
func _on_run_state_processing(_delta):
	death();
	fire(0.5);
	crouch();
	var direction = move();
	if direction == 0:
		states.send_event("idle");
func _on_jump_state_processing(_delta):
	death();
	fire(0.25);
	move();
	if velocity.y >= 0:
		states.send_event("fall");
func _on_fall_state_processing(_delta):
	death();
	fire(0.25);
	move();
	if is_on_floor():
		states.send_event("idle");
func _on_crouch_state_processing(delta):
	death();
	fire(1.0);
	var direction = target_direction;
	velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
	if direction != 0:
		flip(direction < 0);
	if target:
		flip(target.global_position.x - global_position.x < 0);
	if !is_on_floor():
		states.send_event("fall");
	elif (!target && !always_crouch_when_stop) || (direction != 0.0 && always_crouch_when_stop):
		states.send_event("idle");
func _on_death_state_processing(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
func _on_knockout_state_processing(delta):
	_on_death_state_processing(delta);

#endregion
#region Exited
func _on_run_state_exited():
	step_frame = -1;
#dendregion

#region Others
func _on_health_damaged():
	if !alerted:
		alerted = true;
		Game.enemies_alerted += 1;
func _on_health_invencibility_tick():
	blink();
func _on_health_invencibility_finished():
	stop_blink();
#endregion
