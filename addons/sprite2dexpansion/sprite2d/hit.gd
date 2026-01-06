class_name Hit

# 衝突を検出したピクセルの位置
var position :Vector2 = Vector2(INF, INF)
# 衝突しているとき true
var hit: bool = false
# 衝突したときの外周点のインデクス（デバッグ用）
var touch_idx:int = -1

var surrounding_size: int = -1
