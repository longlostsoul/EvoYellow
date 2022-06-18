MtSilverCaveObject:
	db $19 ; border block

	db $2 ; warps
	db $4, $4, $0, JOHTO_FALLS ;warp from here loc, then location to. The location you end up on the other side is determined by that map's WARP TO, see below for example.
	db $1f, $25, $0, MT_SILVER ;warp from?

	db $0 ; signs

	db $3 ; objects
	object SPRITE_BUG_CATCHER,$1e, $1b, STAY, RIGHT, $1, OPP_BUG_CATCHER, $8
	object SPRITE_RED, $21, $3, STAY, DOWN, $2, OPP_RANDTRAINER, $1
  object SPRITE_BALL, $1e, $1c, STAY, NONE, $3, RARE_CANDY ;for items you also have to mess with hide/show sprite and hidden items list.
	; warp-to
	EVENT_DISP DIGLETTS_CAVE_WIDTH, $5, $5 ; Warps FROM Johto or anywhere else calling our first warp point will end up here in the cave.
	EVENT_DISP DIGLETTS_CAVE_WIDTH, $1f, $25 ; silv