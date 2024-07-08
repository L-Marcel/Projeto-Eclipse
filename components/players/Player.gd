class_name Player
extends CharacterBody2D

@export var player_one : bool = true :
	set(value):
		player_one = value;
		if player_one:
			key_left = "red_left";
			key_right = "red_right";
			key_jump = "red_up";
			key_down = "red_down";
			key_fire = "red_fire";
			key_interact = "red_interact";
		else:
			key_left = "green_left";
			key_right = "green_right";
			key_jump = "green_up";
			key_down = "green_down";
			key_fire = "green_fire";
			key_interact = "green_interact";
@export var sprite_frames : SpriteFrames;

@export_group("Interaction")
@export var actor : Actor;
@export var actor_collision_shape : CollisionShape2D;
@export var interaction : Interaction;

@export_group("Components")
@export var sprite : AnimatedSprite2D;
@export var states : StateChart;
@export var hurtbox : Hurtbox;
@export var health : Health;

@export_group("Fire")
@export var fire_delay : float = 0.25;
@export var fire_point : FirePoint;
@export var flash : Flash;
@export var gun_fire_sound : AudioStreamPlayer;

@export_group("Step")
@export var step_point : Marker2D;
@export var step_sound_player : AudioStreamPlayer;
@export var step_sounds : Array[AudioStream] = [];
var step_frame : int = 0;
var can_fire : bool = true :
	set(value):
		can_fire = value;
		if !can_fire:
			await get_tree().create_timer(fire_delay).timeout;
			can_fire = true;

@export_group("Visibility")
@export var vision_icon : VisionIcon;
var vision_timer : Timer = Timer.new();
var was_seen : int = 0 :
	set(value):
		was_seen = value;
		update_visibility();
var furtive : bool = false :
	set(value):
		furtive = value;
		if furtive:
			z_index = 0;
		else:
			z_index = 200;
		update_visibility();

const SPEED = 300.0;
const JUMP_VELOCITY = -400.0;

var soundwave : PackedScene = Scenes.get_resource("Soundwave");
var bullet : PackedScene = Scenes.get_resource("Bullet");

var flipped : bool = false :
	set(value):
		if flipped != value && flash:
			flash.on = false;
		flipped = value;
var key_left : String = "red_left";
var key_right : String = "red_right";
var key_jump : String = "red_up";
var key_down : String = "red_down";
var key_fire : String = "red_fire";
var key_interact : String = "red_interact";
var can_cancel_jump : bool = true;

func _ready():
	add_child(vision_timer);
	vision_timer.timeout.connect(_on_vision_timer_timeout);
	Mobs.registry(self);
	sprite.sprite_frames = sprite_frames;
	hurtbox.shape = hurtbox.shape.duplicate();
	actor_collision_shape.shape = hurtbox.shape;
	if !player_one:
		actor.set_collision_mask_value(3, true);
		actor.set_collision_mask_value(4, false);
		health._limit = health._limit/2.0;
		health._base = health._base/2.0;
		health.set_total(health.get_limit());
		interaction.registry(on_player_one_interact);
	else:
		actor.set_collision_mask_value(3, false);
		actor.set_collision_mask_value(4, true);

#region Visibility
func set_was_seen(value : int, duration : float = 2.0):
	if value != 0:
		was_seen = value;
		vision_timer.wait_time = duration if value > 1 else 0.1;
		vision_timer.start();
	else:
		was_seen = value;
		vision_timer.stop();
func update_visibility():
	if was_seen <= 1 && furtive:
		vision_icon.update(false);
		set_collision_layer_value(2, false);
	elif was_seen != 0:
		vision_icon.update(true);
		set_collision_layer_value(2, true);
	else:
		vision_icon.visible = false;
		set_collision_layer_value(2, true);
#endregion
#region Control
func interact():
	if Input.is_action_just_pressed(key_interact) && is_on_floor():
		actor.interact_with_nearest(self);
