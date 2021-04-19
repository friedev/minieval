extends Node

var timer
var seconds_remaining: int = 0


func update_label():
	var hours = int(seconds_remaining / 3600)
	var minutes = int(seconds_remaining / 60) % 60
	var seconds = seconds_remaining % 60
	if hours > 0:
		$timeLeftLabel.set_text("%d:%02d:%02d" % [hours, minutes, seconds])
	else:
		$timeLeftLabel.set_text("%d:%02d" % [minutes, seconds])


func _ready():
	if Global.game_mode == 1: 
		Global.timer_over = false
		seconds_remaining = Global.game_time
		update_label()
		
		timer = Timer.new()
		timer.connect("timeout", self, "_on_timer_timeout") 
		timer.set_wait_time(1)
		timer.set_one_shot(false)
		add_child(timer) 
		timer.start()


func _on_timer_timeout():
	seconds_remaining -= 1
	update_label()
	
	if seconds_remaining == 0:
		Global.timer_over = true
		timer.queue_free()
