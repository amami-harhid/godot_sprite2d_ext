extends Node2D

func _physics_process(delta: float) -> void:
	ThreadUtils.waitNextFrame.emit(delta) # 引数は意味なし
	if Input.is_key_pressed(KEY_ESCAPE) :
		ThreadUtils.stop_scene.emit()
		ScenesManager.load_scene_main()
