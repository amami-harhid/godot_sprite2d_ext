extends Sprite2DSvg
class_name Sprite2DExt

# drag可否
@export var draggable:bool = false

# original sprite when cloned
var _original_sprite: Sprite2DExt

# signal for dragging
signal signal_just_pressed_mouse_left()
signal signal_just_release_mouse_left()

const VECTOR2_INF = Vector2(INF,INF) 
var _mouse_dis:Vector2 = VECTOR2_INF
func _preset_dragging() -> void :
	signal_just_pressed_mouse_left.connect(Callable(self, "_on_mouse_left_just_pressed"))
	signal_just_release_mouse_left.connect(Callable(self, "_on_mouse_left_just_released"))

# マウス左押されたときにポインターが画像の不透明部分にあれば
# 押された座標を記憶させる
func _on_mouse_left_just_pressed() -> void:
	var _pos = get_viewport().get_mouse_position()
	var l_pos = to_local(_pos)
	if self.is_pixel_opaque(l_pos):
		# ポジションとの距離ベクトルを保存
		_mouse_dis = self.position - _pos
		
# マウス左を離したとき、押された座標を消す
func _on_mouse_left_just_released() -> void:
	# ポジションとの距離ベクトルを初期化
	_mouse_dis = VECTOR2_INF

# ドラッグ処理
func _drag_process() -> void:
	if draggable :
		if _mouse_dis.x == VECTOR2_INF.x:
			# マウス左を離した後
			return
		# マウスポインター座標に応じてスプライト位置を変える
		var _pos = self.get_viewport().get_mouse_position()
		var _drag_pos = _mouse_dis + _pos
		self.position = _drag_pos


func _ready() -> void:
	if self.draggable:
		# ドラッグ処理の初期処理
		_preset_dragging()

func _physics_process(delta: float) -> void:
	# ドラッグ対応
	if self.draggable:
		# fire input signals
		if Input.is_action_just_pressed("mouse_left"):
			signal_just_pressed_mouse_left.emit()
		if Input.is_action_just_released("mouse_left"):
			signal_just_release_mouse_left.emit()
