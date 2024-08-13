extends Label


func _process(_delta):
	text = "版本:" + str(ProjectSettings.get_setting("application/config/version"))
