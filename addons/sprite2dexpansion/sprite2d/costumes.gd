class_name Costumes

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
				var _img = svg_obj.get_image()
				var _size = _img.get_size()
				
				# 横方向の走査
				for y in range(_size.y):
					for x in range(_size.x):
						var pixel = _img.get_pixel(x, y)
						if pixel.a > 0: # 不透明ピクセルの場合
							svg_obj.pixel_opaque_arr.append(Vector2(x,y))
							#_pixel_opaque_arr.append(Vector2(x,y))
			
				# 連続して不透明のピクセルが並ぶとき、決めた数だけスキップさせる
				var b_size:int = svg_obj.pixel_opaque_arr.size()
				svg_obj.opaque_compression(self.sprite.pixel_spacing)
				#var __size:int = svg_obj.pixel_opaque_compression_arr.size()
				#print("size=", __size)
				#print("svg_obj.pixel_opaque_compression_arr=",svg_obj.pixel_opaque_compression_arr)
				svg_obj.distance = calculate_distance(svg_obj)
				#var a_size:int = svg_obj.pixel_opaque_compression_arr.size()
				print("distance=" , svg_obj.distance)
		else:
			print("ivalid path = ", path)

func calculate_distance(svg_obj: SvgObj) -> float :
	var _size = svg_obj.image.get_size()
	var _rect = svg_obj.rect
	var center:Vector2 = self.sprite.to_global( Vector2( _rect.size.x/2, _rect.size.y/2 ))
	var max:float = -INF
	for pos:Vector2 in svg_obj.pixel_opaque_compression_arr :
		var d = center.distance_to( self.sprite.to_global(pos) )
		if max < d :
			max = d
	
	return max
	
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
	var hitter:Hit = Hit.new()
	var target:Sprite2DExt = _target
	if _is_neighborhood(target) == false:
		hitter.hit = false
		return hitter
 	# 周囲を囲む四角形
	var rect:Rect2 = self.sprite.get_rect()
	var touch:bool = false
	var svg_obj_key = self._svg_img_keys[self._texture_idx]
	var svg_obj:SvgObj = self._svg_img_map.get(svg_obj_key)
	# 不透明の境界の点を使い、衝突判定をする
	for pos in svg_obj.pixel_opaque_compression_arr:
		var _pos = Vector2(pos.x-rect.size.x/2, pos.y-rect.size.y/2)
		var _pos00:Vector2 = target.to_local(self.sprite.to_global(_pos))
		# 前後左右の矩形の９個の点で衝突判定をする
		var _diff:int = 1
		var _pos00_arr = [
			_pos00 + Vector2(-1,-1)*_diff,
			_pos00 + Vector2(-1, 0)*_diff,
			_pos00 + Vector2(-1, 1)*_diff,
			_pos00 + Vector2( 0,-1)*_diff,
			_pos00,
			_pos00 + Vector2( 0, 1)*_diff,
			_pos00 + Vector2( 1,-1)*_diff,
			_pos00 + Vector2( 1, 0)*_diff,
			_pos00 + Vector2( 1, 1)*_diff,
		]
		for __pos00:Vector2 in _pos00_arr:
			if target.costumes.sprite.is_pixel_opaque(__pos00):
				hitter.position = self.sprite.to_global(_pos)
				hitter.hit = true
				return hitter

	# 周囲の線だけによる衝突判定であるため、相手が自身の画像のなかに
	# 完全に入ってしまっているときには「衝突」とみなされない
	# その場合、相手側から衝突判定を再度行う。
	if( caller == CALLER.OWN):
		# 自身を起点とした衝突判定の場合
		# 相手の周囲の線から自身への衝突判定
		var hitter2 = target.costumes._is_pixel_touched(self.sprite, CALLER.RECALL)
		if hitter2.hit == true:
			return hitter2
		
	hitter.position = Vector2(-INF, -INF)
	return hitter

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
	var target_texture_idx = target._texture_idx
	# 自身のsvgObj
	var svg_key:String = self._svg_img_keys.get(texture_idx)
	var svg_obj:SvgObj = self._svg_img_map.get(svg_key)
	# 相手のsvgObj
	var target_svg_key:String = target.costumes._svg_img_keys.get(target_texture_idx)
	var target_svg_obj:SvgObj = target.costumes._svg_img_map.get(target_svg_key)
	
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
	
