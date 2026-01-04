extends Node

enum CALLER  {OWN, RECALL}

# 衝突している
func is_touched( own: Sprite2DExt, target:Sprite2DExt, caller:CALLER = CALLER.OWN)->Hit:
	var hitter:Hit = Hit.new()	
	
	# 相手ノードの準備ができているか？( ready 完了しているか？）
	# costumesプロパティが保障されるのはready完了時点である
	if target == null or target.costumes == null :
		hitter.hit = false
		return hitter

	# SVG OBJ を用意する
	var svg_obj:SvgObj = own.costumes._get_svg_img_obj()
	var target_svg_obj:SvgObj = target.costumes._get_svg_img_obj()
	if svg_obj.empty or target_svg_obj.empty:
		# SVG OBJ が空（異常時）
		hitter.hit = false
		return hitter

	var rect:Rect2 = own.get_rect()
	var target_rect_in_own:Array[Vector2] = get_rectangle_from_target(own, target)
	'''
	# For Debug( ノード Viewerへ 重なる点を描画する )
	if caller == CALLER.OWN:
		var Viewer = $"../Scene01/Viewer"
		Viewer.texture = ImageTexture.new()
		var image = Image.create(int(rect.size.x), int(rect.size.y), false, Image.FORMAT_RGBA8)
		image.fill(Color(0,0,0,1))
		for pos in svg_obj.surrounding_point_arr:
			if Vector2Utils.point_is_inside(pos, target_rect_in_own):
				var _pos = pos + rect.size / 2
				image.set_pixel(_pos.x, _pos.y, Color(1,1,1,1))
		Viewer.texture.set_image(image)
	'''

	# 自身の矩形と相手の矩形（四角形）の衝突判定
	# 相手の矩形は回転していることを前提に衝突判定をする
	var _collision = collision_rect2_to_array(rect, target_rect_in_own)
	if _collision == false: # 衝突していない
		# 近傍にないと判定する
		hitter.hit = false
		return hitter

	# 以降は、近傍にあるときの衝突判定処理	
	# 外周点の配列(svg_obj.surrounding_point_arr)は
	# 中心点を基準点(0,0)としたときの座標である
	# 相手の矩形に含まれる外周座標に絞り込んで衝突判定をする

	# 不透明の境界の点を使い、衝突判定をする
	for pos:Vector2 in svg_obj.surrounding_point_arr:
		# 相手の矩形の中にある点の場合のみ、衝突判定をする
		if Vector2Utils.point_is_not_inside(pos, target_rect_in_own):
			continue
		var _pos_g:Vector2 = own.to_global(pos)
		var _pos_t_l:Vector2 = target.to_local(_pos_g)
		# is_pixel_opaqueは、スプライトのScale,Rotationを考慮して
		# 不透明判定をしてくれる。自前で画像(Image)から座標ピクセルを取り出して
		# 不透明判定をする方法もあるが、Scale/Rotationの値どおりに画像を変換させる
		# 必要があるので、is_pixel_opaque の方が使いやすい。
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
		var hitter2:Hit = is_touched(target, own, CALLER.RECALL)
		if hitter2.hit == true:
			# 相手側の視点にて衝突しているとき
			# 当たっている点は 相手スプライト上のローカルの点である
			# 当たっている点を 自分のローカル座標に変換する
			var target_pos = hitter2.position
			var pos_g = target.to_global(target_pos)
			var own_pos = own.to_local(pos_g)
			hitter2.position = own_pos
			return hitter2
		
	hitter.position = Vector2(-INF, -INF)
	return hitter

# 相手画像を囲む矩形(Rect2)にある４点の頂点座標を
# 自分のスプライト上のローカル座標の配列（要素４個）にする
func get_rectangle_from_target(_own:Sprite2DExt, _target:Sprite2DExt)->Array[Vector2]:
	var _rect:Rect2 = _target.get_rect()
	var _pos_target_arr: Array[Vector2] = Vector2Utils.rect2_to_array(_rect)
	var _pos_own: Array[Vector2] = []
	for _pos in _pos_target_arr:
		var _pos_g = _target.to_global(_pos)
		_pos_own.append(
			_own.to_local(_pos_g)
		)
	return _pos_own

# 矩形(Rect2)と傾きがある長方形(Array[Vector2])との衝突判定
func collision_rect2_to_array(rect:Rect2, target:Array[Vector2])->bool:
	# Rect2の矩形の頂点（４個）を配列にする
	var rect_arr:Array[Vector2] = Vector2Utils.rect2_to_array(rect)
	var _collision:bool = Vector2Utils.collision_rectangle(rect_arr, target)
	return _collision

# 相手画像を囲む矩形の頂点４座標を自スプライトのローカル座標に変換し
# 自スプライトのローカルで 水平垂直の辺をもつ矩形(Rect2)にする
func get_rect2_from_target(_own:Sprite2DExt, _target: Sprite2DExt) ->Rect2 :
	var _posArr: Array[Vector2] = []
	var _rect:Rect2 = _target.get_rect()
	_posArr.append( _rect.position ) # 左上
	_posArr.append( _rect.position + Vector2( _rect.size.x, 0 ) ) # 右上
	_posArr.append( _rect.end ) # 右下
	_posArr.append( _rect.position + Vector2(0, _rect.size.y) ) # 左下	
	var _posArr_own: Array[Vector2] = []
	for _pos:Vector2 in _posArr:
		_posArr_own.append( _own.to_local( _target.to_global( _pos ) ) )

	var _rect_out:Rect2 = _enveloped_rect(_posArr_own)
	return _rect_out

# 傾きが任意の長方形の頂点４座標の配列をもとにして、
# ４座標を囲む 水平・垂直の矩形(Rect2)を作る
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

# クローンノードを作る
# ノードの「ツリー追加」はここでは行わない
func clone(own:Sprite2DExt) -> Sprite2DExt:
	
	var _clone = own.duplicate() # 複製
	_clone._original_sprite = own # 本体スプライト
	_clone._cloned = true # クローンである
	_clone.z_index = own.z_index - 1 # 本体の後ろに表示

	return _clone
