extends VBoxContainer
class_name SubjectField

@onready var label = $Label
@export var subject_name = "数学"
var task: PackedScene = preload("res://UI/task.tscn")
var edit_mode: bool
var default_duetime: int = 0:
	set(new_due_time):
		if default_duetime != new_due_time:
			last_default_duetime = default_duetime
			default_duetime = new_due_time
var last_default_duetime: int = 0

func _physics_process(_delta: float) -> void:
	hide_when_empty()
	label.text = subject_name
	for i in get_tasks():
		i.editable = edit_mode
	if edit_mode:
		editing()

func get_tasks() -> Array[Task]:
	var tasks: Array[Task]
	for i in get_children():
		if i is Task:
			tasks.append(i)
	return tasks
	
func add_task(task_text: String, task_date: int = 0) -> Task:
	## task_time:unix时间戳
	var new_task: Task = task.instantiate()
	new_task.text = task_text
	new_task.subject = subject_name
	new_task.date = task_date
	new_task.name = new_task.parse_with_subject()
	# 将信号绑定到整体的函数上
	new_task.task_state_changed.connect(Callable(get_parent(), "_on_task_state_changed"))
	add_child(new_task)
	return new_task
	

func get_tasks_count() -> int:
	return len(get_tasks())

func is_empty() -> bool:
	var count: int = get_tasks_count()
	if not count:
		return true
	return false

func hide_when_empty():
	visible = !is_empty()

func delete_all():
	for i in get_children():
		if i is Task:
			i.queue_free()
			
func parse():
	var dict: Dictionary = {
		"contents": [],
		"subject": subject_name
	}
	for i in get_tasks():
		dict["contents"].append(i.parse())
	return dict

func add_when_no_empty():
	var has_no_empty: bool = true
	for i in get_tasks():
		if is_new_task(i):
			has_no_empty = false
			break
	if has_no_empty:
		add_task("", Task.today_to_date(default_duetime)).editable = edit_mode

func is_new_task(task: Task) -> bool:
	if not task.text and (task.day_difference() == last_default_duetime or task.day_difference() == default_duetime):
		return true
	else:
		return false

func editing():
	add_when_no_empty()
	for i in get_children():
		if i is Task and is_new_task(i):
			i.date = Task.today_to_date(default_duetime)
