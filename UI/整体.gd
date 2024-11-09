extends VBoxContainer
class_name Main

@onready var pop = %"提示框"
@onready var refresh_timer: Timer = $"Timers/定时刷新"
@onready var update_timer = $Timers/UpdateTimer
@onready var v_scroll_bar: VScrollBar = get_parent().get_v_scroll_bar()
@export var particle: CPUParticles2D
@export var default_duetime_input: LineEdit
@export var selecting_button: Button
#@export var edit_mode_control: Control
#@onready var defualt_duetime_control: Control = edit_mode_control.defualt_duetime_editer

## 是否提醒过用户更新的事了
var poped: bool = false
var subject_column = preload("res://UI/subject_field.tscn")
var place_holder: Control

var focus_list: Array
var focusing: bool = false

func update(wait: bool = true):
	if wait:
		update_timer.start()
	await update_timer.timeout
	post(parse())

func _ready():
	await create_tween().tween_interval(0.1).finished
	refresh(true)

func calculate_date(date: int) -> int:
	if not date:
		return 0
	var now_date = Time.get_date_dict_from_system()
	var result_day = Time.get_unix_time_from_datetime_dict(now_date) + (1 * 60 * 60 * 24) * date
	return result_day

func post(array: Array):
	HomeworkRequester.update_homework(JSON.stringify(array))

func get_subject_fields() -> Array[SubjectField]:
	var array: Array[SubjectField]
	for i in get_children():
		if i is SubjectField:
			array.append(i)
	return array

func get_tasks():
	var array: Array
	for i in get_subject_fields():
		array += i.get_tasks()
	return array

func free_subjects():
	# 其实不是真的删除了，只是把它其中的所有task都删除了
	for i in get_subject_fields():
		i.delete_all()

func write_check():
	var check_file = FileAccess.open("user://check_file.txt", FileAccess.WRITE)
	var okayList = [] # ["语文,卷子"]
	
	for subject in get_children():
		for i in subject.get_children():
			if i is Task and i.state:
				okayList.append(subject.subject_name + "," + i.text)
	
	check_file.store_csv_line(okayList)

func read_check():
	if not FileAccess.file_exists("user://check_file.txt"):
		return
		
	var okayList = FileAccess.open("user://check_file.txt", FileAccess.READ).get_csv_line()
	for i in okayList: # 分别为每个匹配的都完成一下
		var s = i.split(",")
		for subject in get_children():
			for task in subject.get_children():
				if task is Task and subject.subject_name == s[0] and task.text == s[1]:
					task.state = true

func open_website():
	OS.shell_open(HomeworkRequester.url + "/download_hub") 

func add_subject(subject_text: String) -> SubjectField:
	# 判断有没有重复的学科，有就直接返回
	for i in get_children():
		if i is SubjectField:
			if i.subject_name == subject_text:
				return i
	
	var new_subject = subject_column.instantiate()
	new_subject.subject_name = subject_text
	add_child(new_subject)
	return new_subject

func user_canceled_tip():
	poped = true

func extract_date(text: String) -> Array:
	# text: 今日作业xxxxxx%DATETIMESTRING（unix时间戳）
	var array: Array = text.split("%")
	if not len(text.split("%")) >= 2:
		return [text, 0]
	var date_text = int(array[1])
	return [array[0], date_text]


## 加入作业，array的格式是[{"subject":xxx, "contents":xxx}, 
## {"subject":xxx, "contents":xxx}]这样。注意，此函数没有清除功能
## 只是把解析的作业加入。
func put_in(array: Array):
	for i in array:
		var subject_name = i["subject"]
		var subject = add_subject(subject_name)
		for j in i["contents"]:
			var task_array: Array = extract_date(j)
			subject.add_task(task_array[0], task_array[1])

func parse() -> Array:
	var array: Array
	for i in get_subject_fields():
		array.append(i.parse())
	return array

func refresh(on_ready: bool = false) -> bool:
	var original: Array = await HomeworkRequester.get_homework()
	if parse() == original:
		return false
	# 先保存目前的条子的状态
	var value = v_scroll_bar.value
	refresh_timer.start()
