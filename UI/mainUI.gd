extends Control

@onready var tip = %"提示框"

func _ready():	
	var date_file = FileAccess.open("user://date.txt", FileAccess.READ)
	var now_date: Dictionary= Time.get_datetime_dict_from_system()
	if not date_file: # 如果为空 就储存当前日期的字典 并弹出新人提醒
		date_file = FileAccess.open("user://date.txt", FileAccess.WRITE)
		date_file.store_string(JSON.stringify(now_date))
		
		tip.pop("欢迎！", "欢迎使用由徐智开发的作业查询系统！\n下面说明使用规则", self, "", "", true)
		tip.pop("使用规则", "您的作业栏与其他同学的作业栏都是共享的，也就是说别人添加作业你也可以看到。\n使用右上角的按钮来手动刷新\n添加与修改作业输入密钥才能进行，您可以通过微信联系管理员来快速获取密钥，并在设置中添加。\n抱有恶意的行为会被收回密钥\n祝使用愉快", self, "", "", true)
