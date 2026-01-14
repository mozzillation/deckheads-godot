extends RefCounted

class_name CardInstance

signal card_revealed(card: CardInstance)

var data: CardData
var is_face_down: bool = false

func _init(card_data: CardData, face_down := false):
	data = card_data
	is_face_down = face_down
	#emit_signal("card_added", self)

func reveal():
	if not is_face_down:
		return

	is_face_down = false
	
	emit_signal("card_revealed", self)
