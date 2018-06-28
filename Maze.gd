var seed_x = 123456789
var seed_y = 362436069
var seed_z = 521288629
var seed_w = 88675123

var min_room_side = 4
var one_side = 12
var map = null
var root_space = null
var spaces = []
var rand = null

enum MapId {
	void,
	boundary,
	wall,
	room,
	room_to_trail,
	trail,
}

func generate( ):
	self.init( )
	self.split( self.root_space )
	self.make_room( )
	self.make_trail( )
	self.connect_trail( )
	self.fill_wall( )
	# self.debug_draw( )

func create_room( ):
	return {
		"base_x": 0,
		"base_y": 0,
		"base_z": 0,
		"size_x": 0,
		"size_y": 0,
		"size_z": 0,
		"trail": []
	}

func create_space( ):
	return {
		"base_x": 0,
		"base_y": 0,
		"base_z": 0,
		"size_x": 0,
		"size_y": 0,
		"size_z": 0,
		"room": self.create_room( ),
		"children": null
	}

func init( ):
	self.rand = preload( "res://field/XorShift.gd" ).new( )
	self.rand.x = self.seed_x
	self.rand.y = self.seed_y
	self.rand.z = self.seed_z
	self.rand.w = self.seed_w
	# マップ
	self.map = []
	for z in range( 0, self.one_side ):
		var plane = []
		for y in range( 0, self.one_side ):
			var line = []
			for x in range( 0, self.one_side ):
				line.append( MapId.void )
			plane.append( line )
		self.map.append( plane )
	# スペース
	self.root_space = self.create_space( )
	self.root_space.size_x = self.one_side
	self.root_space.size_y = self.one_side
	self.root_space.size_z = self.one_side

func split_fill( ax, ay, az, bx, by, bz ):
	# print( ax, ",", ay, ",", az, " - ", bx, ",", by, ",", bz );
	for z in range( az, bz ):
		var plane = self.map[z]
		for y in range( ay, by ):
			var line = plane[y]
			for x in range( ax, bx ):
				line[x] = MapId.boundary

func split( t_room ):
	var result = null
	var select = rand.gen( ) % 3

	if select == 0:
		result = self.split_x( t_room )
	elif select == 1:
		result = self.split_y( t_room )
	elif select == 2:
		result = self.split_z( t_room )

	if result != null:
		t_room.children = result
		self.split( result[0] )
		self.split( result[1] )
	else:
		self.spaces.append( t_room )

func split_x( t_room ):
	if t_room.size_x <= min_room_side * 2:
		return null
	# 仕切り
	var split = t_room.base_x + ( rand.gen( ) % ( t_room.size_x - min_room_side * 2 ) + min_room_side )
	self.split_fill( split, t_room.base_y, t_room.base_z, split + 1, t_room.base_y + t_room.size_y, t_room.base_z + t_room.size_z )
	# 部屋1
	var room1 = self.create_space( )
	room1.base_x = t_room.base_x
	room1.base_y = t_room.base_y
	room1.base_z = t_room.base_z
	room1.size_x = split - t_room.base_x
	room1.size_y = t_room.size_y
	room1.size_z = t_room.size_z
	# 部屋2
	var room2 = self.create_space( )
	room2.base_x = split + 1
	room2.base_y = t_room.base_y
	room2.base_z = t_room.base_z
	room2.size_x = t_room.size_x + t_room.base_x - ( split + 1 )
	room2.size_y = t_room.size_y
	room2.size_z = t_room.size_z

	return [ room1, room2 ]

func split_y( t_room ):
	if t_room.size_y <= min_room_side * 2:
		return null
	# 仕切り
	var split = t_room.base_y + ( rand.gen( ) % ( t_room.size_y - min_room_side * 2 ) + min_room_side )
	self.split_fill( t_room.base_x, split, t_room.base_z, t_room.base_x + t_room.size_x, split + 1, t_room.base_z + t_room.size_z )
	# 部屋1
	var room1 = self.create_space( )
	room1.base_x = t_room.base_x
	room1.base_y = t_room.base_y
	room1.base_z = t_room.base_z
	room1.size_x = t_room.size_x
	room1.size_y = split - t_room.base_y
	room1.size_z = t_room.size_z
	# 部屋2
	var room2 = self.create_space( )
	room2.base_x = t_room.base_x
	room2.base_y = split + 1
	room2.base_z = t_room.base_z
	room2.size_x = t_room.size_x
	room2.size_y = t_room.size_y + t_room.base_y - ( split + 1 )
	room2.size_z = t_room.size_z

	return [ room1, room2 ]

