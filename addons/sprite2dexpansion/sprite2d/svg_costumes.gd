class_name SvgCostumes

var sprite: Sprite2DExt
var neighborhood_value: int = 10
# SVG 関連
var _svg_img_map = Dictionary()
var _svg_img_keys = Array()
# テキスチャの位置
var _texture_idx = 0

# コンストラクター	
func _init(sprite: Sprite2DExt):
	self.sprite = sprite

# 画像ファイルを読み込む
func svg_file_path_setting(svg_path_arr: Array) -> void:
	if self.sprite._cloned == true :
		# クローンされたときは何もしない
		return
		
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
				svg_obj.surrounding_point_arr = BitmapUtils.surrounding_points(_img)
		else:
			print("ivalid path = ", path)
	
# 現在のテキスチャーで描画
func current_svg_tex() -> void:
	#print(self.sprite._original_sprite)
	self._draw_svg()

# 次のテキスチャーで描画
func next_svg_tex() -> void:
	if self.sprite._cloned:
		if self.sprite._original_sprite == null:
			return
		if self.sprite._original_sprite.costumes._svg_img_keys.size() == 1:
			return
	else:
		if self.sprite == null:
			return
		if self.sprite.costumes._svg_img_keys.size() == 1:
			return

	_texture_idx += 1
	self._draw_svg()

# 前のテキスチャーで描画
func prev_svg_tex() -> void:
	_texture_idx -= 1
	if _texture_idx < 0:
		if self.sprite._cloned:
			_texture_idx = self.sprite._original_sprite.costumes._svg_img_keys.size() -1
		else:
			_texture_idx = self.sprite.costumes._svg_img_keys.size() -1
			
	self._draw_svg()

# 描画
func _draw_svg() -> void:
	if self.sprite._cloned and self.sprite._original_sprite == null:
		return
	var svg_img_keys = self._get_svg_img_keys()
	var svg_img_map = self._get_svg_img_map()
	if _texture_idx < 0:
		return
	if svg_img_keys.size() > 0:
		var tex_size = svg_img_keys.size()
		_texture_idx = _texture_idx % tex_size
		var key = svg_img_keys.get(_texture_idx)
		var svg_obj:SvgObj = svg_img_map.get(key)
		svg_obj.svg_scale = self.sprite.svg_scale
		var image:Image = svg_obj.get_image()
		# ImageTextureへのset_image は事前に済ませておく。
		var _texture = svg_obj.get_texture()
		self.sprite.texture = _texture
		svg_obj.rect = self.sprite.get_rect()

func _get_svg_img_obj() -> SvgObj:
	var _tex_idx = self._texture_idx
	if _tex_idx < 0:
		return SvgObj.new(true) # 空のオブジェクト
		
	var _svg_img_keys = _get_svg_img_keys()
	if _tex_idx < _svg_img_keys.size():
		var _tex_key = _svg_img_keys.get(_tex_idx)
		var _svg_img_map = _get_svg_img_map()
		if _svg_img_map.has(_tex_key):
			var _svg_obj:SvgObj = _svg_img_map.get(_tex_key)
			return _svg_obj
	return SvgObj.new(true) # 空のオブジェクト

func _get_svg_img_keys() -> Array:
	if self.sprite._cloned == true :
		return self.sprite._original_sprite.costumes._svg_img_keys
	else:
		return self._svg_img_keys	

func _get_svg_img_map()-> Dictionary:
	if self.sprite._cloned == true:
		return self.sprite._original_sprite.costumes._svg_img_map
	else:
		return self._svg_img_map

# 画像ピクセルで判定する衝突判定
# スプライト自身の表示サイズが大のときの高速化を図りたい
func _is_pixel_touched(_target:Sprite2DExt) -> Hit :
	# 見えないときは衝突しない
	if self.sprite.visible == false:
		return Hit.new()
	if _target.visible == false:
		return Hit.new()
		
	var hit = SpriteUtils.is_touched(self.sprite, _target)
	return hit
