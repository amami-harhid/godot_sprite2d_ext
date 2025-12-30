extends Node

enum CALLER  {OWN, RECALL}

# 衝突している
func is_touched( own: Sprite2DExt, target:Sprite2DExt, caller:CALLER = CALLER.OWN)->Hit:
	var hitter:Hit = Hit.new()	
	
	# 相手ノードの準備ができているか？( ready 完了しているか？）
	if target == null or target.costumes == null :
		hitter.hit = false
		return hitter

	# SVG OBJ を用意する
	var svg_obj:SvgObj = own.costumes._get_svg_img_obj()
	var target_svg_obj:SvgObj = target.costumes._get_svg_img_obj()
	if svg_obj.empty or target_svg_obj.empty:
		# SVG OBJ が空（異常時）
		#print("svg obj is not ready")
		hitter.hit = false
		return hitter

	var rect:Rect2 = own.get_rect()
	var target_rect_in_own:Rect2 = get_rect2_from_target(own, target)
	var _intersect:Rect2 = rect.intersection(target_rect_in_own)
	if !_intersect.has_area(): # 大きさをもたない
		# 近傍にないと判定する
		hitter.hit = false
		return hitter


	# 以降は、近傍にあるときの衝突判定処理	

	# 相互の矩形が重なるところの外周座標のみを抽出する
	var _surrounding_point_arr = []
	for pos in svg_obj.surrounding_point_arr:
		var _pos = Vector2(pos.x-rect.size.x/2, pos.y-rect.size.y/2)
		if _intersect.has_point(_pos):
			_surrounding_point_arr.append(_pos)

	# 絞り込んだ不透明の境界の点を使い、衝突判定をする
	for pos in _surrounding_point_arr:
		var _pos_2:Vector2 = pos + Vector2(rect.size.x/2, rect.size.y/2)
		var _pos_g:Vector2 = own.to_global(pos)
		var _pos_t_l:Vector2 = target.to_local(_pos_g)
		# TODO 
		# is_pixel_opaque　は非効率のようなので、
		# ImageよりPixelを取り出して不透明判定をするようにしたい
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
		var hitter2 = is_touched(target, own, CALLER.RECALL)
		if hitter2.hit == true:
			return hitter2
		
	hitter.position = Vector2(-INF, -INF)
	return hitter

func get_rect2_from_target(_own:Sprite2DExt, _target: Sprite2DExt) ->Rect2 :
	
	var _posArr = []
	var _rect:Rect2 = _target.get_rect()
	_posArr.append( _rect.position ) # 左上
	_posArr.append( _rect.position + Vector2( _rect.size.x, 0 ) ) # 右上
	_posArr.append( _rect.end ) # 右下
	_posArr.append( _rect.position + Vector2(0, _rect.size.y) ) # 左下	
	var _posArr_own = []
	for _pos in _posArr:
		_posArr_own.append( _own.to_local( _target.to_global( _pos ) ) )

	var _rect_out = _enveloped_rect(_posArr_own)
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



		
func clone(own:Sprite2DExt) -> Sprite2DExt:
	
	var _clone = own.duplicate()
	_clone._original_sprite = own
	_clone._cloned = true
	_clone.z_index = own.z_index - 1 # 本体の後ろに表示

	return _clone
