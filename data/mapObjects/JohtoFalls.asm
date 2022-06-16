JohtoFallsObject:
	db $f ; border block

	db $1 ; warps
	db $7, $26, $1, MT_SILVER_CAVE ;warp from spot 7,26 to Mt Silver Cave
	db $0 ; signs
	;db $b, $7, $3 ; Route22FrontGateText

	db $2 ; objects
	object SPRITE_SWIMMER,$20, $6, STAY, RIGHT, $1, OPP_COOLTRAINER_M, $6
	object SPRITE_GIRL, $8, $3, STAY, DOWN, $2, OPP_JR_TRAINER_F, $4

	; warp-to
  EVENT_DISP ROUTE_22_WIDTH, $7, $26 ;any other warp activating 0th will go here. Aka, things warping to here FROM silver cave will go here in Johto.