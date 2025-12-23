class_name SvgCostumes

var sprite: Sprite2DExt
var neighborhood_value: int = 10
# SVG 関連
var _svg_img_map = {}
var _svg_img_keys = []
# テキスチャの位置
var _texture_idx = 0
var image: Image
	
func _init(sprite: Sprite2DExt):
	self.sprite = sprite

func svg_file_path_setting(svg_path_arr: Array) -> void:
	var _regex := RegEx.new()
	var _error = _regex.compile("^.+/(.+)\\.svg$")
	# スプライトテキスチャーの型をImageTextureにする
	self.sprite.texture = ImageTexture.new()
	if _error != OK:
		return
	for path in svg_path_arr:
		if path != null and path is String and _regex.is_valid():
			var file = FileAccess.open(path, FileAccess.READ)
			if file != null:
				var result = _regex.search(path)
				var name = result.get_string(1)		# 拡張子を除いたファイル名
				var _txt = file.get_as_text(true)	# skip_cr = true
				_svg_img_keys.append(name)
				var svg_obj:SvgObj = SvgObj.new()
				svg_obj.name = name
				svg_obj.svg_text = _txt
				svg_obj.svg_scale = self.sprite.svg_scale
				svg_obj.create_svg_from_text()
				_svg_img_map.set(name, svg_obj)
				# 不透明なピクセル座標（Local)を配列化
				var _img = svg_obj.get_image()
				svg_obj.surrounding_point_arr = BitmapUtils.surrounding_points(_img, self.sprite.pixel_spacing)
		else:
			print("ivalid path = ", path)

# 画像矩形をグローバル座標に変換し、矩形の中に描かれるイメージ外周点のうちから
# 中心より最も遠い点を求める
func calculate_distance(svg_obj: SvgObj) -> float :
	var _rect = svg_obj.rect
	var _global_center:Vector2 = self.sprite.to_global( Vector2( _rect.size.x/2, _rect.size.y/2 ))
	var _pixels = BitmapUtils.pixel_to_global(self.sprite, svg_obj.surrounding_point_arr)
	var _fartherst = BitmapUtils.point_fartherst_from_center(_global_center, _pixels)
	return _fartherst
	
func current_svg_tex() -> void:
	self._draw_svg()

func next_svg_tex() -> void:
	if self._svg_img_keys.size() == 1:
		return
	_texture_idx += 1
	self._draw_svg()

func prev_svg_tex() -> void:
	_texture_idx -= 1
	if _texture_idx < 0:
		_texture_idx = self._svg_img_keys.size() -1
	self._draw_svg()
	
func _draw_svg() -> void:
	
	if _texture_idx < 0:
		return
	if self._svg_img_keys.size() > 0:
		var tex_size = self._svg_img_keys.size()
		_texture_idx = _texture_idx % tex_size
		var key = self._svg_img_keys.get(_texture_idx)
		var svg_obj:SvgObj = self._svg_img_map.get(key)
		svg_obj.svg_scale = self.sprite.svg_scale
		var image:Image = svg_obj.get_image()
		# ImageTextureへのset_image は事前に済ませておく。
		var _texture = svg_obj.get_texture()
		self.sprite.texture = _texture
		svg_obj.rect = self.sprite.get_rect()

enum CALLER  {OWN, RECALL}
# 画像ピクセルで判定する衝突判定
# スプライト自身の表示サイズが大のときの高速化を図りたい
func _is_pixel_touched(_target:Sprite2DExt, caller:CALLER = CALLER.OWN) -> Hit :
	#var circle :Sprite2D = $"/root/Node2D/Circle"
	var hit = SpriteUtils.is_touched(self, _target.costumes)
	return hit
