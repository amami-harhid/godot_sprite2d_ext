extends Node

enum CALLER  {OWN, RECALL}

# 衝突している
func is_touched( own: Sprite2DExt, target:Sprite2DExt)->Hit:
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

	# 外周点配列はグローバル座標に変換しておく
	var _surrounding_point_arr:Array[Vector2] = svg_obj.surrounding_point_arr
	var global_surrounding_point_arr:Array[Vector2] = []
	for p:Vector2 in _surrounding_point_arr:
		global_surrounding_point_arr.append(own.to_global(p))

	# 自分自身、相手の画像矩形の４点をグローバル座標の配列にしておく
	# 画像矩形は「Collision Space:Vector2i」の大きさ分、上下左右に拡大しておく
	var g_rect:Array[Vector2] = get_rectangle_arr(own)
	var g_target_rect:Array[Vector2] = get_rectangle_arr(target)
	
	#'''
	# For Debug( ノード Viewerへ 重なる点を描画する )
	# Debug用なので Viewerノードの参照は適当です
	var Viewer = $"../Scene01/Viewer"
	Viewer.texture = ImageTexture.new()
	var rect = own.get_rect()
	var image = Image.create(int(rect.size.x), int(rect.size.y), false, Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,1))
	for g_pos in global_surrounding_point_arr:
		# グローバル座標上で比較する
		if Vector2Utils.point_is_inside(g_pos, g_target_rect):
			var _pos = own.to_local(g_pos) + rect.size / 2
			image.set_pixel(_pos.x, _pos.y, Color(1,1,1,1))
	Viewer.texture.set_image(image)
	#'''

	# 自身の矩形と相手の矩形（四角形）の衝突判定
	# 相手の矩形は回転していることを前提に衝突判定をする
	var _collision = collision_rect_to_rect(g_rect, g_target_rect)
	if _collision == false: # 衝突していない
		# 近傍にないと判定する
		hitter.hit = false
		return hitter

	# 以降は、近傍にあるときの衝突判定処理	
	# 外周点の配列(global_surrounding_point_arr)は
	# ローカル座標視点で画像中心点を基準点(0,0)としたときの座標である（実際はグローバル座標に変換済）
	# 相手の矩形に含まれる外周座標に絞り込んで衝突判定をする
	# 不透明の境界の点を使い、衝突判定をする
	var touch_idx:int = 0
	# TODO pixel_spacing
	# collision_space が (2,2)未満のとき ミニマム値として 2 にしておきたい
	var collision_space = own.collision_space
	var pixel_spacing:int = int(Vector2(collision_space.x,collision_space.y).distance_to(Vector2(0,0)))
	if pixel_spacing < 2:
		pixel_spacing = 2
	#print("pixel_spacing=",pixel_spacing)
	for g_pos:Vector2 in global_surrounding_point_arr:
		touch_idx += 1
		if touch_idx > 0 and touch_idx % pixel_spacing > 0:
			continue
		# 外周のグローバル座標の点が相手の矩形の中にない場合は、無視する
		if Vector2Utils.point_is_not_inside(g_pos, g_target_rect):
			continue
		# is_pixel_opaqueは、スプライトのScale,Rotationを考慮して
		# 不透明判定をしてくれる独自関数。		
		if is_pixel_opaque(target, collision_space, g_pos):
			hitter.position = own.to_local(g_pos) # ローカル座標に直す
			hitter.hit = true
			hitter.touch_idx = touch_idx # デバッグ用
			hitter.surrounding_size = global_surrounding_point_arr.size() # デバッグ用
			return hitter
		elif is_pixel_opaque(own, own.collision_space, g_pos):
			hitter.position = own.to_local(g_pos) # ローカル座標に直す
			hitter.hit = true
			hitter.touch_idx = touch_idx # デバッグ用
			hitter.surrounding_size = global_surrounding_point_arr.size() # デバッグ用
			return hitter
	# 周囲の線だけによる衝突判定であるため、相手が自身の画像のなかに
	# 完全に入ってしまっているときには「衝突」とみなされない
	# その場合、相手側から衝突判定を再度行う。
	var g_pos:Vector2 = global_surrounding_point_arr.get(0)
	if is_pixel_opaque(own, collision_space, g_pos):
		hitter.position = own.to_local(g_pos) # ローカル座標に直す
		hitter.hit = true
		hitter.touch_idx = 0 # デバッグ用
		hitter.surrounding_size = global_surrounding_point_arr.size() # デバッグ用
		return hitter
			
	'''
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
			var own_pos_l = own.to_local(pos_g) # ローカル座標に直す
			hitter2.position = own_pos_l
			return hitter2
	'''
		
	hitter.position = Vector2(-INF, -INF)
	return hitter

# collision_space: Vector2i  の幅と高さ
# の範囲で不透明の判定をする
func is_pixel_opaque(target_sprite: Sprite2DExt, collision_space: Vector2, pos_global:Vector2)->bool:
	var pos_local:Vector2 = target_sprite.to_local(pos_global)
	if target_sprite.is_pixel_opaque(pos_local):
		return true
	var c_x = int(collision_space.x)
	var c_y = int(collision_space.y)
	if c_x < 1 or c_y < 1:
		return false
	var _diff_unit_local:Vector2 = target_sprite.to_local(Vector2(1, 1)) - target_sprite.to_local(Vector2(0, 0))
	for x in range(c_x):
		for y in range(c_y):
			if x == 0 and y == 0:
				continue
			var _diff = Vector2(x, y) * _diff_unit_local.abs()
			if target_sprite.is_pixel_opaque(pos_local - _diff):
				return true
			if target_sprite.is_pixel_opaque(pos_local + _diff):
				return true
	return false

# スプライト画像を囲む矩形(Rect2)にある４点の頂点座標を
# グローバル座標の配列（要素４個）にする
func get_rectangle_arr(_sprite:Sprite2DExt)->Array[Vector2]:
	var _rect:Rect2 = _sprite.get_rect()
	var _collision_space = _sprite.collision_space
	#_rect.position -= _collision_space
	var _rect2:Rect2 = Rect2(_rect.position-_collision_space, _rect.size+_collision_space*2)
	var _pos_target_arr: Array[Vector2] = Vector2Utils.rect2_to_array(_rect2)
	var _pos_arr: Array[Vector2] = []
	for _pos in _pos_target_arr:
		var _pos_g = _sprite.to_global(_pos)
		_pos_arr.append(
			_pos_g
		)
	return _pos_arr

# 矩形(Rect2)と傾きがある長方形(Array[Vector2])との衝突判定
func collision_rect2_to_array(own:Sprite2DExt, rect:Rect2, target:Array[Vector2])->bool:
	# Rect2の矩形の頂点（４個）を配列にする
	var rect_arr:Array[Vector2] = Vector2Utils.rect2_to_array(rect)
	var _collision:bool = Vector2Utils.collision_rectangle(rect_arr, target)
	return _collision

# 傾きがある矩形(Array[Vector2])と傾きがある矩形(Array[Vector2])との衝突判定
func collision_rect_to_rect(own_rect_arr:Array[Vector2], target_rect_arr:Array[Vector2])->bool:
	var _collision:bool = Vector2Utils.collision_rectangle(own_rect_arr, target_rect_arr)
	return _collision


func rect2_to_array_global(rect:Rect2, own:Sprite2DExt)->Array[Vector2] :
	var rect_arr:Array[Vector2] = Vector2Utils.rect2_to_array(rect)
	var _arr:Array[Vector2] = []
	for v in rect_arr:
		var _v = own.to_global(v)
		_arr.append(_v)
	return _arr

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
