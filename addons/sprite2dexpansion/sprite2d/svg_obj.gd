# Svgテキスチャー情報
class_name SvgObj 
var name : String
var rect: Rect2
var svg_text: String
var svg_scale: float = 1.0
var svg_scale_created : float = 1.0
var texture: ImageTexture = ImageTexture.new()
var surrounding_point_arr = [] # 不透明部分の外周ピクセル配列

var empty:bool = false
# コンストラクター
func _init(_empty:bool = false) :
	self.empty = _empty

# 画像を取り出す
func get_image()->Image:
	if self.svg_scale != self.svg_scale_created:
		self.create_svg_from_text()
	return self.texture.get_image()

# テキスチャーを取り出す
func get_texture()->ImageTexture:
	return self.texture

# SVG文字列から画像を生成する
func create_svg_from_text( ) ->void:
	var image = Image.new()
	image.load_svg_from_string(self.svg_text, self.svg_scale)
	self.texture.set_image(image)
	self.svg_scale_created = self.svg_scale

# デバッグ用
func toString():
	return "name=%s,svg_scale=%f"% [self.name, self.svg_scale]
