#@tool
extends Sprite2D
class_name Sprite2DExt

# ループ内の休止(await)を解除するシグナル
# _processの中で emit される
#signal signal_process_loop()
signal signal_just_pressed_mouse_left()
signal signal_just_release_mouse_left()
# SVGをレンダリングする拡大率
@export var svg_scale: float = 1.0

# Bitmap Collision pixel spacing
@export var pixel_spacing: int = 10

@export var neighborhood_value: int = 10

# drag可否
@export var draggable:bool = false

# SVG 関連
var _svg_img_map = {}
var _svg_img_keys = []

# テキスチャの位置
var _texture_idx = 0

# イメージ
#var _img = Image.new()

@onready var _top:Node2D = $"/root/Node2D"

# _readyの中で呼び出す前提の処理
# svg_path_arr は、svgファイルのパスを配列で指定する
func svg_file_path_setting(svg_path_arr: Array) -> void:
	var _regex := RegEx.new()
	var _error = _regex.compile("^.+/(.+)\\.svg$")
	# スプライトテキスチャーの型をImageTextureにする
	self.texture = ImageTexture.new()
	if _error != OK:
		return
	for path in svg_path_arr:
		if path != null and path is String and _regex.is_valid():
			var file = FileAccess.open(path, FileAccess.READ)
			if file != null:
				var result = _regex.search(path)
				var name = result.get_string(1)		# 拡張子を除いたファイル名
				var _txt = file.get_as_text(true)	# skip_cr = true
				_svg_img_keys.append(name)
				var svg_obj:SvgObj = SvgObj.new()
				svg_obj.name = name
				svg_obj.svg_text = _txt
				svg_obj.svg_scale = self.svg_scale
				svg_obj.create_svg_from_text()
				_svg_img_map.set(name, svg_obj)
				var _img = svg_obj.get_image()
				var _size = _img.get_size()
				# 横方向の走査
				for y in range(_size.y):
					for x in range(_size.x):
						var pixel = _img.get_pixel(x, y)
						if pixel.a > 0: # 不透明ピクセルの場合
							svg_obj.pixel_opaque_arr.append(Vector2(x,y))

				# 連続して不透明のピクセルが並ぶとき、決めた数だけスキップさせる
				var b_size:int = svg_obj.pixel_opaque_arr.size()
				svg_obj.opaque_arr_tuning(self.pixel_spacing)
				var a_size:int = svg_obj.pixel_opaque_tuning_arr.size()

		else:
				print("ivalid path = ", path)

func current_svg_tex() -> void:
	self._draw_svg()
func next_svg_tex() -> void:
	if self._svg_img_keys.size() == 1:
		return
	_texture_idx += 1
	self._draw_svg()

func prev_svg_tex() -> void:
	_texture_idx -= 1
	if _texture_idx < 0:
		_texture_idx = self._svg_img_keys.size() -1
	self._draw_svg()
	
func _draw_svg() -> void:
	
	if _texture_idx < 0:
		return
	if self._svg_img_keys.size() > 0:
		var tex_size = self._svg_img_keys.size()
		_texture_idx = _texture_idx % tex_size
		var key = self._svg_img_keys.get(_texture_idx)
		var svg_obj:SvgObj = self._svg_img_map.get(key)
		svg_obj.svg_scale = self.svg_scale
		var image:Image = svg_obj.get_image()
		# ImageTextureへのset_image は事前に済ませておく。
		var _texture = svg_obj.get_texture()
		self.texture = _texture

# PROCESS_ALWAYS( Engine停止時に、停止する )
# when false, the timer will be paused when setting paused to true
const PROCESS_ALWAYS = true
# PROCESS_IN_PHYSICS ( timer は 物理フレームの終わりで更新される )
# when false, the timer will update at the end of the process frame.
const PROCESS_IN_PHYSICS = false
# IGNORE_TIME_SCALE ( 実時間を採用 )
# when true, the timer will ignore Engine.time_scale and update with the real, elapsed time.
const IGNORE_TIME_SCALE = true
func sleep(time_sec: float) -> void:
	await get_tree().create_timer(
		time_sec
		,PROCESS_ALWAYS 
		,PROCESS_IN_PHYSICS 
		,IGNORE_TIME_SCALE
		).timeout

const VECTOR2_INF = Vector2(INF,INF) 
var _mouse_dis:Vector2 = VECTOR2_INF
func _preset_dragging() -> void :
	signal_just_pressed_mouse_left.connect(Callable(self, "_on_mouse_left_just_pressed"))
	signal_just_release_mouse_left.connect(Callable(self, "_on_mouse_left_just_released"))

		
func _on_mouse_left_just_pressed() -> void:
	var _pos = get_viewport().get_mouse_position()
	#print(_pos)
	var l_pos = to_local(_pos)
	if self.is_pixel_opaque(l_pos):
		# ポジションとの距離ベクトルを保存
		_mouse_dis = self.position - _pos
		
func _on_mouse_left_just_released() -> void:
	# ポジションとの距離ベクトルを初期化
	_mouse_dis = VECTOR2_INF
	
func _drag_process() -> void:
	if draggable :
		if _mouse_dis.x == VECTOR2_INF.x:
			# マウス左を離した後
			return

		var _pos = self.get_viewport().get_mouse_position()
		var _drag_pos = _mouse_dis + _pos
		self.position = _drag_pos


