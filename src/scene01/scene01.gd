extends Node2D

#signal signal_process_loop()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

const TIME: float = 1.0/30
var timer = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > TIME:
		timer -= TIME
		ThreadUtils.signal_process_loop.emit()
	pass
