# ThreadUtils
extends Node

# プロセスのループの同期をとるためのシグナル
# シーン内の一か所（トップノード内）で emit をする前提とする
signal waitNextFrame()
#signal waitNextFrame1()

# PROCESS_ALWAYS( Engine停止時に、停止する )
# when false, the timer will be paused when setting paused to true
const PROCESS_ALWAYS = true
# PROCESS_IN_PHYSICS ( timer は 物理フレームの終わりで更新される )
# when false, the timer will update at the end of the process frame.
const PROCESS_IN_PHYSICS = false
# IGNORE_TIME_SCALE ( 実時間を採用 )
# when true, the timer will ignore Engine.time_scale and update with the real, elapsed time.
const IGNORE_TIME_SCALE = true
func sleep(time_sec: float) -> void:
	await get_tree().create_timer(
		time_sec
		,PROCESS_ALWAYS 
		,PROCESS_IN_PHYSICS 
		,IGNORE_TIME_SCALE
		).timeout

func get_time() -> float:
	return Time.get_ticks_msec()
