extends Control

@onready var roll_button: Button = $VBoxContainer/Button

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	roll_button.pressed.connect(_on_roll_pressed)

func _on_roll_pressed():
	var monster_data := Monsters.spawn(rng)
	print(monster_data.name)
	
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
