extends Node
# Base interface for a generic state machine.
# It handles initializing, setting the machine active or not
# delegating _physics_process, _input calls to the State nodes,
# and changing the current/active state.
# See the PlayerV2 scene for an example on how to use it.

signal state_changed(current_state)

@export var start_state: NodePath
var states_map = {}

var states_stack = []
var current_state = null
var _active = false:
	set(value):
		_active = value
		set_active(value)

func _enter_tree():
	if start_state.is_empty():
		start_state = get_path_to(get_child(0))  # ✅ Correction ici

	for child in get_children():
		states_map[child.name] = child           # ✅ Ajout ici
		var err = child.finished.connect(_change_state)
		child.player = get_parent()
		if err:
			printerr(err)

	initialize(start_state)

func initialize(initial_state):
	_active = true
	states_stack.push_front(get_node(initial_state))
	current_state = states_stack[0]
	current_state.enter()

func set_active(value):
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null

func _unhandled_input(event):
	current_state.handle_input(event)

func _physics_process(delta):
	current_state.update(delta)

func _on_animation_finished(anim_name):
	if not _active:
		return
	current_state._on_animation_finished(anim_name)

func _change_state(state_name):
	if not _active:
		return
	if current_state == states_map[state_name]:
		return  # ✅ Évite les transitions inutiles vers le même état

	current_state.exit()

	if state_name == "previous":
		states_stack.pop_front()
	else:
		states_stack[0] = states_map[state_name]

	current_state = states_stack[0]
	state_changed.emit(current_state)

	if state_name != "previous":
		current_state.enter()
