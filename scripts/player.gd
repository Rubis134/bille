extends CharacterBody3D

const SPEED = 1.0
const RUN_SPEED = 2.0
const GRAVITY = 9.8
const JUMP_VELOCITY = 3.0
const DASH_SPEED = 3.0
const DASH_TIME = 0.2
const GLIDE_TIME = 2.5
const GLIDE_GRAVITY_MULTIPLIER = 0.3
const GLIDE_START_DELAY = 0.3

var is_jumping = false
var can_double_jump = true
var is_dashing = false
var dash_timer = 0.0
var is_crouching = false
var is_gliding = false
var glide_timer = 0.0
var glide_start_timer = 0.0
var glide_pending = false
var current_anim = ""

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()

	var sprite = get_node_or_null("Sprite")
	if sprite and input_dir.x != 0:
		sprite.flip_h = input_dir.x < 0

	# Reset quand au sol ou mur
	if is_on_floor() or is_on_wall():
		is_gliding = false
		glide_timer = 0.0
		glide_start_timer = 0.0
		glide_pending = false
		can_double_jump = true
		is_jumping = false

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		_play_anim("dash")
	else:
		var current_speed = SPEED
		if is_crouching:
			current_speed = SPEED / 2.0
		elif Input.is_action_pressed("run"):
			current_speed = RUN_SPEED

		var target_speed = input_dir * current_speed

		if is_on_floor():
			velocity.x = lerp(velocity.x, target_speed.x, 0.3)
			velocity.z = lerp(velocity.z, target_speed.z, 0.3)
		else:
			velocity.x = lerp(velocity.x, target_speed.x, 0.1)
			velocity.z = lerp(velocity.z, target_speed.z, 0.1)

		if is_on_floor():
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				is_jumping = true
				_play_anim("jump")
			else:
				if input_dir.length() > 0:
					if Input.is_action_pressed("run"):
						_play_anim("run")
					else:
						_play_anim("walk")
				else:
					if is_crouching:
						_play_anim("crouch_idle")
					else:
						_play_anim("idle")
		else:
			# Gérer le délai avant glide
			if glide_pending:
				glide_start_timer += delta
				if glide_start_timer >= GLIDE_START_DELAY:
					is_gliding = true
					glide_pending = false
					glide_timer = 0.0

			if is_gliding:
				glide_timer += delta
				if glide_timer >= GLIDE_TIME:
					is_gliding = false
				_play_anim("glide")
			else:
				_play_anim("in_air")

			# Double saut et mise en attente de glide après délai
			if is_jumping and can_double_jump and Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				can_double_jump = false
				glide_pending = true
				glide_start_timer = 0.0
				_play_anim("double_jump")

		# Gravité réduite si glide
		var gravity_multiplier = 1.0
		if is_gliding:
			gravity_multiplier = GLIDE_GRAVITY_MULTIPLIER
		velocity.y -= GRAVITY * gravity_multiplier * delta

		is_crouching = Input.is_action_pressed("crouch")

		if Input.is_action_just_pressed("dash"):
			is_dashing = true
			dash_timer = DASH_TIME
			velocity = input_dir * DASH_SPEED
			velocity.y = 0
			_play_anim("dash")

	move_and_slide()

func _play_anim(name):
	if current_anim == name:
		return
	current_anim = name
	print("Anim : " + name)
	# $AnimatedSprite3D.play(name)  # décommente si tu utilises AnimatedSprite3D
