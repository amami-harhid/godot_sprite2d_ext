# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

@onready var TOP = $"/root/Scene02"

signal ballWaitNextProcess()

var myself:Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.costumes.svg_file_path_setting([
		"res://assets/ball-a.svg"
	])
	if _cloned == false: 
		_original_sprite = self
		position.x = get_viewport_rect().size.x / 10
		position.y = get_viewport_rect().size.y - 10
		
	#print("_original_sprite=",_original_sprite)
	costumes.current_svg_tex()
	
	if _cloned == false:
		_loop_clone()
		visible = false
	else:
		_loop_shoot()
		_loop_hit()

func _process(delta: float)->void:
	#if _cloned == false:
	ballWaitNextProcess.emit()

func _loop_clone() ->void:
	for idx in range(10):
			
		var limit = 20
		var count = 0
		while _cloned == false:
			if count > limit:
				break
			_clone(count)
			count += 1
		await ThreadUtils.sleep(2)
		await ballWaitNextProcess

func _clone(count:int) ->void:
	var clone:Sprite2DExt = SpriteUtils.clone(self)
	clone.visible = true
	clone.position.x += 25 * count
	# 同じ階層に追加する
	TOP.add_sibling.call_deferred(clone)

func _loop_shoot()->void:
	while _cloned:
		self.position.y -= 10
		await ballWaitNextProcess

func _loop_hit()->void:
	var target :Sprite2DExt = $"/root/Scene02/Cat"
	while _cloned:
		var hitter:Hit = costumes._is_pixel_touched(target)
		if hitter.hit :
			break
		if position.y < 0:
			break
		await ballWaitNextProcess

	visible = false
	await ThreadUtils.sleep(1)	
	queue_free()
