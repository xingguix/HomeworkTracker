extends TextureButton

@onready var tip = %"提示框"

func _on_pressed():
	tip.pop("作业删除", "要清除过期的作业吗？", self, "sure", "")

func sure():
	tip.pop("确认？", "你真的要这么做吗？", self, "delete", "")

func delete():
	%"整体".delete_due_task()
