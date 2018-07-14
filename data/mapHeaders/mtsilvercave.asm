MtSilverCave_h:
	db CAVERN ; tileset
	db DIGLETTS_CAVE_HEIGHT, DIGLETTS_CAVE_WIDTH ; dimensions (y, x)
	dw MtSilverCaveBlocks, SilverCaveTextPointers, SilverCaveScript ; blocks, texts, scripts
	db $00 ; connections
	dw MtSilverCaveObject ; objects
