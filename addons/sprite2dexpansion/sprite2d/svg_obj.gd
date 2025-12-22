# Svgテキスチャー情報
class_name SvgObj 
var name : String
var rect: Rect2
var svg_text: String
var svg_scale: float = 1.0
var svg_scale_created : float = 1.0
var image: Image = Image.new()
var texture: ImageTexture = ImageTexture.new()
var pixel_opaque_arr = [] # 不透明ピクセルすべて
var pixel_opaque_compression_arr = [] # 不透明ピクセルを圧縮した配列
var distance:float = -INF
enum Axis { X, Y }

# 不透明ピクセルの境界だけを残す
func opaque_compression(skip_count: int)->void:
	var arr = self._opaque_changed(self.image)
	pixel_opaque_compression_arr.append_array(arr)
	return

# 周囲の線のみを抽出する
func _opaque_changed(image:Image) -> Array:
	var size:Vector2i = image.get_size()	
	var arr = []
	for _x:int in range(size.x):
		var x = _x
		var pixel = image.get_pixel(x, 0)
		if pixel.a > 0:
			arr.append(Vector2(_x, 0))
		for _y:int in range(size.y -2):
			var y = _y + 1
			var pixel00 = image.get_pixel(x, y-1)
			var pixel01 = image.get_pixel(x, y)
			var pixel02 = image.get_pixel(x, y+1)
			if pixel01.a > 0:			
				if pixel00.a > 0 and pixel02.a > 0:
					if x == 0 or x == size.x -1 :
						#arr.append(pixel01)
						arr.append(Vector2(x, y))
					else:
						var pixel_x_00 = image.get_pixel(x-1, y)
						var pixel_x_02 = image.get_pixel(x+1, y)
						if pixel_x_00.a > 0 and pixel_x_02.a > 0 :
							continue
						else:
							#arr.append(pixel01)
							arr.append(Vector2(x, y))
				else:
					#arr.append(pixel01)
					arr.append(Vector2(x, y))
		pixel = image.get_pixel(x, size.y-1)
		if pixel.a > 0:
			#arr.append(pixel)
			arr.append(Vector2(x, size.y -1))
				
	return arr
		

func get_image()->Image:
	if self.svg_scale != self.svg_scale_created:
		self.create_svg_from_text()
	return self.image

func get_texture()->ImageTexture:
	texture.set_image(self.image)
	return texture

func create_svg_from_text( ) ->void:
	self.image.load_svg_from_string(self.svg_text, self.svg_scale)
	self.svg_scale_created = self.svg_scale
	
func toString():
	return "name=%s,svg_scale=%f"% [self.name, self.svg_scale]