#
	#print("刷新中" + "on_ready = ", on_ready)
	if not on_ready:
		write_check()
	
	if not original or not original is Array:
		if original == null:
			add_subject("提醒").add_task("服务器没有响应，请在设置中检查是否正确输入了服务器IP或询问管理员")
		printerr("refresh没有original")
		return false
	# 正式开始刷新
	var subject_array: Array = ["语文", "数学", "英语", "物理", "政治", "历史", "地理", "生物", "其他", "提醒"]
	# 判断是不是更新提醒
	original.reverse()
	for subject in original:  # [{ "subject": "数学", "contents": ["数学卷", "整理笔记"] }]
		if subject["subject"] == "提醒":
			if not poped:
				var now_version = HomeworkRequester.version
				var update_type:String = subject["contents"][0]
				var newest_version:String = subject["contents"][1].split("=")[1]
				var update_content = subject["contents"][2]
				var tip_text: String =  "最新版本为" + newest_version +"\n"+ update_content +"\n点击“确定”来跳转到下载网站"
				if update_type == "%important_update":
					pop.pop("重大更新", "有重大更新 " + tip_text, self, "open_website", "user_canceled_tip")
				elif update_type == "%normal_update":
					pop.pop("更新", "有更新 " + tip_text, self, "open_website", "user_canceled_tip")
	# 再reverse回来
	original.reverse()
	free_subjects()
	put_in(original)
	read_check()
	
	v_scroll_bar.value = value
	return true

func delete_tasks(tasks: Array[Task]):
	for task in tasks:
		task.queue_free()
	update()

func delete_due_task():
	var delete_array: Array[Task]
	for subject in get_subject_fields():
		for task in subject.get_tasks():
			if task.due():
				print(task.due())
				delete_array.append(task)
	delete_tasks(delete_array)

func put_place_holder():
	place_holder = Control.new()
	place_holder.custom_minimum_size = Vector2(1, 1000)
	place_holder.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(place_holder)

## 这个方法只会在编辑模式开启或关闭时被调用
func edit_mode(enable: bool):
	#refresh_timer.paused = enable
	default_duetime_input.visible = enable
	for i in get_subject_fields():
		i.edit_mode = enable
	if enable:
		refresh()
		put_place_holder()
	else:
		place_holder.queue_free()
		update()

## 在subject_field的add_task中被链接
func _on_task_state_changed(_task: Task, state: bool):
	if state:
		particle.emitting = true

func _physics_process(delta):
	for i in get_subject_fields():
		var input = int(default_duetime_input.text)
		if not input:
			input = 1
		i.default_duetime = input
	if focusing:
		focus()

func parse_with_state() -> Array:
	var with_states: Array = parse()
	#print(with_states)
	for i in get_subject_fields():
		var subject_dic: Dictionary
		for j in with_states:
			if i.subject_name == j["subject"]:
				subject_dic = j
				break
		var state_array: Array = []
		for index in range(len(subject_dic["contents"])):
			# 再找到对应的task
			var task: Task
			for j in i.get_tasks():
				var j_text = j.parse()
				var dic_text = subject_dic["contents"][index]
				if j_text == dic_text:
					task = j
			# 终于开始记录了
			state_array.append(task.state)
		subject_dic["states"] = state_array
		with_states.append(subject_dic)
	return with_states

func select_task() -> Array:
	selecting_button.show()
	# 先保存目前任务状态
	var former_state := parse_with_state()
	for i in get_tasks():
		# 然后让所有状态都为未完成
		i.state = false
	# 等待选择完成按钮的按下
	await selecting_button.pressed
	selecting_button.hide()
	var selected_tasks: Array
	for i in get_tasks():
		if i.state:
			selected_tasks.append(i)
	# 再还原回来
	for i in get_subject_fields():
		var subject_former_state: Dictionary
		for j in former_state:
			# 是叫 "subject"吧
			if j["subject"] == i.subject_name:
				subject_former_state = j
				break
		for index in range(len(subject_former_state["contents"])):
			for task in i.get_tasks():
				if task.parse() == subject_former_state["contents"][index]:
					var task_state: bool =  subject_former_state["states"][index]
					task.state = task_state
	return selected_tasks

func show_tasks() -> void:
	for i in get_tasks():
		i.show()

## 现在没啥用了
func least_difference() -> int:
	var tasks : Array = get_tasks()
	var difference: int = tasks[0].day_difference()
	for i in get_tasks():
		if i.day_difference() < difference:
			difference = i.day_difference()
	return difference

func focus_toggle(enable: bool) -> void:
	if enable:
		focus_list = await select_task()
	else:
		show_tasks()
	focusing = enable

## 逻辑：把所有没完成且在选择清单内的全都显示，其余一律不显示
func focus() -> void:
	for i in get_tasks():
		if not i in focus_list:
			i.hide()
		elif i.state == true:
			i.hide()
		
