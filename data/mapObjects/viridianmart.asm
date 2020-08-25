ViridianMartObject:
	db $0 ; border block

	db $2 ; warps
	db $7, $3, $1, $ff
	db $7, $4, $1, $ff

	db $0 ; signs

	db $4 ; objects
	object SPRITE_MART_GUY, $0, $5, STAY, RIGHT, $1 ; person
	object SPRITE_JAMES, $4, $5, STAY, LEFT, $2 ; person
	object SPRITE_JESSIE, $2, $6, STAY, UP, $3 ; person
  object SPRITE_MEOWTH, $2, $3, STAY, DOWN, $4 ; person

	; warp-to
	EVENT_DISP VIRIDIAN_MART_WIDTH, $7, $3
	EVENT_DISP VIRIDIAN_MART_WIDTH, $7, $4