# 画像ピクセルで判定する衝突判定
# スプライト自身の表示サイズが大のときの高速化を図りたい
func _is_pixel_touched(_target:Sprite2DExt, counter:int) -> Hit :
	#var circle :Sprite2D = $"/root/Node2D/Circle"
	var hiter:Hit = Hit.new()
	var target:Sprite2DExt = _target
	if _is_neighborhood(target) == false:
		hiter.hit = false
		return hiter
	#var time_start = Time.get_unix_time_from_system()
	# 周囲を囲む四角形
	var rect:Rect2 = self.get_rect()
	var touch:bool = false
	var svg_obj_key = self._svg_img_keys[self._texture_idx]
	var svg_obj:SvgObj = self._svg_img_map.get(svg_obj_key)
	for pos in svg_obj.pixel_opaque_tuning_arr:
		var _pos = Vector2(pos.x-rect.size.x/2, pos.y-rect.size.y/2)
		var _pos00:Vector2 = target.to_local(self.to_global(_pos))
		if target.is_pixel_opaque(_pos00):
			hiter.position = self.to_global(_pos)
			hiter.hit = true
			return hiter
	
	hiter.position = Vector2(-INF, -INF)
	return hiter

# 相手のスプライトが近傍にあるかを判定する
func _is_neighborhood(target:Sprite2D) -> bool :
	# 相手が空のとき 
	if target == null :
		return false

	return self._is_neighborhood_condition(target)

# to use for override
func _is_neighborhood_condition(target: Sprite2D) -> bool :
	# 前提事項
	# 全スプライトの親の基準位置は トップのNode2Dの左上隅
	# 自身と相手のポジションの間の距離を計算し、所定の範囲の中にあれば
	# 「近傍である」と判定する。
	# 所定の距離とは、それぞれの画像Rectの隅を通る円の半径を足し合わせ、10 加算したものとする

	# 位置ポジションを取得	
	var pos:Vector2 = self.position
	var pos_t:Vector2 = target.position
	
	# スプライト画像を囲む四角形(Rect2)を取得
	var rect1:Rect2 = self.get_rect()
	var rect2:Rect2 = target.get_rect()
	
	# 四角形の相対する頂点間の距離の半分が半径として計算し、２つのスプライトの半径を合計する
	# 四角形(Rect2)には Scaleの指定、SVGの大きさ(SvgScale)が反映されていないため、大きさを反映させている
	var r_01: float = (rect1.size * self.scale).distance_to(Vector2(0,0)) /2
	var r_02: float = (rect2.size * target.scale).distance_to(Vector2(0,0)) /2
	# 近傍距離
	var neighborhood: float = r_01 + r_02 + self.neighborhood_value
	
	var pos_g = self.to_global(pos)
	var pos_g_t = target.to_global(pos_t)
	var pos_g_t_l = self.to_local(pos_g_t)
	
	# 実際の距離を取得する
	var distance: float = pos.distance_to(pos_t)
	# 実際の距離が 近傍距離より大のとき
	#print("distance =%f , neighborhood =%f" % [distance, neighborhood])
	if distance > neighborhood:
		# 近傍にはない
		return false
	else:
		# 近傍にある
		return true
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_top = self.get_parent()
	if self.draggable:
		_preset_dragging()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# fire input signals
	if Input.is_action_just_pressed("mouse_left"):
		signal_just_pressed_mouse_left.emit()
	if Input.is_action_just_released("mouse_left"):
		signal_just_release_mouse_left.emit()
	
	# fire loop signal
	#_top.signal_process_loop.emit()

class SvgObj: 
	var name : String
	var svg_text: String
	var svg_scale: float = 1.0
	var svg_scale_created : float = 1.0
	var image: Image = Image.new()
	var texture: ImageTexture = ImageTexture.new()
	var pixel_opaque_arr = []
	#var pixel_opaque_arr_y = []
	var pixel_opaque_tuning_arr = []
	enum Axis { X, Y }
	func sort_custom_y(p01:Vector2, p02:Vector2)->bool:
		if p01.x == p02.x :
			return p01.y < p02.y
		else:
			return p01.x < p02.x
			
	func opaque_arr_tuning(skip_count: int)->void:
		
		var arr_x = _opaque_arr_tuning(skip_count, Axis.X)
		arr_x.sort_custom(sort_custom_y)
		pixel_opaque_arr = arr_x
		var arr_y = _opaque_arr_tuning(skip_count, Axis.Y)
		pixel_opaque_tuning_arr = arr_y

	func _opaque_arr_tuning(skip_count: int, axis: Axis)-> Array:
		var arr = []
		var size = pixel_opaque_arr.size()
		var count = 0
		for idx in range(size):
			var pos = pixel_opaque_arr.get(idx)
			if idx == 0:
				arr.append(pos)
			else:
				var pos_pre = pixel_opaque_arr.get(idx-1)
				var pos_diff = pos - pos_pre
				# 横向きに不透明が連続するとき
				if (axis == Axis.X and pos_diff.y == 0 and pos_diff.x == 1) or (axis == Axis.Y and pos_diff.x == 0 and pos_diff.y == 1):
					# 指定した数だけスキップ
					if count % skip_count == 0:
						arr.append(pos)
					count += 1
						
				else:
					if count > 0:
						# Yが変化したとき、または、不透明が不連続になったとき
						# 直前のピクセルはスキップ対象外
						arr.append(pos_pre)
						
					arr.append(pos)
					count = 0
		return arr
		

	func get_image()->Image:
		if self.svg_scale != self.svg_scale_created:
			self.create_svg_from_text()
		return self.image
	func get_texture()->ImageTexture:
		texture.set_image(self.image)
		return texture
	func create_svg_from_text( ) ->void:
		self.image.load_svg_from_string(self.svg_text, self.svg_scale)
		self.svg_scale_created = self.svg_scale
	
	func toString():
		return "name=%s,svg_scale=%f"% [self.name, self.svg_scale]

class Hit :
	var position :Vector2 = Vector2(INF, INF)
	var hit: bool = false
	
