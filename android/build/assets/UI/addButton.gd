extends Button

@onready var https = $"../../../https"
@onready var content = $"../content"
@onready var subject = %subjectSelectList # 这些subjecty什么的都是输入框
@onready var alert = $"../alert"

# TODO: alert的那个渐隐效果
func _on_pressed():
	alert.text = ""
	
	var selected_subject = subject.get_selected_items()
	var selected_subject_string
	if selected_subject.size() == 1:
		selected_subject_string = subject.get_item_text(selected_subject[0])
	else:
		alert.text += "没选学科吧？或者程序有问题"
		return
		
	if not content.text:
		alert.text += "你未填入具体作业！"
		return
	
	var added: bool = false
	
	var data = await https.get_homework() #[{ "subject": "数学", "contents": ["数学卷", "整理笔记"] }, { "subject": "语文", "contents": ["语文卷", "背诗"] }]
	if not data:
		data = []
	for i in data:
		if i["subject"] == selected_subject_string:
			i["contents"].append(content.text)
			added = true
			break
	if not added: # 这就说明学科不存在
		data.append({ "subject": selected_subject_string, "contents": [content.text] })
	
	content.text = ""
	
	await https.post_homework(JSON.stringify(data))
	$"../../Timer".start()
	await $"../../Timer".timeout
	$"../../ScrollContainer/整体".refresh()
