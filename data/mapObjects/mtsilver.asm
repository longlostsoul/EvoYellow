MtSilverObject:
	db $2c ; border block

	db $2 ; warps
	db $7, $26, $4, ROUTE_22_GATE
	db $5, $8, $1, MT_SILVER_CAVE
;db $4, $4, $1, DIGLETTS_CAVE
	db $1 ; signs
	db $b, $7, $3 ; Route22FrontGateText

	db $0 ; objects
	;object SPRITE_BLUE, $19, $5, STAY, NONE, $1 ; person
	;object SPRITE_BLUE, $19, $5, STAY, NONE, $2 ; person

	; warp-to
	EVENT_DISP ROUTE_22_WIDTH, $5, $8 ; ROUTE_22_GATE
  EVENT_DISP ROUTE_22_WIDTH, $7, $26 ; silver cave. things warping to here will go here.