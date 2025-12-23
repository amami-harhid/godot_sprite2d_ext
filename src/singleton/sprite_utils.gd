extends Node

enum CALLER  {OWN, RECALL}

# 衝突している
func is_touched( own: SvgCostumes, target:SvgCostumes, caller:CALLER = CALLER.OWN)->Hit:
	var hitter:Hit = Hit.new()	
	if own == null or target == null:
		hitter.hit = false
		return hitter

	if is_neighborhood(own, target) == false:
		hitter.hit = false
		return hitter
	
	var rect:Rect2 = own.sprite.get_rect()
	var svg_obj_key = own._svg_img_keys[own._texture_idx]
	var svg_obj:SvgObj = own._svg_img_map.get(svg_obj_key)
	# 不透明の境界の点を使い、衝突判定をする
	for pos in svg_obj.surrounding_point_arr:
		var _pos = Vector2(pos.x-rect.size.x/2, pos.y-rect.size.y/2)
		var _pos00:Vector2 = target.sprite.to_local(own.sprite.to_global(_pos))
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
			if target.sprite.is_pixel_opaque(__pos00):
				hitter.position = own.sprite.to_global(_pos)
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

# 近傍にある
func is_neighborhood(own: SvgCostumes, target:SvgCostumes)->bool:
	
	# 前提事項
	# 全スプライトの親の基準位置は トップのNode2Dの左上隅
	# 相手のテキスチャー設定が完了していないときは 「近傍でない」として終わる
	if own._svg_img_keys.size() ==0 or target._svg_img_keys.size() == 0:
		return false

	# 自身のTexture_idx
	var texture_idx = own._texture_idx
	# 相手のTexture_idx
	var target_texture_idx = target._texture_idx
	# 自身のsvgObj
	var svg_key:String = own._svg_img_keys.get(texture_idx)
	var svg_obj:SvgObj = own._svg_img_map.get(svg_key)
	svg_obj.distance = own.calculate_distance(svg_obj)
	# 相手のsvgObj
	var target_svg_key:String = target._svg_img_keys.get(target_texture_idx)
	var target_svg_obj:SvgObj = target._svg_img_map.get(target_svg_key)
	target_svg_obj.distance = target.calculate_distance(target_svg_obj)
	
	# 近傍最大距離( global )
	# TODO distance : Scaleを考慮する必要あり。
	# TODO Global座標で距離を産出しているはずなのでOKかも？。
	var neighborhood: float = (svg_obj.distance + target_svg_obj.distance)
	# 位置ポジションを取得	
	var pos:Vector2 = own.sprite.position
	var pos_t:Vector2 = target.sprite.position
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