func split_z( t_room ):
	if t_room.size_z <= min_room_side * 2:
		return null
	# 仕切り
	var split = t_room.base_z + ( rand.gen( ) % ( t_room.size_z - min_room_side * 2 ) + min_room_side )
	self.split_fill( t_room.base_x, t_room.base_y, split, t_room.base_x + t_room.size_x, t_room.base_y + t_room.size_y, split + 1 )
	# 部屋1
	var room1 = self.create_space( )
	room1.base_x = t_room.base_x
	room1.base_y = t_room.base_y
	room1.base_z = t_room.base_z
	room1.size_x = t_room.size_x
	room1.size_y = t_room.size_y
	room1.size_z = split - t_room.base_z
	# 部屋2
	var room2 = self.create_space( )
	room2.base_x = t_room.base_x
	room2.base_y = t_room.base_y
	room2.base_z = split + 1
	room2.size_x = t_room.size_x
	room2.size_y = t_room.size_y
	room2.size_z = t_room.size_z + t_room.base_z - ( split + 1 )

	return [ room1, room2 ]

func make_room( ):
	for space in self.spaces:
		var room = space.room
		room.size_x = self.rand.gen( ) % ( space.size_x - min_room_side + 1 ) + min_room_side
		room.size_y = self.rand.gen( ) % ( space.size_y - min_room_side + 1 ) + min_room_side
		room.size_z = self.rand.gen( ) % ( space.size_z - min_room_side + 1 ) + min_room_side
		room.base_x = space.base_x + ( self.rand.gen( ) % ( space.size_x - space.room.size_x + 1 ) )
		room.base_y = space.base_y + ( self.rand.gen( ) % ( space.size_y - space.room.size_y + 1 ) )
		room.base_z = space.base_z + ( self.rand.gen( ) % ( space.size_z - space.room.size_z + 1 ) )

		for z in range( room.base_z, room.base_z + room.size_z ):
			var plane = self.map[z]
			for y in range( room.base_y, room.base_y + room.size_y ):
				var line = plane[y]
				for x in range( room.base_x, room.base_x + room.size_x ):
					if ( x == room.base_x ) or ( y == room.base_y ) or ( z == room.base_z ) or ( x == room.base_x + room.size_x - 1 ) or ( y == room.base_y + room.size_y - 1 ) or ( z == room.base_z + room.size_z - 1 ):
						line[x] = MapId.wall
					else:
						line[x] = MapId.room

func make_trail( ):
	for space in self.spaces:
		var room = space.room
		if 0 < space.base_x:
			var trail_y = room.base_y + ( self.rand.gen( ) % ( room.size_y - 2 ) + 1 )
			var trail_z = room.base_z + ( self.rand.gen( ) % ( room.size_z - 2 ) + 1 )
			var x = room.base_x
			while space.base_x - 1 <= x:
				self.map[trail_z][trail_y][x] = MapId.room_to_trail
				x -= 1
			self.map[trail_z][trail_y][x+1] = MapId.trail
			room.trail.append( [x+1, trail_y, trail_z] )
		if space.base_x + space.size_x < self.one_side:
			var trail_x = room.base_x + room.size_x - 1
			var trail_y = room.base_y + ( self.rand.gen( ) % ( room.size_y - 2 ) + 1 )
			var trail_z = room.base_z + ( self.rand.gen( ) % ( room.size_z - 2 ) + 1 )
			var x = trail_x
			while x <= space.base_x + space.size_x:
				self.map[trail_z][trail_y][x] = MapId.room_to_trail
				x += 1
			self.map[trail_z][trail_y][x-1] = MapId.trail
			room.trail.append( [x-1, trail_y, trail_z] )

		if 0 < space.base_y:
			var trail_x = room.base_x + ( self.rand.gen( ) % ( room.size_x - 2 ) + 1 )
			var trail_z = room.base_z + ( self.rand.gen( ) % ( room.size_z - 2 ) + 1 )
			var y = room.base_y
			while space.base_y - 1 <= y:
				self.map[trail_z][y][trail_x] = MapId.room_to_trail
				y -= 1
			self.map[trail_z][y+1][trail_x] = MapId.trail
			room.trail.append( [trail_x, y+1, trail_z] )
		if space.base_y + space.size_y < self.one_side:
			var trail_x = room.base_x + ( self.rand.gen( ) % ( room.size_x - 2 ) + 1 )
			var trail_y = room.base_y + room.size_y - 1
			var trail_z = room.base_z + ( self.rand.gen( ) % ( room.size_z - 2 ) + 1 )
			var y = trail_y
			while y <= space.base_y + space.size_y:
				self.map[trail_z][y][trail_x] = MapId.room_to_trail
				y += 1
			self.map[trail_z][y-1][trail_x] = MapId.trail
			room.trail.append( [trail_x, y-1, trail_z] )

		if 0 < space.base_z:
			var trail_x = room.base_x + ( self.rand.gen( ) % ( room.size_x - 2 ) + 1 )
			var trail_y = room.base_y + ( self.rand.gen( ) % ( room.size_y - 2 ) + 1 )
			var z = room.base_z
			while space.base_z - 1 <= z:
				self.map[z][trail_y][trail_x] = MapId.room_to_trail
				z -= 1
			self.map[z+1][trail_y][trail_x] = MapId.trail
			room.trail.append( [trail_x, trail_y, z+1] )
		if space.base_z + space.size_z < self.one_side:
			var trail_x = room.base_x + ( self.rand.gen( ) % ( room.size_x - 2 ) + 1 )
			var trail_y = room.base_y + ( self.rand.gen( ) % ( room.size_y - 2 ) + 1 )
			var trail_z = room.base_z + room.size_z - 1
			var z = trail_z
			while z <= space.base_z + space.size_z:
				self.map[z][trail_y][trail_x] = MapId.room_to_trail
				z += 1
			self.map[z-1][trail_y][trail_x] = MapId.trail
			room.trail.append( [trail_x, trail_y, z-1] )

