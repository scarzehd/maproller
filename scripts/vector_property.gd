extends VBoxContainer
class_name Vector2Property

# This is unused. set() isn't called when value.x and value.y are set, so this isn't super useful as a vector.
# Maybe I could split it up into x and y components and then have a get_vector() function?

var value:Vector2 :
	set(val):
		value_changed.emit(val)
		value = val

signal value_changed(value:Vector2)
