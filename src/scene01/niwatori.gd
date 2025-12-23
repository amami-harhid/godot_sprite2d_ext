# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	position.x = 350
	position.y = 350
	costumes.svg_file_path_setting([
		"res://assets/hen-a.svg",
		"res://assets/hen-b.svg",
		#"res://assets/hen-b.svg",
		#"res://assets/hen-b.svg",
	])
	costumes.current_svg_tex()
	self._loop01()
	self._loop02()

func _loop01() -> void :
	while true:
		await ThreadUtils.sleep(0.5)
		costumes.next_svg_tex()
		await ThreadUtils.signal_process_loop

func _loop02() -> void :
	while true:
		self.rotation += PI / 180 * 5
		await ThreadUtils.signal_process_loop
