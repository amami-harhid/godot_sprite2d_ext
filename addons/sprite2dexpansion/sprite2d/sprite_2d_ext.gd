extends Sprite2DSvg
class_name Sprite2DExt

# ループ内の休止(await)を解除するシグナル
# _processの中で emit される
#signal signal_process_loop()
signal signal_just_pressed_mouse_left()
signal signal_just_release_mouse_left()
# SVGをレンダリングする拡大率
@export var svg_scale: float = 1.0

# Bitmap Collision pixel spacing
@export var pixel_spacing: int = 0

#@export var neighborhood_value: int = 10

# drag可否
@export var draggable:bool = false

@onready var TOP:Node2D = $"/root/Node2D"

@onready var prev_scale: Vector2 = self.scale

@onready var costumes:SvgCostumes = SvgCostumes.new(self)

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#_top = self.get_parent()
	if self.draggable:
		_preset_dragging()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# ドラッグ対応
	if self.draggable:
		# fire input signals
		if Input.is_action_just_pressed("mouse_left"):
			signal_just_pressed_mouse_left.emit()
		if Input.is_action_just_released("mouse_left"):
			signal_just_release_mouse_left.emit()
			
	# scale変更されたとき「衝突判定近傍距離」変化するため再計算する
	if prev_scale != self.scale:
		for key:String in self._svg_img_keys:
			var svg_obj:SvgObj = self._svg_img_map.get(key)
			svg_obj.distance = self.costumes.calculate_distance(svg_obj)
			#print("scale change distance = ", svg_obj.distance)
		prev_scale = self.scale
