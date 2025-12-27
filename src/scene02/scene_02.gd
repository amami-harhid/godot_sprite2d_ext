extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_loop_next_scene()
	
	#var list = _hidouki.get_object().get_signal_list()
	#for a in list:
	#	print(a)
	_hidouki()
	pass
	

var _hidouki_val = false

func _hidouki() -> bool: 
	await ThreadUtils.sleep(3)
	_hidouki_val = true	
	return true

func _physics_process(delta: float) -> void:
	#print("_hidouki_val=", _hidouki_val)
	#var time_start = Time.get_unix_time_from_system()
	ThreadUtils.waitNextFrame.emit()
	#var size = ThreadUtils.waitNextFrame.get_connections().size()
	#print("size=",size)
	#ThreadUtils.waitNextFrame1.emit()

func _loop_next_scene()->void:
	await ThreadUtils.sleep(0.5)
	visible = true
	while true:
		if Input.is_action_pressed("key_space"):
			break
		await ThreadUtils.waitNextFrame

	visible = false
	ScenesManager.load_scene01()
