extends Node2D
	
func _physics_process(delta: float) -> void:
	ThreadUtils.waitNextFrame.emit(delta)  # 引数は意味なし
