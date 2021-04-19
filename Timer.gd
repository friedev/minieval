extends Node

var timer
var seconds: int = 0
var minutes: int = 0

func _ready():
	if Global.game_mode == 1: 
		if Global.game_time == 60:
			minutes = 1
		elif Global.game_time == 300:
			minutes = 5
		elif Global.game_time == 600:
			minutes = 10
		elif Global.game_time == 1800:
			minutes = 30
		$timeLeftLabel.set_text(str(minutes, ":", str(seconds).pad_zeros(2)))
		timer = Timer.new()
		timer.connect("timeout",self,"_on_timer_timeout") 
		timer.set_wait_time(1)
		timer.set_one_shot(false)
		add_child(timer) 
		timer.start()


func _on_timer_timeout():
	if seconds == 0 && minutes == 0:
		Global.timer_over = true
	if seconds == 0:
		seconds = 60
		minutes -= 1
	seconds -= 1
	if minutes < 0:
		minutes = 0
		seconds = 0
	$timeLeftLabel.set_text(str(minutes, ":", str(seconds).pad_zeros(2)))
