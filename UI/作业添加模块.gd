extends Panel

@export var https: Node
@onready var content = $"content"
@onready var subject = %subjectSelectList # 这些subjecty什么的都是输入框
@onready var alert = $"alert"
@onready var date_edit = $Date
@onready var timer = $Timer

func calculate_date() -> int:
	var date: int = int(date_edit.text)
	if not date:
		return 0
	var now_date = Time.get_date_dict_from_system()
	var result_day = Time.get_unix_time_from_datetime_dict(now_date) + (1 * 60 * 60 * 24) * date
	return result_day

func generate_text(text: String) -> String:
	var date = calculate_date()
	if not date:
		return text
	else:
		return text + "%" + str(date)

# TODO: alert的那个渐隐效果
func _on_addButton_pressed():
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
	var final_text = generate_text(content.text)
	if not data:
		data = []
	for i in data:
		if i["subject"] == selected_subject_string:
			i["contents"].append(final_text)
			added = true
			break
	if not added: # 这就说明学科还没被添加
		data.append({ "subject": selected_subject_string, "contents": [final_text] })
	content.text = ""
	
	await https.post_homework(JSON.stringify(data))
	timer.start()
	await timer.timeout
	%"整体".refresh()

