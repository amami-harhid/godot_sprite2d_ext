#@tool
extends Sprite2D
class_name Sprite2DExt

# ループ内の休止(await)を解除するシグナル
# _processの中で emit される
signal signal_process_loop()
signal signal_just_pressed_mouse_left()
signal signal_just_release_mouse_left()
# SVGをレンダリングする拡大率
@export var svg_scale: float = 1.0
# drag可否
@export var draggable:bool = false

# SVG 関連
var _svg_tex_arr = []
var svg_path_arr = []

# テキスチャの位置
var _texture_idx = 0

# イメージ
var _img = Image.new()

var _regex := RegEx.new()
var _error = _regex.compile("^.+\\.svg$")


# _readyの中で呼び出す前提の処理
# svg_path_arr は、svgファイルのパスを配列で指定する
func svg_file_path_setting(svg_path_arr: Array) -> void:
	# スプライトテキスチャーの型をImageTextureにする
	self.texture = ImageTexture.new()
	if _error != OK:
		return
	for path in svg_path_arr:
		if path != null and path is String and _regex.is_valid():
			var file = FileAccess.open(path, FileAccess.READ)
			if file != null:
				# get svg text
				var _img = file.get_as_text(true)
				_svg_tex_arr.append(_img)
		else:
				print("ivalid path = ", path)
	
func current_svg_tex() -> void:
	self._draw_svg()
func next_svg_tex() -> void:
	_texture_idx += 1
	self._draw_svg()
func prev_svg_tex() -> void:
	_texture_idx -= 1
	if _texture_idx < 0:
		_texture_idx = _svg_tex_arr.size() -1
	self._draw_svg()
	
func _draw_svg() -> void:
	if _texture_idx < 0:
		return
	if _svg_tex_arr.size() > 0:
		var tex_size = _svg_tex_arr.size()
		_texture_idx = _texture_idx % tex_size
		_img.load_svg_from_string(_svg_tex_arr[_texture_idx], svg_scale)
		self.texture.set_image(_img)

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
	print(_pos)
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
func _is_pixel_touched(target:Sprite2DExt) -> bool :
	if _is_nearly(target) == false:
		return false
	# 周囲を囲む四角形
	var rect:Rect2 = self.get_rect()
	var touch:bool = false
	for x in range(rect.size.x):
		for y in range(rect.size.y):
			# (x,y)座標をスプライト座標の形へする( rect2の半分だけずらす）
			var pos = Vector2(x-rect.size.x/2,y-rect.size.y/2)
			# 自身の画像( A > 0 )の場所であれば
			
			
			if self.is_pixel_opaque(pos):
				# 自身のピクセルの座標を 相手のローカル座標基準へ変える
				var _pos00:Vector2 = target.to_local(self.to_global(pos))
				var _pos01:Vector2 = Vector2(_pos00.x+1, _pos00.y)
				var _pos02:Vector2 = Vector2(_pos00.x-1, _pos00.y)
				var _pos03:Vector2 = Vector2(_pos00.x, _pos00.y+1)
				var _pos04:Vector2 = Vector2(_pos00.x, _pos00.y-1)
				if target.is_pixel_opaque(_pos00):
					return true
				elif target.is_pixel_opaque(_pos01):
					return true
				elif target.is_pixel_opaque(_pos02):
					return true
				elif target.is_pixel_opaque(_pos03):
					return true
				elif target.is_pixel_opaque(_pos04):
					return true
	
	return false

# 相手のスプライトが近傍にあるかを判定する
func _is_nearly(target:Sprite2DExt) -> bool :
	# 相手が空のとき 
	if target == null :
		return false

	return self._is_nearly_condition(target)

# to use for override
func _is_nearly_condition(target: Sprite2DExt) -> bool :
	# 前提事項
	# 全スプライトの親の基準位置は トップのNode2Dの左上隅
	# 自身と相手のポジションの間の距離を計算し、所定の範囲の中にあれば
	# 「近傍である」と判定する。
	# 所定の距離とは、それぞれの画像の隅を通る円の半径を足し合わせたものとする

	# 位置ポジションを取得	
	var pos:Vector2 = self.position
	var pos_t:Vector2 = target.position
	
	# スプライト画像を囲む四角形(Rect2)を取得
	var rect:Rect2 = self.get_rect()
	var rect2:Rect2 = target.get_rect()
	
	# 四角形の相対する頂点間の距離の半分が半径として計算し、２つのスプライトの半径を合計する
	# 四角形(Rect2)には Scaleの指定、SVGの大きさ(SvgScale)が反映されていないため、大きさを反映させている
	var r_01: float = (rect.size * self.scale*self.svg_scale).distance_to(Vector2(0,0)) /2
	var r_02: float = (rect2.size * target.scale*target.svg_scale).distance_to(Vector2(0,0)) /2
	# 近傍距離
	var neighborhood: float = r_01 + r_02 
	
	var pos_g = self.to_global(pos)
	var pos_g_t = target.to_global(pos_t)
	var pos_g_t_l = self.to_local(pos_g_t)
	
	# 実際の距離を取得する
	var distance: float = pos.distance_to(pos_t)
	# 実際の距離が 近傍距離より大のとき
	if distance > neighborhood:
		# 近傍にはない
		return false
	else:
		# 近傍にある
		return true
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	signal_process_loop.emit()
