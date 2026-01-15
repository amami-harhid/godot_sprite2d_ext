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

# 不透明部分の外周部を抽出する（Suzuki85-Method)
func get_surrounding_points(_image: Image, _number_of_skip:int=0) -> Array[Vector2]:
	var _image_size:Vector2i = _image.get_size()
	var _points:Array[Vector2] = []
	var _detection:ContourDetection.Detection = ContourDetection.Detection.new()
	var _contours_info:ContourDetection.ContoursInfo = _detection.raster_scan(_image)

	# 指定した間隔でセル情報をスキップさせ、輪郭点の配列を作る
	var _count = 0
	for _contour:ContourDetection.Contour in _contours_info.contour_list():
		for _cell:ContourDetection.Cell in _contour.list():
			if _number_of_skip==0 or _count%_number_of_skip==0:
				_points.append(_cell.to_vector2())
			_count+=1
	
	# 輪郭点を画像中心点を基準にした座標に置き換える
	var _surroundings:Array[Vector2] = []
	var _points_size: int = _points.size()
	# 画像中心を基準とした座標に変換する
	for idx in range(_points_size):
		var _pos:Vector2 = _points.get(idx)
		# 画像中心を基準(0,0)とした座標へ変換
		var _pos_m:Vector2 = Vector2(2*_pos.x-_image_size.x, 2*_pos.y-_image_size.y)/2
		_surroundings.append(_pos_m)
	return _surroundings
