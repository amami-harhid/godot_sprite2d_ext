# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.svg_file_path_setting([
		"res://assets/crab-a.svg",
		"res://assets/crab-b.svg",
	])
	position.x = 1000
	position.y = 500
	self.current_svg_tex()

	# 無限ループスレッドを起動（３個）
	_loop01()
	_loop02()
	_loop03()
	pass

func _loop01() -> void :
	while true:
		await sleep(0.5)
		next_svg_tex()
		if Input.is_action_just_pressed("key_escape"):
			break
		await signal_process_loop
		
func _loop02() -> void:
	var target:Sprite2DExt = $"/root/Node2D/Niwatori"
	while true:
		if self._is_pixel_touched(target) :
			self.modulate = Color(0.5, 0.5, 0.5) # やや暗くする
		else:
			self.modulate = Color(1, 1, 1) # 元の色に変える
			
		if Input.is_action_just_pressed("key_escape"):
			break
		await signal_process_loop
	
	self.modulate = Color(1, 1, 1) # 元の色に変える

func _loop03() -> void:
	while draggable:
		self._drag_process()
		
		if Input.is_action_just_pressed("key_escape"):
			break
		await signal_process_loop
