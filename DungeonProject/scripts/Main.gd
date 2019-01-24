extends Node2D

var Room = preload("res://scenes/Room.tscn") #For instacing Room scene

var tile_size = 32 		#How big the tiles we generate
var num_rooms = 50		#Number of rooms we want to generate
var min_size = 4 		#Min number of tiles a room's width and height can be
var max_size = 10 		#Max number of tiles a room's width and height can be
var hspread = 400		#How much more you want the generation of rooms to be horizontal
var cull = 0.5			#Cull is a percentage and when you call cull, it culls about half the room

var path 				#AStar pathfinding object

func _ready():
	randomize()
	make_rooms()
	
func make_rooms():
	for i in range(num_rooms):									#Looping to create num_rooms amount of rooms
		var pos = Vector2(rand_range(-hspread, hspread),0)		#Setting a position
		var r = Room.instance()									#Instancing a new room
		var w = min_size + randi() % (max_size - min_size)		#Getting a random number for width
		var h = min_size +  randi() % (max_size - min_size)		#Getting a random number for height
		r.make_room(pos, Vector2(w, h) * tile_size)				#Makes the new room and passing new positions
		$Rooms.add_child(r)										#Adds the rooms to the room container
	#Have to wait for the movement to finish
	yield(get_tree().create_timer(1.1), 'timeout')				#Sets a timer to wait 1.1 second 
	
	#Culling room is when theres a possibility for the room to be deleted
	var room_positions = []										#Array to hold all the room's coordinate
	for room in $Rooms.get_children():							#For all rooms in room container
		if randf() < cull:										#If random number is less than cull then delete
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC					#Else turn the rigidbody to static mode which means it won't move anymore or 
																#have any collisions happening
			room_positions.append(Vector3(room.position.x, 		#Because AStar uses Vector3, we have to convert our Vector2 into Vector3
								room.position.y, 0))			#For the Z-Axis we set it to 0 because  we are not dealing wtih 3D
	yield(get_tree(), 'idle_frame')								#Have it pause breifly to let the room finish calculating, so we can use MST
	#Generate a minimum spanning tree (MST) connecting the rooms
	path = find_mst(room_positions)
		
func _draw():
	for room in $Rooms.get_children():									#For each room
		draw_rect(Rect2(room.position - room.size, room.size * 2),		#Draw a rectangle of its size
				Color(0, 1, 0), false)								#Draws a green rectangle and false to not fill the rectangle in
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y),
								Color(1, 1, 0), 15, true)
				
func _process(delta):
	update()
	
func _input(event):
	if event.is_action_pressed('ui_select'):		#If the space bar is pressed
		for n in $Rooms.get_children():				#get all the rooms in Rooms
			n.queue_free()							#Delete all the rooms
		path = null
		make_rooms()								#Make new rooms
		
func find_mst(nodes):
	#Prim's Algorithm
	var path = AStar.new()							#New AStar object
	path.add_point(path.get_available_point_id(), nodes.pop_front())		#Add point by getting available point ID, inserts first node from 
																			#array and take out the first node from array
	
	#Repeat until no more nodes remain
	while nodes:
		var min_dist = INF				#Minimum distance so far
		var min_p = null 				#Position of that node
		var p = null					#Current position
		#Loop through points in path
		for p1 in path.get_points():	#Goes through path and get their points
			p1 = path.get_point_position(p1)	#Gets the position of each points
			#Loop through the remaining nodes
			for p2 in nodes:
				if p1.distance_to(p2) < min_dist:		#Check to see if point1 distance to point2 is less than the current min distance
					min_dist = p1.distance_to(p2)		#If so then min_dist will have a new value
					min_p = p2							# min_p takes the new position
					p = p1								# Our current nodes because p1
		#Insert the resulting node into the path and add its conenction
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(min_p)								# Remove the nodes from the array so it isn't visited again
	return path
	