extends Panel


func _on_cancel_pressed():
	self.hide()

func _on_accept_pressed():
	$"../../https".delete_homework()
	FileAccess.open("user://check_file.txt", FileAccess.WRITE).store_string("")
	$"../../Panel/ScrollContainer/整体".refresh()
	hide()
	%"提示框".hide()
