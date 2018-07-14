MtSilver_h:
	db OVERWORLD ; tileset
	db ROUTE_22_HEIGHT, ROUTE_22_WIDTH ; dimensions (y, x)
	dw MtSilverBlocks, Route22TextPointers, DiglettsCaveScript ; blocks, texts, scripts
	db $00 ; connections
	dw MtSilverObject ; objects
