extends Control

@onready var key = $key
@onready var random = $random
@onready var user_name = $name
@onready var submit = $submit

func _on_random_pressed():
	key.text = str(randi_range(1000, 10000))

func _on_submit_pressed():
	print(HomeworkRequester)
	HomeworkRequester.add_key([key.text, user_name.text])
