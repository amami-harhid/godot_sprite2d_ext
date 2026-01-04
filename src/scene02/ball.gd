# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

@onready var TOP = $"/root/Scene02"

#signal waitNextFrame()
#signal s_loop_shoot()
#signal s_loop_hit()

var signalArr = []
var target :Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.costumes.svg_file_path_setting([
		"res://assets/ball-a.svg"
	])
	if _cloned == false: 
		position.x = get_viewport_rect().size.x / 4
		position.y = get_viewport_rect().size.y - 10
		
	#print("_original_sprite=",_original_sprite)
	costumes.current_svg_tex()
	
	if _cloned == false:
		_loop_clone()
		visible = false
	else:
		target = $"/root/Scene02/Cat"
		_freeSignal.connect(_free)
		_loop_shoot()
		_loop_hit()

	ThreadUtils.stop_scene.connect(
		func(): _freeSignal.emit(self)
	)

func _loop_clone() ->void:
	for idx in range(20):
			
		var limit = 9
		var count = 0
		while _cloned == false:
			count += 1
			if count > limit:
				break
			_clone(count)
			#await frame_changed
			#await waitNextFrame

			#await ThreadUtils.waitNextFrame
		await ThreadUtils.sleep(2)
		#await frame_changed
		await ThreadUtils.waitNextFrame
		#await waitNextFrame

func _clone(count:int) ->void:
	var clone:Sprite2DExt = SpriteUtils.clone(self)
	clone.visible = true
	clone.position.x += 40 * (count)
	# 同じ階層に追加する
	TOP.add_sibling.call_deferred(clone)

var _move_direction = 1
func _loop_shoot()->void:
	while _cloned:
		self.position += Vector2(0, -10) + _move_direction * Vector2(1, 5)
		#await frame_changed
		await ThreadUtils.waitNextFrame
		#await waitNextFrame
		#await s_loop_shoot
		#await ThreadUtils.sleep(1/30)
var hitter:Hit = Hit.new()
func _loop_hit()->void:
	#_freeSignal.connect(_free)
	#var target :Sprite2DExt = $"/root/Scene02/Cat"
	while _cloned:
		#var time_start = ThreadUtils.get_time()
		var hitter:Hit = costumes._is_pixel_touched(target)
		#costumes._is_pixel_touched2.call_deferred(target)
		#var time_now = ThreadUtils.get_time()
		#print("time=", int(time_now-time_start), "   ,", time_now, ",", time_start)
		if hitter.hit :
			#print("time=", int(time_now-time_start), "   ,", time_now, ",", time_start)
			_move_direction *= -5
			await ThreadUtils.waitNextFrame
			continue
		if position.y < 0:
			break
		if position.y > get_viewport_rect().size.y:
			break
		#await frame_changed
		await ThreadUtils.waitNextFrame
		#await waitNextFrame
		#await s_loop_hit
		#await ThreadUtils.sleep(1/30)

	visible = false
	_freeSignal.emit(self)
	#var thread = Thread.new()
	#thread.start(_free, Thread.PRIORITY_NORMAL)
	#await ThreadUtils.sleep(1)	
	#await ThreadUtils.waitNextFrame
	#TOP.remove_child.call_deferred(self)
	
	#self.free.call_deferred()
	#self.queue_free.call_deferred()

signal _freeSignal()
func _free( node ):
	#var node = self
	#print(node.name)
	node.free.call_deferred()
	node.queue_free.call_deferred()
	
	
