extends Node

# 不透明な点の座標(Local)を配列化
func opaque_pixels(_image:Image)-> Array:
	var _arr:Array[Vector2] = []
	var _size:Vector2i = _image.get_size()
	# 横方向の走査
	for y in range(_size.y):
		for x in range(_size.x):
			var pixel = _image.get_pixel(x, y)
			if pixel.a > 0: # 不透明ピクセルの場合
				var _pos = Vector2(2*x-_size.x, 2*y-_size.y)
				_arr.append(_pos / 2)
	return _arr

# 不透明の点より、外周部の点を抽出する
func surrounding_points(_image: Image, skip_count: int) -> Array:
	var size:Vector2i = _image.get_size()	
	var _opaque_arr:Array[Vector2] = []
	for _x:int in range(size.x):
		var x = _x
		var pixel:Color = _image.get_pixel(x, 0)
		if pixel.a > 0:
			_opaque_arr.append(Vector2(_x, 0))
		for _y:int in range(size.y -2):
			var y:int = _y + 1
			var pixel00 = _image.get_pixel(x, y-1)
			var pixel01 = _image.get_pixel(x, y)
			var pixel02 = _image.get_pixel(x, y+1)
			if pixel01.a > 0:
				# 前後のピクセルが不透明のとき
				if pixel00.a > 0 and pixel02.a > 0:
					if x == 0 or x == size.x -1 :
						# 先頭、もしくは最後
						_opaque_arr.append(Vector2(x, y))
					else:
						# 途中のピクセル
						var pixel_x_00:Color = _image.get_pixel(x-1, y)
						var pixel_x_02:Color = _image.get_pixel(x+1, y)
						# 両隣のピクセルが不透明のとき
						if pixel_x_00.a > 0 and pixel_x_02.a > 0 :
							# 外周ではないのでスキップする
							continue
						else:
							_opaque_arr.append(Vector2(x, y))
				else:
					_opaque_arr.append(Vector2(x, y))

		pixel = _image.get_pixel(x, size.y-1)
		if pixel.a > 0:
			#arr.append(pixel)
			_opaque_arr.append(Vector2(x, size.y -1))
		
	var _surroundings:Array[Vector2] = []
	var _opaque_size: int = _opaque_arr.size()
	# 座標をスキップさせる
	# 画像中心を基準とした座標に変換する
	for idx in range(_opaque_size):
		# スキップ無しの指定の場合、外周に追加
		# または、スキップの長さごとに外周に追加
		if skip_count == 0 or idx % skip_count == 0:
			var _pos:Vector2 = _opaque_arr.get(idx)
			# 画像中心を基準(0,0)とした座標へ変換
			var _pos_m:Vector2 = Vector2(2*_pos.x-size.x, 2*_pos.y-size.y)/2
			_surroundings.append(_pos_m)
		
	return _surroundings
