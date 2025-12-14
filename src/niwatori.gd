# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.svg_file_path_setting([
		"res://assets/hen-a.svg",
		"res://assets/hen-b.svg",
	])
	position.x = 200
	position.y = 200
	self.current_svg_tex()
	self._loop01()

func _loop01() -> void :
	while true:
		await sleep(1.0)
		next_svg_tex()
		await signal_process_loop
