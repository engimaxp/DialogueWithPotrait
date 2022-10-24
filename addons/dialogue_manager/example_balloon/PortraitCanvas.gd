extends CanvasLayer

onready var potrait = $Potrait
onready var margin_container = $MarginContainer
onready var balloon_2 = $Balloon2

var current_potraits = {"left":[],"right":[]}
var current_index_pos = [0,0]

var lp = Vector2.ZERO
var rp = Vector2.ZERO

func _ready():
	var v_size = potrait.get_viewport_rect().size
	lp.x = v_size.x * 0.05
	rp.x = v_size.x * 0.95
#	set_height(v_size.y * 0.8)
#	var test_tween = create_tween()
#	test_tween.tween_callback(self,"show_potrait",["mort","left"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["tard","left"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["doux","right"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["vita","right"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"hide_potrait")
	
#	test_tween.tween_callback(self,"set_height",[v_size.y * 0.5])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["mort","left"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["tard","left"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["doux","right"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["vita","right"])
#
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["mort","right"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["tard","right"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["doux","left"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"show_potrait",["vita","left"])
#
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"leave_potrait",["mort"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"leave_potrait",["tard"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"leave_potrait",["doux"])
#	test_tween.tween_interval(1)
#	test_tween.tween_callback(self,"leave_potrait",["vita"])
#	test_tween.tween_interval(1)

func set_potrait_base(rect_gp,rect_s):
	if balloon_2.rect_position == Vector2.ZERO:
		balloon_2.rect_size = rect_s / 4.0
		balloon_2.rect_global_position = rect_gp
		set_height(rect_gp.y - potrait.rect_size.y * 2)
	else:
		var tween = create_tween()
		tween.parallel().tween_property(balloon_2,"rect_size",rect_s / 4.0,0.2)
		tween.parallel().tween_property(balloon_2,"rect_global_position",rect_gp,0.2)
		set_height(rect_gp.y - potrait.rect_size.y * 2)
		yield(tween,"finished")
	balloon_2.self_modulate.a = 1.0
	return true
	
func set_height(hight_pos):
	lp.y = hight_pos
	rp.y = hight_pos
	var tween = create_tween()
	for c in current_potraits.values():
		for cc in c:
			cc.pos.y = hight_pos
			tween.parallel().tween_property(cc.node,"rect_global_position:y",hight_pos,0.2)
	tween.tween_interval(0.01)

func hide_potrait():
	# all hide
	var tween = create_tween()
	for c in current_potraits.values():
		for cc in c:
			tween.parallel().tween_property(cc.node,"modulate:a",0.0,0.2)
			tween.parallel().tween_property(cc.node,"rect_global_position:y",cc.node.rect_global_position.y + cc.node.rect_size.y * 2.0,0.2)
	tween.tween_interval(0.01)
	
func destroy_potrait():
	# all hide
	var tween = create_tween()
	for c in current_potraits.values():
		for cc in c:
			tween.parallel().tween_property(cc.node,"modulate:a",0.0,0.2)
			tween.parallel().tween_property(cc.node,"rect_global_position:y",cc.node.rect_global_position.y + cc.node.rect_size.y * 2.0,0.2)
	tween.tween_interval(0.01)
	tween.tween_property(balloon_2,"modulate:a",0.0,0.2)
	yield(tween,"finished")
	current_potraits["left"].clear()
	current_potraits["right"].clear()
	for c in current_potraits.values():
		for cc in c:
			cc.node.queue_free()
	current_index_pos[0] = 0
	current_index_pos[1] = 0

func leave_potrait(name,to_other_side = false):
	var exist = null
	var tween = create_tween()
	for c in current_potraits.values():
		for cc in c:
			if cc.name == name:
				exist = cc
	if exist == null or not is_instance_valid(exist.node):
		return
	tween.parallel().tween_property(exist.node,"modulate:a",0.0,0.2)
	tween.parallel().tween_property(exist.node,"rect_global_position:y",exist.node.rect_global_position.y + exist.node.rect_size.y * 2.0,0.2)
	tween.tween_interval(0.01)
	for cc in current_potraits[exist.side]:
		if cc.index > exist.index:
			cc.index -= 1
			cc.pos.x = cc.pos.x \
				- potrait.rect_size.x * (1 if exist.side == "left" else -1)
			tween.parallel().tween_property(cc.node,"rect_global_position",cc.pos,0.2)
	current_index_pos[0 if exist.side == "left" else 1] -= 1
	
	yield(tween,"finished")
	if not to_other_side: 
		current_potraits[exist.side].erase(exist)
		exist.node.queue_free()
	else:
		tween = create_tween()
		current_potraits[exist.side].erase(exist)
		tween.tween_interval(0.01)
		var lr = "right" if exist.side == "left" else "left"
		current_potraits[lr].append(exist)
		var ip = current_index_pos[0 if lr == "left" else 1]
		current_index_pos[0 if lr == "left" else 1] += 1
		var pos_move = ip * potrait.rect_size.x * (1 if lr == "left" else -1)
		exist.node.rect_global_position = (lp if lr == "left" else rp) + Vector2(pos_move,exist.node.rect_size.y * 2.0)
		exist.node.rect_scale = Vector2(4 if lr == "left" else -4,4)
		exist.side = lr
		exist.index = ip
		exist.pos = exist.node.rect_global_position - Vector2(0,exist.node.rect_size.y * 2.0)
		# animate potrait
		tween.tween_property(exist.node,"modulate:a",1.0,0.2)
		tween.tween_property(exist.node,"rect_global_position:y",exist.node.rect_global_position.y - exist.node.rect_size.y * 2.0,0.2)
		yield(tween,"finished")


func show_potrait(name,pos = null):
	if not Constants.name_potrait.has(name):
		return true
		
	var exist = null
	var final_side = "left"
	for c in current_potraits.values():
		for cc in c:
			if cc.name == name:
				exist = cc
	if exist == null:
		var potrait_tween = create_tween()
		var p = potrait.duplicate()
		var style = potrait.get("custom_styles/panel").duplicate(true)
		style.texture = load(Constants.name_potrait[name])
		style.region_rect = Rect2(0,0,24,24)
		p.set("custom_styles/panel",style)
		p.material = potrait.material.duplicate()
		var lr = "left" if pos == null else pos
		margin_container.add_child(p)
		var ip = current_index_pos[0 if lr == "left" else 1]
		current_index_pos[0 if lr == "left" else 1] += 1
		var pos_move = ip * p.rect_size.x * (1 if lr == "left" else -1)
		p.rect_global_position = (lp if lr == "left" else rp) + Vector2(pos_move,potrait.rect_size.y * 2.0)
		p.rect_scale = Vector2(4 if lr == "left" else -4,4)
		exist = {
			"node":p,
			"name":name,
			"side":lr,
			"index":ip,
			"pos":p.rect_global_position
		}
		final_side = exist.side
		current_potraits[lr].append(exist)
		# animate potrait
		potrait_tween.tween_property(p,"modulate:a",1.0,0.2)
		potrait_tween.tween_property(p,"rect_global_position:y",p.rect_global_position.y - potrait.rect_size.y * 2.0,0.2)
	else:
		if pos != null and exist.side != pos:
			# change side
			var r = leave_potrait(exist.name,true)
			if r is GDScriptFunctionState:
				yield(r,"completed")
			final_side = "left" if exist.side == "right" else "left"
		else:
			final_side = exist.side
	var another_tween = create_tween()
	for c in current_potraits.values():
		for cc in c:
			if cc.name != name:
				if cc.node.material.get_shader_param("darken") != 0.7:
					another_tween.parallel().tween_property(cc.node.material,"shader_param/darken",0.7,0.2)
			else:
				margin_container.move_child(cc.node,margin_container.get_child_count())
				if cc.node.rect_global_position != cc.pos:
					another_tween.parallel().tween_property(cc.node,"rect_global_position:y",cc.pos.y,0.2)
				if cc.node.material.get_shader_param("darken") != 0.0:
					another_tween.parallel().tween_property(cc.node.material,"shader_param/darken",0.0,0.2)
	another_tween.tween_interval(0.01)
	yield(another_tween,"finished")
	return final_side == "left"
