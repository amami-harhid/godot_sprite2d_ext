extends Node

# 不透明な点の座標(Local)を配列化
func opaque_pixels(_image:Image)-> Array:
	var _arr = []
	var _size = _image.get_size()
	# 横方向の走査
	for y in range(_size.y):
		for x in range(_size.x):
			var pixel = _image.get_pixel(x, y)
			if pixel.a > 0: # 不透明ピクセルの場合
				var _pos = Vector2(x-_size.x/2, y-_size.y/2)
				_arr.append(_pos)
	return _arr

# 不透明の点より、外周部の点を抽出する
func surrounding_points(_image: Image, skip_count: int) -> Array:
	var size:Vector2 = _image.get_size()	
	var _opaque_arr = []
	for _x:int in range(size.x):
		var x = _x
		var pixel = _image.get_pixel(x, 0)
		if pixel.a > 0:
			_opaque_arr.append(Vector2(_x, 0))
		for _y:int in range(size.y -2):
			var y = _y + 1
			var pixel00 = _image.get_pixel(x, y-1)
			var pixel01 = _image.get_pixel(x, y)
			var pixel02 = _image.get_pixel(x, y+1)
			if pixel01.a > 0:			
				if pixel00.a > 0 and pixel02.a > 0:
					if x == 0 or x == size.x -1 :
						#arr.append(pixel01)
						_opaque_arr.append(Vector2(x, y))
					else:
						var pixel_x_00 = _image.get_pixel(x-1, y)
						var pixel_x_02 = _image.get_pixel(x+1, y)
						if pixel_x_00.a > 0 and pixel_x_02.a > 0 :
							continue
						else:
							#arr.append(pixel01)
							_opaque_arr.append(Vector2(x, y))
				else:
					#arr.append(pixel01)
					_opaque_arr.append(Vector2(x, y))

		pixel = _image.get_pixel(x, size.y-1)
		if pixel.a > 0:
			#arr.append(pixel)
			_opaque_arr.append(Vector2(x, size.y -1))
		
	var _surroundings = []
	var _opaque_size = _opaque_arr.size()
	# 座標をスキップさせる
	# 画像中心を基準とした座標に変換する
	for idx in range(_opaque_size):
		if skip_count == 0 or idx % skip_count == 0:
			var _pos = _opaque_arr.get(idx)
			var _pos_m = Vector2(_pos.x-size.x/2, _pos.y-size.y/2)
			_surroundings.append(_pos_m)
		
	return _surroundings
