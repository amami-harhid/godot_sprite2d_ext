# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.costumes.svg_file_path_setting([
		"res://assets/cat-a.svg",
		"res://assets/cat-b.svg",
	])
	position.x = get_viewport_rect().size.x /2
	position.y = get_viewport_rect().size.y /4
	costumes.current_svg_tex()

	_loop_rotate()
	_loop_next_costume()

func _loop_rotate()->void:
	while true:
		rotation += PI/180 * 5
		await ThreadUtils.signal_process_loop

func _loop_next_costume()->void:
	while true:
		self.costumes.next_svg_tex()
		await ThreadUtils.sleep(0.2)
		await ThreadUtils.signal_process_loop
