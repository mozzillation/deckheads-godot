extends Control

enum PHASES {
	DEALING,
	CAN_PLAY,
	STAND
}

@onready var stand_button: Button = $StandButton

@onready var playerHandView := %HandsContainer/PlayerHandView
@onready var monsterHandView := %HandsContainer/MonsterHandView
@onready var playerScoreLabel := %PlayerScoreLabel
@onready var monsterScoreLabel := %MonsterScoreLabel

@onready var deckView := %DeckView

@export var start_delay : = 0.5
@export var deal_delay := 0.25

var rng := RandomNumberGenerator.new()

var deck := DeckController.new()
var playerHand := HandController.new()
var monsterHand := HandController.new()

var phase: = PHASES.DEALING


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize RNG
	rng.randomize()
	
	# Connect UI signals 
	#hit_button.pressed.connect(_on_hit_pressed)
	stand_button.pressed.connect(_on_stand_pressed)
	
	# Deal initial cards
	deal()
	
	# Bind hands
	playerHandView.bind(playerHand)
	monsterHandView.bind(monsterHand)
	
	# Bind deck
	deckView.bind(deck)
	
	playerHand.connect("score_update", func(who: HandView.WHO): 
		if not who == HandView.WHO.PLAYER:
			return
		playerScoreLabel.text = str(playerHand.get_score())
	)
	
	monsterHand.connect("score_update", func(who: HandView.WHO): 
		if not who == HandView.WHO.MONSTER:
			return
		monsterScoreLabel.text = str(monsterHand.get_score())
	)
	
	# Connect signals
	deckView.connect('card_requested', func(card: CardInstance):
		_on_hit_pressed(card)
	)


func _on_hit_pressed(card: CardInstance):
	# Add card
	playerHand.add(card, HandView.WHO.PLAYER)
	
	
	if playerHand.is_busted():
		print("BUSTED!")

func deal() -> void:
	await get_tree().process_frame  # let scene settle
	await get_tree().create_timer(start_delay).timeout

	await _deal_card(playerHand, HandView.WHO.PLAYER)
	await _deal_card(monsterHand, HandView.WHO.MONSTER)
	
	await _deal_card(playerHand, HandView.WHO.PLAYER)
	await _deal_card(monsterHand, HandView.WHO.MONSTER, true)
	
	_update_phase(PHASES.CAN_PLAY)


func _deal_card(hand: HandController, who: HandView.WHO,  is_face_down := false):
	hand.add(deck.draw(is_face_down), who)
	await get_tree().create_timer(deal_delay).timeout


func _on_stand_pressed() -> void:
	_update_phase(PHASES.STAND)
	print("monster score before: ", monsterHand.get_score())

	playerHand.reveal(HandView.WHO.PLAYER)
	monsterHand.reveal(HandView.WHO.MONSTER)
	print("card revealed")
	print("monster score after: ", monsterHand.get_score())

	
	print("player score: ", playerHand.get_score())


func _update_phase(to: PHASES) -> void:
	if phase == to:
		return

	phase = to

	match phase:
		PHASES.DEALING:
			pass
			#deckView.hide()

		PHASES.CAN_PLAY:
			deckView.play_enter_animation()
		
		PHASES.STAND:
			deckView.play_deck_exit_animation()

	
