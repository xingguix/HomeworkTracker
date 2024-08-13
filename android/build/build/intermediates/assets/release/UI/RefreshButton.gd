extends Button


## 如果disabeld即cooldown了就无法触发了所以不用管冷却时间的事
func _on_pressed():
	pivot_offset = size / 2 * scale
	cooldown()
	var tween = create_tween()
	rotation = 0
	tween.tween_property(self, "rotation", 6.25, 1)
	
		

func cooldown():
	if not disabled:
		disabled = true
		await create_tween().tween_interval(3).finished
		rotation = 0
		disabled = false
