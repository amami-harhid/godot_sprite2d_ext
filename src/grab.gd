# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	position.x = 1000
	position.y = 500
	costumes.svg_file_path_setting([
		"res://assets/crab-a.svg",
		"res://assets/crab-b.svg",
	])
	costumes.current_svg_tex()

	# 無限ループスレッドを起動（３個）
	_loop01()
	_loop02()
	_loop03()
	_loop04()

func _loop01() -> void :
	while true:
		#next_svg_tex()
		if Input.is_action_just_pressed("key_escape"):
			break
		if Input.is_action_pressed("key_left"):
			self.position.x -= 0.3
		if Input.is_action_pressed("key_right"):
			self.position.x += 0.3
		#await sleep(0.5)
		await TOP.signal_process_loop
		
func _loop02() -> void:
	var counter = 0
	var label:Label = $"/root/Scene01/Label"
	var circle :Sprite2D = $"/root/Scene01/Circle"
	circle.visible = false # 隠す
	#circle.modulate = Color(0, 0, 1) # 青くする
	#circle.position = Vector2(0,0)
	var target:Sprite2DExt = $"/root/Scene01/Niwatori"
	while true:
		# 1秒ごと（Niwatoriのコスチューム切り替えのタイミングで、falseになる. なぜかな？
		var hitter:Hit = costumes._is_pixel_touched(target)
		if hitter.hit == true:
			#circle.position = hitter.position 
			self.modulate = Color(0.1, 0.1, 1, 0.5) # 青くする
			circle.position = hitter.position
			circle.visible = true
			label.text = "Hit!"
		elif hitter.position.x == INF:
			self.modulate = Color(1, 1, 1, 1)
			label.text = ""
			circle.visible = false
		else:
			label.text = "Neighborhood!"
			self.modulate = Color(1, 1, 1, 1)
			circle.visible = false
			
		
		await TOP.signal_process_loop
	

func _loop03() -> void:
	while draggable:
		self._drag_process()
		
		#if Input.is_action_just_pressed("key_escape"):
		#	break
		await TOP.signal_process_loop

func _loop04() -> void :
	while true:
		await sleep(0.5)
		costumes.next_svg_tex()
		await TOP.signal_process_loop
