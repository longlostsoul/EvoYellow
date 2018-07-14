MtSilverCaveObject:
	db $19 ; border block

	db $2 ; warps
	db $5, $5, $0, MT_SILVER
	db $1f, $25, $0, MT_SILVER

	db $0 ; signs

	db $2 ; objects
	object SPRITE_BUG_CATCHER,$1e, $1b, STAY, RIGHT, $1, OPP_BUG_CATCHER, $8
	object SPRITE_OAK, $21, $3, STAY, DOWN, $2, OPP_PROF_OAK, $3
  ;object SPRITE_BALL, $1e, $1c, STAY, NONE, $3, POTION not totally sure how items work
	; warp-to
	EVENT_DISP DIGLETTS_CAVE_WIDTH, $5, $5 ; silv
	EVENT_DISP DIGLETTS_CAVE_WIDTH, $1f, $25 ; silv