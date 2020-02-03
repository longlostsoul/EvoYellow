Route7Object:
	db $f ; border block

	db $5 ; warps
	db $9, $12, $2, ROUTE_7_GATE
	db $a, $12, $2, ROUTE_7_GATE
	db $9, $b, $0, ROUTE_7_GATE
	db $a, $b, $0, ROUTE_7_GATE
	db $d, $5, $0, PATH_ENTRANCE_ROUTE_7

	db $1 ; signs
	db $d, $3, $1 ; Route7Text1

	db $1 ; people
	object SPRITE_BERRY_TREE, $F,$5,  NONE, $ff, $2
	; warp-to
	EVENT_DISP ROUTE_7_WIDTH, $9, $12 ; ROUTE_7_GATE
	EVENT_DISP ROUTE_7_WIDTH, $a, $12 ; ROUTE_7_GATE
	EVENT_DISP ROUTE_7_WIDTH, $9, $b ; ROUTE_7_GATE
	EVENT_DISP ROUTE_7_WIDTH, $a, $b ; ROUTE_7_GATE
	EVENT_DISP ROUTE_7_WIDTH, $d, $5 ; PATH_ENTRANCE_ROUTE_7
