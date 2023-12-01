extends Spatial

func _init():
	call_deferred("set_floor", 1)

func _process(_delta):
	
	if last_frame != Engine.get_frames_drawn() and focused: # new frame!
		last_frame = Engine.get_frames_drawn()
		if len(touches_data) == 1 and len(touches) == 1: # rotate if one finger
			var v = touches_data[0].relative * 0.002
			if not self.global_rotation.x + v.y > deg2rad(90) and not self.global_rotation.x + v.y < -deg2rad(10): # todo: fix (change position_based to velocity_based!)
				self.global_rotation.x += v.y
			self.global_rotation.y += -v.x
		
		if len(touches) == 2 and len(touches_data) > 0: # scale and move if 2 fingers
			var finger_1_vector := Vector2.ZERO
			var finger_2_vector := Vector2.ZERO
			var finger_1_idx = touches.keys()[0]
			var finger_2_idx = touches.keys()[1]
			var finger_1_pos : Vector2 = touches[finger_1_idx].position
			var finger_2_pos : Vector2 = touches[finger_2_idx].position
			if touches_data[0].index == finger_1_idx:
				finger_1_vector = touches_data[0].relative
				if len(touches_data) == 2:
					finger_2_vector = touches_data[1].relative
			else:
				finger_2_vector = touches_data[0].relative
			var angle = finger_1_vector.angle_to(finger_2_vector)
			if abs(angle) < PI / 4 and not (finger_2_vector == Vector2.ZERO or finger_1_vector == Vector2.ZERO): # move
				var direction = (finger_1_vector + finger_2_vector) / 2
				self.translation += (self.global_transform.basis.x * direction.x * 0.01) * Vector3(1, 0, 1)
				self.translation += (self.global_transform.basis.y * direction.y * 0.01) * Vector3(1, 0, 1) # done: change to moving only by xy plane! and relative to "scale"
			else:
				var new_1_pos : Vector2  = finger_1_pos + finger_1_vector
				var new_2_pos : Vector2  = finger_2_pos + finger_2_vector
				var multipler = 1
				if finger_1_pos.distance_squared_to(finger_2_pos) > new_1_pos.distance_squared_to(new_2_pos): 
					multipler = -1
				$Camera.translation.z = clamp(
					$Camera.translation.z + (finger_1_vector - finger_2_vector).length() * 0.03 * multipler,
					-60,
					0.1
				)
				
		
		touches_data = []

var touches = {}
var touches_data  = []
var last_frame = 0
var focused = false
#func _input(event):
#	if event is InputEventScreenTouch:
#		if event.pressed:
#			touches[event.index] = event
#		else:
#			touches.erase(event.index)
#	if  event is InputEventScreenDrag:
#		touches_data.append(event)

func set_floor(i): # todo: rewrite
	get_parent().get_node("result/ROOF").hide()
	for n in range(1, 100):
		var res = get_parent().get_node_or_null("result/" + str(n))
		if res:
			if n < i:
				res.show()
				for children in res.get_children():
					children.show()
			if n == i:
				self.translation.y = res.translation.y
				res.show()
				for children in res.get_children():
					children.show()
				res.get_node(str(n) + "_CEIL").hide()
			if n > i:
				res.hide()
		else:
			break




func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event
		else:
			touches.erase(event.index)
	if  event is InputEventScreenDrag:
		touches_data.append(event)




func _on_UI_mouse_entered():
	focused = true


func _on_UI_mouse_exited():
	focused = false
