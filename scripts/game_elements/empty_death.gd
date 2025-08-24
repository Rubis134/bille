extends Area3D


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))



func _on_body_entered(body):
	if body is Player: # vérifie que c’est bien ton script Player.gd
		body.main_sm.dispatch(&"to_die")
