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

# 相手のスプライトが近傍にあるかを判定する
func _is_neighborhood(target:Sprite2DExt) -> bool :
	# 相手が空のとき 
	if target == null or target.costumes == null :
		return false

	return self._is_neighborhood_condition(target)

# to use for override
func _is_neighborhood_condition(target: Sprite2DExt) -> bool :
	# 前提事項
	# 全スプライトの親の基準位置は トップのNode2Dの左上隅

	# 相手のテキスチャー設定が完了していないときは 「近傍でない」として終わる
	if self._svg_img_keys.size() ==0 or target.costumes._svg_img_keys.size() == 0:
		return false

	# 自身のTexture_idx
	var texture_idx = self._texture_idx
	# 相手のTexture_idx
	var target_texture_idx = target.costumes._texture_idx
	# 自身のsvgObj
	var svg_key:String = self._svg_img_keys.get(texture_idx)
	var svg_obj:SvgObj = self._svg_img_map.get(svg_key)
	svg_obj.distance = calculate_distance(svg_obj)
	# 相手のsvgObj
	var target_svg_key:String = target.costumes._svg_img_keys.get(target_texture_idx)
	var target_svg_obj:SvgObj = target.costumes._svg_img_map.get(target_svg_key)
	target_svg_obj.distance = calculate_distance(target_svg_obj)
	
	# 近傍最大距離( global )
	# TODO distance : Scaleを考慮する必要あり。
	var neighborhood: float = (svg_obj.distance + target_svg_obj.distance)
	# 位置ポジションを取得	
	var pos:Vector2 = self.sprite.position
	var pos_t:Vector2 = target.costumes.sprite.position
	#print("position self=", pos, ", target=", pos_t)
	# 実際の距離を取得する( global )
	var distance: float = pos.distance_to(pos_t)
	# 実際の距離が 近傍距離より大のとき
	#print("distance =%f , neighborhood =%f" % [distance, neighborhood])
	if distance > neighborhood:
		# 近傍にはない
		return false
	else:
		# 近傍にある
		return true
	