func connect_trail( ):
	for space in self.spaces:
		# 各部屋の出入口ごと
		for trail in space.room.trail:
			# 一番近い通路を探す
			var walked = {}
			var stack = [trail + [[]]]
			var detect_steps = null
			while not stack.empty( ):
				var p = stack.pop_front( )
				var x = p[0]
				var y = p[1]
				var z = p[2]
				if x < 0 or y < 0 or z < 0 or self.one_side <= x or self.one_side <= y or self.one_side <= z:
					continue
				var cell = self.map[z][y][x]
				if cell != MapId.boundary and cell != MapId.trail:
					continue
				var pos_text = "%d_%d_%d" % [x,y,z]
				if walked.has( pos_text ):
					continue
				walked[pos_text] = true
				var steps = p[3].duplicate( )
				if cell == MapId.trail and 0 < len(steps):
					detect_steps = steps
					break
				# 6方向
				steps.append([x,y,z])
				stack.push_back([x+1,y,z,steps])
				stack.push_back([x-1,y,z,steps])
				stack.push_back([x,y+1,z,steps])
				stack.push_back([x,y-1,z,steps])
				stack.push_back([x,y,z+1,steps])
				stack.push_back([x,y,z-1,steps])
			# 繋ぐ
			if detect_steps != null:
				for step in detect_steps:
					var x = step[0]
					var y = step[1]
					var z = step[2]
					self.map[z][y][x] = MapId.trail

func fill_wall( ):
	for z in range( 0, self.one_side ):
		for y in range( 0, self.one_side ):
			for x in range( 0, self.one_side ):
				if self.map[z][y][x] == MapId.void:
					var wall = false
					if 0 < x: wall = wall or self.map[z][y][x-1] != MapId.void
					if 0 < y: wall = wall or self.map[z][y-1][x] != MapId.void
					if 0 < z: wall = wall or self.map[z-1][y][x] != MapId.void
					if x < self.one_side-1: wall = wall or self.map[z][y][x+1] != MapId.void
					if y < self.one_side-1: wall = wall or self.map[z][y+1][x] != MapId.void
					if z < self.one_side-1: wall = wall or self.map[z+1][y][x] != MapId.void
					if wall:
						self.map[z][y][x] = MapId.wall

func debug_draw( ):
	var no = 0
	var all = ""
	for plane in self.map:
		no += 1
		print( "* floor #", no )
		for line in plane:
			var s = ""
			for cell in line:
				match cell:
					MapId.room: s += "."
					MapId.room_to_trail: s += "+"
					MapId.trail: s += "*"
					MapId.boundary: s += "#"
					_: s += " "
			print( s )
