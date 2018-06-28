var x = 123456789
var y = 362436069
var z = 521288629
var w = 88675123

func gen( ):
	var t = x ^ ( x << 11 )
	x = y
	y = z
	z = w
	w = ( w ^ ( w >> 19 ) ) ^ ( t ^ ( t >> 8 ) )
	return w & 0xffffffff
