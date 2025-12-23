extends Sprite2D
class_name Sprite2DSvg

# SVGをレンダリングする拡大率
@export var svg_scale: float = 1.0

# Bitmap Collision pixel spacing
@export var pixel_spacing: int = 0

@onready var prev_scale: Vector2 = self.scale

@onready var costumes:SvgCostumes = SvgCostumes.new(self)
