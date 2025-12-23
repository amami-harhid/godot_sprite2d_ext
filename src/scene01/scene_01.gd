extends Node2D

#signal signal_process_loop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_loop_next_scene()

const TIME: float = 1.0/30   # FPS = 30

var timer = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > TIME:
		timer -= TIME
		ThreadUtils.signal_process_loop.emit()
		
func _loop_next_scene()->void:
	await ThreadUtils.sleep(0.5)
	visible = true
	while true:
		if Input.is_action_just_pressed("key_space"):
			break
		await ThreadUtils.signal_process_loop
	
	visible = false
	ScenesManager.load_scene02()
