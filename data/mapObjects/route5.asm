Route5Object:
	db $a ; border block

	db $5 ; warps
	db $1d, $a, $2, ROUTE_5_GATE
	db $1d, $9, $2, ROUTE_5_GATE
	db $21, $a, $0, ROUTE_5_GATE
	db $1b, $11, $0, PATH_ENTRANCE_ROUTE_5
	db $15, $a, $0, DAYCAREM

	db $1 ; signs
	db $1d, $11, $1 ; Route5Text1

	db $1 ; objects
	object SPRITE_BERRY_TREE, $9,$2,NONE,$FF,$2

	; warp-to
	EVENT_DISP ROUTE_5_WIDTH, $1d, $a ; ROUTE_5_GATE
	EVENT_DISP ROUTE_5_WIDTH, $1d, $9 ; ROUTE_5_GATE
	EVENT_DISP ROUTE_5_WIDTH, $21, $a ; ROUTE_5_GATE
	EVENT_DISP ROUTE_5_WIDTH, $1b, $11 ; PATH_ENTRANCE_ROUTE_5
	EVENT_DISP ROUTE_5_WIDTH, $15, $a ; DAYCAREM
