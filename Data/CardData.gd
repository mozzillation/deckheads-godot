extends Resource

class_name CardData

enum Suit {
	HEARTS, 
	DIAMONDS, 
	CLUBS, 
	SPADES
}

@export var suit: Suit
@export var rank: int # 1 = Ace, 11 = Jack, 12 = Queen, 13 = King

func get_value() -> int:
	if rank == 1:
		return 11 # Ace's 1 or 11 value is handled in HandController
	if rank >= 11:
		return 10
	return rank

func get_rank() -> String:
	if rank == 1:
		return "A"
	if rank == 11:
		return "J"
	if rank == 12:
		return "Q"
	if rank == 13:
		return "K"
	return str(rank) # return numeric rank
	
func get_suit() -> String:
	if suit == Suit.HEARTS:
		return "Hearts"
	if suit == Suit.DIAMONDS:
		return "Diamonds"
	if suit == Suit.CLUBS:
		return "Clubs"
	if suit == Suit.SPADES:
		return "Spades"
	
	return "NULL" # fallback
