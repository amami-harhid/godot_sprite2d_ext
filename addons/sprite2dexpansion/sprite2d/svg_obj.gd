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
var surrounding_point_arr = [] # 不透明ピクセルを圧縮した配列
var distance:float = -INF
enum Axis { X, Y }

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
