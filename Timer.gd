extends Node

var timer
var seconds: int = 0
var minutes: int = 0

func _ready():
	if Global.game_mode == 1: 
		Global.timer_over = false
		minutes = int(Global.game_time / 60)
		seconds = Global.game_time % 60
		$timeLeftLabel.set_text(str(minutes, ":", str(seconds).pad_zeros(2)))
		timer = Timer.new()
		timer.connect("timeout",self,"_on_timer_timeout") 
		timer.set_wait_time(1)
		timer.set_one_shot(false)
		add_child(timer) 
		timer.start()


func _on_timer_timeout():
	if seconds == 0 and minutes == 0:
		Global.timer_over = true
	if seconds == 0:
		seconds = 60
		minutes -= 1
	seconds -= 1
	if minutes < 0:
		minutes = 0
		seconds = 0
	$timeLeftLabel.set_text(str(minutes, ":", str(seconds).pad_zeros(2)))