func on_player_one_interact(_by : Node2D):
	if is_on_floor() && ["idle", "run", "crouch"].has(sprite.animation):
		velocity.y = JUMP_VELOCITY * 1.2;
		states.send_event("jump");
		can_cancel_jump = false;
func fire(precision : float = randf_range(0.0, 1.0)):
	if Input.is_action_pressed(key_fire) && can_fire:
		flash.on = true;
		var soundwave_instance = soundwave.instantiate() as Soundwave;
		soundwave_instance.global_position = fire_point.global_position;
		get_parent().add_child(soundwave_instance);
		var bullet_instance = bullet.instantiate() as Bullet;
		bullet_instance.configure_as_ally(self);
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
		set_was_seen(2, 0.1);
		get_parent().add_child(bullet_instance);
		can_fire = false;
func flip(yes : bool):
	if yes:
		scale.y = -abs(scale.y);
		rotation_degrees = 180;
		flipped = true;
	else:
		scale.y = abs(scale.y);
		rotation_degrees = 0;
		flipped = false;
func step(force : bool = false):
	if (sprite.animation == "run" || force) && step_sounds.size() > 0 && step_frame != sprite.frame && (sprite.frame == 2 || sprite.frame == 5 || force):
		var soundwave_instance = soundwave.instantiate() as Soundwave;
		soundwave_instance.global_position = step_point.global_position;
		get_parent().add_child(soundwave_instance);
		step_sound_player.stream = step_sounds[randi() % step_sounds.size()];
		step_frame = sprite.frame;
		if player_one:
			soundwave_instance.play();
			step_sound_player.volume_db = -25.0;
			step_sound_player.play();
		else:
			soundwave_instance.play(
				soundwave_instance.min_size,
				soundwave_instance.max_size / 2.0
			);
			step_sound_player.volume_db = -30.0;
			step_sound_player.play();
func move():
	var direction = Input.get_axis(key_left, key_right);
	if direction:
		velocity.x = direction * (SPEED if player_one else SPEED * 0.75);
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED);
	if direction != 0:
		flip(direction < 0);
	return direction;
func apply_gravity(delta : float):
	if !is_on_floor():
		velocity += get_gravity() * delta;
func jump():
	if Input.is_action_just_pressed(key_jump) && is_on_floor():
		velocity.y = JUMP_VELOCITY;
		states.send_event("jump");
func crouch():
	if Input.is_action_pressed(key_down):
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

func _physics_process(delta):
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
	set_collision_layer_value(1, false);
	set_collision_layer_value(2, false);
	sprite.play("death");
#endregion
#region Processing
func _on_idle_state_processing(_delta):
	death();
	if !is_on_floor():
		states.send_event("fall");
	interact();
	fire(0.75);
	jump();
	crouch();
	var direction = move();
	if direction != 0:
		states.send_event("run");
func _on_run_state_processing(_delta):
	death();
	if !is_on_floor():
		states.send_event("fall");
	step();
	interact();
	fire(0.5);
	jump();
	crouch();
	var direction = move();
	if direction == 0:
		states.send_event("idle");
func _on_jump_state_processing(_delta):
	death();
	fire(0.25);
	move();
	if !Input.is_action_pressed(key_jump) && can_cancel_jump:
		velocity.y = 0;
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
	if !is_on_floor():
		states.send_event("fall");
	elif !Input.is_action_pressed(key_down):
		states.send_event("idle");
	interact();
	fire(1.0);
	var direction = Input.get_axis(key_left, key_right);
	velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
	if direction != 0:
		flip(direction < 0);
	jump();
func _on_death_state_processing(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 2);
#endregion
#region Exited
func _on_jump_state_exited():
	can_cancel_jump = true;
func _on_fall_state_exited():
	step(true);
	step_frame = -1;
func _on_run_state_exited():
	step(true);
	step_frame = -1;
#endregion

#region Others
func _on_vision_timer_timeout():
	was_seen = 0;
func _on_health_invencibility_tick():
	blink();
func _on_health_invencibility_finished():
	stop_blink();
#endregion
