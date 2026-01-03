extends Node

# 矩形Rect2の頂点を配列化
func rect2_to_array(rect:Rect2)->Array[Vector2]:
	var _pos_arr: Array[Vector2] = [	
		rect.position,  # 左上
		rect.position + Vector2(rect.size.x, 0), # 右上
		rect.position + rect.size, # 右下
		rect.position + Vector2(0, rect.size.y) # 左下
	]
	return _pos_arr

func collision_rectangle(rectA:Array[Vector2], rectB:Array[Vector2])->bool:
	for pos in rectA:
		var inside = point_is_inside(pos, rectB)
		if inside:
			return true
	for pos in rectB:
		var inside = point_is_inside(pos, rectA)
		if inside:
			return true
	return false

# 指定した点が四角形の中にない場合はTrue
func point_is_not_inside(point:Vector2, rect:Array[Vector2])->bool:
	return !point_is_inside(point, rect)
	
# 指定した点が四角形の中にある場合はTrue
# 指定した点が四角形の辺上、頂点にある場合、true
func point_is_inside(point:Vector2, rect:Array[Vector2])->bool:
	var size:int = rect.size()
	if size != 4 : # 頂点は４個
		return false
	for idx in range(size):
		var o:Vector2 = rect.get(idx)
		# 隣（前）の点
		var idx_A:int = idx -1
		if idx == 0 :
			idx_A = size -1
		var v_A:Vector2 = rect.get(idx_A)
		# 隣（後）の点
		var idx_B = idx +1
		if idx == size -1:
			idx_B = 0
		var v_B:Vector2 = rect.get(idx_B)
		# 隣（前）の点と指定点に向いたベクトル同士との内積
		var d1 = (v_A-o).dot((point-o))
		# 隣（後）の点と指定点に向いたベクトル同士との内積
		var d2 = (v_B-o).dot((point-o))
		# 内積のどちらかがマイナスのとき 指定点は外にある
		if d1 < 0 or d2 < 0:
			return false
	return true
