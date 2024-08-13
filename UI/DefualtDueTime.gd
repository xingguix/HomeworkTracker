extends Control

@onready var line_edit = $Label/LineEdit

func get_defualt_duetime() -> int:
	return int(line_edit.text)

func clear():
	line_edit.text = ""
