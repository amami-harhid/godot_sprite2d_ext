extends Node

enum CALLER  {OWN, RECALL}

# 衝突している
func is_touched( own: Sprite2DExt, target:Sprite2DExt, caller:CALLER = CALLER.OWN)->Hit:
	var hitter:Hit = Hit.new()	
	if target == null or target._original_sprite == null:
		print("target or target._original_sprite is null")
		hitter.hit = false
		return hitter

	var own_svg_img_keys = own._original_sprite.costumes._svg_img_keys
	var own_svg_img_map = own._original_sprite.costumes._svg_img_map
	var target_svg_img_keys = target._original_sprite.costumes._svg_img_keys
	var target_svg_img_map = target._original_sprite.costumes._svg_img_map	

#	if is_neighborhood(own, target) == false:
#		hitter.hit = false
#		return hitter
	
#	var rect:Rect2 = own._original_sprite.get_rect()
	var rect:Rect2 = own.get_rect()
	
	#var target_rect_in_own:Rect2 = get_rect2_from_target(own._original_sprite,target._original_sprite)
	var target_rect_in_own:Rect2 = get_rect2_from_target(own, target)
	
	var _intersect:Rect2 = rect.intersection(target_rect_in_own)
	if !_intersect.has_area(): # 大きさをもたない
		#print("_intersect has no area")
		hitter.hit = false
		return hitter
	#print("_intersect=",_intersect)
	
	var svg_obj_key = own_svg_img_keys[own.costumes._texture_idx]
	var svg_obj:SvgObj = own_svg_img_map.get(svg_obj_key)
	
	var target_svg_obj_key = target_svg_img_keys[target.costumes._texture_idx]
	var target_svg_obj: SvgObj = target_svg_img_map.get(target_svg_obj_key)
	var target_image: Image = target_svg_obj.get_image()
	# 相互の矩形が重なるところの外周座標のみを抽出する
	var _surrounding_point_arr = []
	for pos in svg_obj.surrounding_point_arr:
		var _pos = Vector2(pos.x-rect.size.x/2, pos.y-rect.size.y/2)
		if _intersect.has_point(_pos):
			_surrounding_point_arr.append(_pos)

	# 不透明の境界の点を使い、衝突判定をする
	for pos in _surrounding_point_arr:
		var _pos_2:Vector2 = pos + Vector2(rect.size.x/2, rect.size.y/2)
		var _pos_g:Vector2 = own.to_global(pos)
		var _pos_t_l:Vector2 = target.to_local(_pos_g)
		if target.is_pixel_opaque(_pos_t_l):
			hitter.position = pos
			hitter.hit = true
			return hitter

	# 周囲の線だけによる衝突判定であるため、相手が自身の画像のなかに
	# 完全に入ってしまっているときには「衝突」とみなされない
	# その場合、相手側から衝突判定を再度行う。
	if( caller == CALLER.OWN):
		# 自身を起点とした衝突判定の場合
		# 相手の周囲の線から自身への衝突判定
		#print("Re call")
		var hitter2 = is_touched(target, own, CALLER.RECALL)
		if hitter2.hit == true:
			#hitter2.hit = false
			return hitter2
		
	hitter.position = Vector2(-INF, -INF)
	return hitter

func get_rect2_from_target(_own:Sprite2DExt, _target: Sprite2DExt) ->Rect2 :
	
	var _posArr = []
	var _rect:Rect2 = _target.get_rect()
	#print("_rect=", _rect.position, _rect.size, _rect.end)
	_posArr.append( _rect.position ) # 左上
	_posArr.append( _rect.position + Vector2( _rect.size.x, 0 ) ) # 右上
	_posArr.append( _rect.end ) # 右下
	_posArr.append( _rect.position + Vector2(0, _rect.size.y) ) # 左下	
	var _posArr_own = []
	for _pos in _posArr:
		_posArr_own.append( _own.to_local( _target.to_global( _pos ) ) )

	var _rect_out = _enveloped_rect(_posArr_own)
	#print("_rect_out=", _rect_out)	
	return _rect_out

func _enveloped_rect( _posArr: Array ) -> Rect2:
	var own_rect_most_left = INF
	var own_rect_most_right = -INF
	var own_rect_most_top = INF
	var own_rect_most_bottom = -INF
	for _pos:Vector2 in _posArr:
		if _pos.x < own_rect_most_left:
			own_rect_most_left = _pos.x
		if _pos.x > own_rect_most_right:
			own_rect_most_right = _pos.x
		if _pos.y < own_rect_most_top:
			own_rect_most_top = _pos.y
		if _pos.y > own_rect_most_bottom:
			own_rect_most_bottom = _pos.y
	var _size = Vector2(
		own_rect_most_right - own_rect_most_left,
		own_rect_most_bottom - own_rect_most_top	
	)
	var _end = Vector2(
		own_rect_most_right,
		own_rect_most_bottom
	)
	var _start = _end - _size
	var _rect = Rect2(_start, _size)
	return _rect	


