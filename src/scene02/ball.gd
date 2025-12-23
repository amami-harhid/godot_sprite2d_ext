# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

@onready var TOP = $"/root/Scene02"

var original = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.costumes.svg_file_path_setting([
		"res://assets/ball-a.svg"
	])
	if original:
		position.x = get_viewport_rect().size.x / 4
		position.y = get_viewport_rect().size.y - 10
	costumes.current_svg_tex()
	if original:
		_loop_clone()
		visible = false
	else:
		_loop_shoot()
		_loop_hit()

func _loop_clone() ->void:
	var limit = 20
	var count = 0
	while true:
		if count > limit:
			break
		_clone(count)
		count += 1
		await ThreadUtils.signal_process_loop

func _clone(count:int) ->void:
	var clone:Sprite2DExt = self.duplicate()
	clone.original = false
	clone.visible = true
	clone.position.x += 25 * count
	TOP.add_child.call_deferred(clone)

func _loop_shoot()->void:
	while true:
		self.position.y -= 10
		await ThreadUtils.signal_process_loop

func _loop_hit()->void:
	var target :Sprite2DExt = $"/root/Scene02/Cat"
	while true:
		var hitter:Hit = costumes._is_pixel_touched(target)
		if hitter.hit :
			break
		if position.y < 0:
			break
		await ThreadUtils.signal_process_loop

	visible = false
	queue_free()
