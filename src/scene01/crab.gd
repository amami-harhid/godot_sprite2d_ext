# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

func _ready() -> void:
	super._ready()
	position.x = 1000
	position.y = 500
	# コスチューム画像を読み込む
	costumes.svg_file_path_setting([
		"res://assets/crab-a.svg",
		"res://assets/crab-b.svg",
	])
	# コスチューム画像を描画する
	costumes.current_svg_tex()

	# 無限ループスレッドを起動（５個）
	self._loop01() # 左右矢印キー押下時にX方向に少しだけ移動する
	self._loop02() # ターゲット（ニワトリ）とのBITMAP衝突判定をし続ける
	self._loop03() # ドラッグ可のとき、ドラッグ移動し続ける
	#self._loop04() # 次のコスチュームに切り替え続ける
	#self._loop05() # ターゲットと衝突している間、回転し続ける

# 左右矢印キー押下時にX方向に少しだけ移動する
func _loop01() -> void :
	while true:
		#next_svg_tex()
		if Input.is_action_just_pressed("key_escape"):
			break
		if Input.is_action_pressed("key_left"):
			self.position.x -= 0.1
		if Input.is_action_pressed("key_right"):
			self.position.x += 0.1
		#await sleep(0.5)
		await ThreadUtils.waitNextFrame

# ターゲット（ニワトリ）とのBITMAP衝突判定をし続ける
func _loop02() -> void:
	var label:Label = $"/root/Scene01/Label"
	var circle :Sprite2D = $"/root/Scene01/Circle"
	circle.visible = false  # 小円を隠す
	var target:Sprite2DExt = $"/root/Scene01/Niwatori"
	while true:
		var time_start = ThreadUtils.get_time()
		var hitter:Hit = costumes._is_pixel_touched(target)
		if hitter.hit == true:
			print("time=",ThreadUtils.get_time()-time_start,",surrounding size=",hitter.surrounding_size, ",touch_idx=",hitter.touch_idx)
			# BITMAP衝突しているとき
			self.modulate = Color(0.1, 0.1, 1, 0.5) # 青くする
			circle.position = self.to_global(hitter.position) 
			#circle.visible = true # 小円を見せる
			label.text = "Hit!(当たっている)"
			_rotationer = true # 衝突している
		elif hitter.position.x == INF:
			# 衝突しておらず近傍でもない
			self.modulate = Color(1, 1, 1, 1)
			label.text = ""
			circle.visible = false # 小円を隠す
			_rotationer = false # 衝突していない
		else:
			# 衝突していないが近傍である
			label.text = "Neighborhood!(近傍)"
			self.modulate = Color(1, 1, 1, 1)
			circle.visible = false # 小円を隠す
			_rotationer = false # 衝突していない
			
		
		await ThreadUtils.waitNextFrame
	

# ドラッグ可のとき、ドラッグ移動し続ける
func _loop03() -> void:
	while draggable:
		self._drag_process() # Drag移動処理
		await ThreadUtils.waitNextFrame

# 次のコスチュームに切り替え続ける
func _loop04() -> void :
	while true:
		await ThreadUtils.sleep(0.5) # 0.5秒待つ
		self.costumes.next_svg_tex() # 次のコスチュームにする
		await ThreadUtils.waitNextFrame

# ターゲットと衝突したとき true, 衝突していないとき false
var _rotationer: bool = false
# ターゲットと衝突している間、回転し続ける
func _loop05() -> void :
	while true:
		if _rotationer:
			self.rotation -= PI / 180 * 15 # 15度右回転
		await ThreadUtils.waitNextFrame
