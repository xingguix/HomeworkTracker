extends CheckButton


func _on_toggled(toggled_on):
	button_pressed = toggled_on
	%"作业添加模块".visible = toggled_on
	$show.visible = toggled_on
	$hide.visible = !toggled_on
