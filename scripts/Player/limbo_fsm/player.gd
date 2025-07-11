extends CharacterBody3D


@export var main_sm : LimboHSM

@onready var idle_state = $LimboHSM/idle

var speed = 1.0
var gravity = -1
const jump_power = 5
var dir


func _ready():
	_initialize_state_machine()

func _physics_process(delta: float) -> void:
	dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	velocity.y += gravity
	flip_sprite(dir)
	move_and_slide()

func flip_sprite(dir):
	if dir != 0:
		# Cherche dans l'arbre du personnage, pas forcément direct
		var sprite = get_node_or_null("Sprite")
		if sprite == null:
			sprite = get_node_or_null("AnimatedSprite3D") # si le nom change à un moment ça devrait pas tout casesr grâce à ça

		if sprite:
			if dir > 0:
				sprite.scale.x = abs(sprite.scale.x)
			else:
				sprite.scale.x = -abs(sprite.scale.x)
		else:
			print("Sprite node not found on player")



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		main_sm.dispatch(&"to_jump")

func _initialize_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	var idle_state = LimboState.new().named("idle_state").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_state = LimboState.new().named("walk_state").call_on_enter(walk_start).call_on_update(walk_update)
	var run_state = LimboState.new().named("run_state").call_on_enter(run_start).call_on_update(run_update)
	var jump_state = LimboState.new().named("jump_state").call_on_enter(jump_start).call_on_update(jump_update)
	var fall_state = LimboState.new().named("fall_state").call_on_enter(fall_start).call_on_update(fall_update)
	var dash_state = LimboState.new().named("dash_state").call_on_enter(dash_start).call_on_update(dash_update)
	
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(run_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(fall_state)
	main_sm.add_child(dash_state)
	
	main_sm.initial_state = idle_state
	
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended")
	main_sm.add_transition(idle_state, jump_state, &"to_jump")
	main_sm.add_transition(walk_state, jump_state, &"to_jump")
	main_sm.add_transition(run_state, jump_state, &"to_jump")
	
	main_sm.initialize(self)
	main_sm.set_active(true)
	

func idle_start():
	print("idle start")
	# faire une var pour le animated sprite puis faire var.play("idle")
func idle_update(delta: float):
	if velocity.x != 0:
		main_sm.dispatch("to_walk")
	
	
	
func walk_start():
	print("walk start")
func walk_update(delta: float):
	if velocity.x == 0:
		main_sm.dispatch(&"state_ended")
	

func run_start():
	print("run start")
	pass
func run_update(delta: float):
	pass

func jump_start():
	print("jump start")
	#animation_sprite.play("jump")
	velocity.y = jump_power
func jump_update(delta: float):
	if is_on_floor():
		main_sm.dispatch(&"state_ended")
	
func fall_start():
	pass
func fall_update(delta: float):
	pass
	
func dash_start():
	pass
func dash_update(delta: float):
	pass
