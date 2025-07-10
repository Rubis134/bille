extends Node
# Base interface for all states: it doesn't do anything by itself,
# but forces us to pass the right arguments to the methods below
# and makes sure every State object had all of these methods.


var player : CharacterBody3D

# warning-ignore:unused_signal
signal finished(next_state_name)

# Initialize the state. E.g. change the animation.
func enter():
	print("enter idle mode")
	#Animation


# Clean up the state. Reinitialize values like a timer.
func exit():
	print("exit idle mode")


func handle_input(_event):
	pass


func update(_delta):
	pass


func _on_animation_finished(_anim_name):
	pass




func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit("run")
	elif Input.is_action_pressed("jump"):
		finished.emit("jump")
	else:
		finished.emit("idle")
