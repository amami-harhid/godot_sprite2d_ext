extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_1) :
		ScenesManager.load_scene01()
	elif Input.is_key_pressed(KEY_2):
		ScenesManager.load_scene02()
		
