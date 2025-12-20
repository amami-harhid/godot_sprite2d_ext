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
		#next_svg_tex()
		if Input.is_action_just_pressed("key_escape"):
			break
		if Input.is_action_just_pressed("key_left"):
			self.position.x -= 0.3
		if Input.is_action_just_pressed("key_right"):
			self.position.x += 0.3
		#await sleep(0.5)
		await _top.signal_process_loop
		
func _loop02() -> void:
	var counter = 0
	var label:Label = $"/root/Node2D/Label"
	var circle :Sprite2D = $"/root/Node2D/Circle"
	circle.visible = false # 隠す
	#circle.modulate = Color(0, 0, 1) # 青くする
	#circle.position = Vector2(0,0)
	var target:Sprite2DExt = $"/root/Node2D/Niwatori"
	while true:
		counter+=1
		# 1秒ごと（Niwatoriのコスチューム切り替えのタイミングで、falseになる. なぜかな？
		var hitter:Hit = self._is_pixel_touched(target, counter)
		if hitter.hit == true:
			#circle.position = hitter.position 
			circle.position = hitter.position
			circle.visible = true
			label.text = "Hit!"
		elif hitter.position.x == INF:
			label.text = ""
			circle.visible = false
		else:
			label.text = "Neighborhood!"
			circle.visible = false
			
		
		await _top.signal_process_loop
	

func _loop03() -> void:
	while draggable:
		self._drag_process()
		
		#if Input.is_action_just_pressed("key_escape"):
		#	break
		await _top.signal_process_loop
