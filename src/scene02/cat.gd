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

#func _physics_process(delta: float) -> void:
#	rotation += PI/180 * 10

func _loop_rotate()->void:
	while true:
		rotation += PI/180 * 10
		#await ThreadUtils.sleep(0.033)
		# 他の同期型(waitNextFrame)ループが多い場合に
		# 目立つ事象
		# sleepで待たないループで、且つ、他のループが多い場合
		# シグナルが滞留するみたい。
		# 他処理がなくなったときに滞留している
		# シグナルが一斉に送られてきて、回転が速くなる
		await ThreadUtils.waitNextFrame
		#await ThreadUtils.sleep(1/30)

func _loop_next_costume()->void:
	while true:
		self.costumes.next_svg_tex()
		await ThreadUtils.sleep(0.2)
		await ThreadUtils.waitNextFrame
		#print(get_signal_list())
		#await ThreadUtils.sleep(1/30)
