DayCareMObject:
	db $a ; border block

	db $2 ; warps
	db $7, $2, $4, $ff
	db $7, $3, $4, $ff

	db $0 ; signs

	db $2 ; objects
	object SPRITE_GENTLEMAN, $2, $3, STAY, RIGHT, $1 ; person
  object SPRITE_LASS, $3, $2, STAY, RIGHT, $2 ; person

	; warp-to
	EVENT_DISP DAYCAREM_WIDTH, $7, $2
	EVENT_DISP DAYCAREM_WIDTH, $7, $3