func is_touched2( own: Sprite2DExt, target:Sprite2DExt, caller:CALLER = CALLER.OWN)->Hit:
	var hitter:Hit = Hit.new()	
	if own == null or target == null:
		hitter.hit = false
		return hitter

	# Aの不透明ピクセルの座標をグローバル座標へ変換し配列化( X とする )
	# その矩形を得る( XK )
	# Targetの画像を取得  (B とする)
	# Bの不透明ピクセルの座標をグローバル座標へ変換し配列化( Y とする )
	# その矩形を得る( YK )
	# XK と YK が重なるとき、BITMAP衝突判定を開始
	# XK サイズのイメージを作成 (XKI), fill()で全体を透明に。
	# XK と YK が重なる範囲に 両方のピクセルを描画するが両方ともアルファ>0の条件付き
	# XKI へ X で 黒( a = 1.0 )を描画
	# XKI へ Y で 透明点を描画、( XK　の範囲のみ）
	# XKI の 非透明点をカウントする ( XKIO )
	# XKIO < X.size であれば接触, 以外は非接触とする

	# OWN
	var own_opaque = _get_opaque_arr(own)
	var own_rect: Rect2 = _get_image_rect(own, own_opaque)
	# TARGET
	#var time_start = ThreadUtils.get_time()
	var target_opaque = _get_opaque_arr(target)
	#var time_now = ThreadUtils.get_time()
	#print("time=", int(time_now-time_start), " ,", time_now, ",", time_start)
	var target_rect: Rect2 = _get_image_rect(target, target_opaque)
	
	# お互いのグローバル矩形が重ならないときは終了
	var _intersect:Rect2 = own_rect.intersection(target_rect)

	if !_intersect.has_area(): # 大きさをもたない
		hitter.hit = false
		#print("_intersect has no area")
		return hitter
	
	# BITMAP衝突判定を開始する
	var _test_image:Image = Image.create(int(own_rect.size.x), int(own_rect.size.y),false,Image.FORMAT_RGBA8)
	_test_image.fill(Color(0,0,0,0))
	var _opaque_pixel_count = 0
	for _own_pos:Vector2 in own_opaque:
		var _pos = _own_pos - own_rect.position
		_test_image.set_pixel(int(_pos.x), int(_pos.y), Color(0,0,0,1))
		_opaque_pixel_count += 1
	# TARGETで消す
	var _opaque_pixel_hit_count = 0
	for _target_pos: Vector2 in target_opaque:
		if _intersect.has_point(_target_pos):
			var _pos = _target_pos - target_rect.position
			var _pixel = _test_image.get_pixel(_pos.x, _pos.y)
			if _pixel.a > 0:
				_test_image.set_pixel(_pos.x, _pos.y, Color(0,0,0,0))
				_opaque_pixel_hit_count += 1
				hitter.hit = true
				hitter.position = own.to_local(_pos)

	if hitter.hit :
		return hitter
	hitter.position = Vector2(-INF, -INF)
	return hitter
	
func _get_opaque_arr(_sprite:Sprite2DExt)->Array:
	var _opaque = []
	var _image = _sprite.texture.get_image()
	var _image_size:Vector2 = _image.get_size()
	for x in range(_image_size.x):
		for y in range(_image_size.y):
			var pixel = _image.get_pixel(x, y)
			if pixel.a > 0:
				_opaque.append( _sprite.to_global(Vector2(x,y) -_image_size/2) )
	return _opaque
	
func _get_image_rect(_sprite:Sprite2DExt, _opaque: Array)-> Rect2:
	var own_rect_most_left = INF
	var own_rect_most_right = -INF
	var own_rect_most_top = INF
	var own_rect_most_bottom = -INF
	for _pos:Vector2 in _opaque:
		if _pos.x < own_rect_most_left:
			own_rect_most_left = _pos.x
		if _pos.x > own_rect_most_right:
			own_rect_most_right = _pos.x
		if _pos.y < own_rect_most_top:
			own_rect_most_top = _pos.y
		if _pos.y > own_rect_most_bottom:
			own_rect_most_bottom = _pos.y
	var _size = Vector2(
		own_rect_most_right - own_rect_most_left,
		own_rect_most_bottom - own_rect_most_top	
	)
	var _end = Vector2(
		own_rect_most_right,
		own_rect_most_bottom
	)
	var _start = _end - _size
	var _rect = Rect2(_start, _size)
	return _rect	

# 近傍にある
func is_neighborhood(own: Sprite2DExt, target:Sprite2DExt)->bool:
	
	var own_svg_img_keys = own._original_sprite.costumes._svg_img_keys
	var own_svg_img_map = own._original_sprite.costumes._svg_img_map
	var target_svg_img_keys = target._original_sprite.costumes._svg_img_keys
	var target_svg_img_map = target._original_sprite.costumes._svg_img_map	
	# 前提事項
	# 全スプライトの親の基準位置は トップのNode2Dの左上隅
	# 相手のテキスチャー設定が完了していないときは 「近傍でない」として終わる
	if own_svg_img_keys.size() ==0 or target_svg_img_keys.size() == 0:
		return false

	# 自身のTexture_idx
	var texture_idx = own.costumes._texture_idx
	# 相手のTexture_idx
	var target_texture_idx = target.costumes._texture_idx
	# 自身のsvgObj
	var svg_key:String = own_svg_img_keys.get(texture_idx)
	var svg_obj:SvgObj = own_svg_img_map.get(svg_key)
	svg_obj.distance = own.costumes.calculate_distance(svg_obj)
	# 相手のsvgObj
	var target_svg_key:String = target_svg_img_keys.get(target_texture_idx)
	var target_svg_obj:SvgObj = target_svg_img_map.get(target_svg_key)
	target_svg_obj.distance = target.costumes.calculate_distance(target_svg_obj)
	
	# 近傍最大距離( global )
	# TODO distance : Scaleを考慮する必要あり。
	# TODO Global座標で距離を産出しているはずなのでOKかも？。
	var neighborhood: float = (svg_obj.distance + target_svg_obj.distance)
	# 位置ポジションを取得	
	var pos:Vector2 = own.position
	var pos_t:Vector2 = target.position
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
		
func clone(own:Sprite2DExt) -> Sprite2DExt:
	
	var _clone = own.duplicate()
	_clone._original_sprite = own
	_clone._cloned = true
	_clone.z_index = own.z_index - 1 # 本体の後ろに表示

	return _clone
