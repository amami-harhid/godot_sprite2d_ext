extends Sprite2D

@onready var crab:Sprite2DExt = $"../Crab"
@onready var niwatori: Sprite2DExt = $"../Niwatori"
func _ready() -> void:
	_loop()
	pass

func _loop() -> void:
	while true:
		_view()
		await ThreadUtils.waitNextFrame

func _view() -> void:
	if crab == null or niwatori == null:
		return
		
	self.texture = ImageTexture.new()
	var rect = crab.get_rect()
	var image = Image.create(int(rect.size.x), int(rect.size.y), false, Image.FORMAT_RGBA8)
	image.fill(Color(0,0,0,1))

	#var g_rect:Array[Vector2] = SpriteUtils.get_rectangle_arr(crab)
	var g_target_rect:Array[Vector2] = SpriteUtils.get_rectangle_arr(niwatori)
	
	var svg_obj:SvgObj = crab.costumes._get_svg_img_obj()
	var _surrounding_point_arr:Array[Vector2] = svg_obj.surrounding_point_arr
	#var global_surrounding_point_arr:Array[Vector2] = []
	
	for _pos in _surrounding_point_arr:
		var g_pos:Vector2 = crab.to_global(_pos) 
		# グローバル座標上で比較する
		if Vector2Utils.point_is_inside(g_pos, g_target_rect):
			var _pos_i:Vector2i = crab.to_local(g_pos) + rect.size / 2
			image.set_pixel(_pos_i.x, _pos_i.y, Color(1,1,1,1))
	self.texture.set_image(image)
	pass	
