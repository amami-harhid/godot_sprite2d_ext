# Sprite2DExt
# ・Sprite2Dを継承
# ・SVG表示に特化し、画像ベースで衝突判定をする
extends Sprite2DExt

func _ready() -> void:
	super._ready()
	position.x = 350
	position.y = 450
	# コスチューム画像を読み込む
	costumes.svg_file_path_setting([
		"res://assets/hen-a.svg",
		"res://assets/hen-b.svg",
	])
	# コスチューム画像を描画する
	costumes.current_svg_tex()
	
	# 無限ループスレッドを起動（２個）
	self._loop01() # 次のコスチュームに切り替えし続ける
	self._loop02() # 回転し続ける

# 次のコスチュームに切り替えし続ける
func _loop01() -> void :
	while true:
		await ThreadUtils.sleep(0.5) # 0.5秒待つ
		costumes.next_svg_tex() # 次のコスチュームにする
		await ThreadUtils.waitNextFrame

# 回転し続ける
func _loop02() -> void :
	while true:
		self.rotation += PI / 180 * 5 # 5度右回転
		await ThreadUtils.waitNextFrame
