extends Control

#@onready var roll_button: Button = $VBoxContainer/Button
@onready var hit_button: Button = $HitButton
@onready var stand_button: Button = $StandButton

@onready var playerHandView := $PlayerHandView
@onready var monsterHandView := $MonsterHandView


var rng := RandomNumberGenerator.new()

var deck := DeckController.new()
var playerHand := HandController.new()
var monsterHand := HandController.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	rng.randomize()
	
	deal()
	#roll_button.pressed.connect(_on_roll_pressed)
	hit_button.pressed.connect(_on_hit_pressed)
	stand_button.pressed.connect(_on_stand_pressed)
	playerHandView.bind(playerHand)
	monsterHandView.bind(monsterHand)

	

#func _on_roll_pressed():
	#var monster_data := Monsters.spawn(rng)
	#print(monster_data.name)
	
func _on_hit_pressed():
	playerHand.add(deck.draw())
	
	print("score: ", playerHand.get_score())
	
	if playerHand.is_busted():
		print("BUSTED!")

func deal() -> void:
	playerHand.add(deck.draw())
	playerHand.add(deck.draw())
	monsterHand.add(deck.draw())
	monsterHand.add(deck.draw(true))
	#playerHandView.render(playerHand)

func _on_stand_pressed() -> void:
	print("monster score before: ", monsterHand.get_score())

	playerHand.reveal()
	monsterHand.reveal()
	print("card revealed")
	print("monster score after: ", monsterHand.get_score())

	
	print("player score: ", playerHand.get_score())
