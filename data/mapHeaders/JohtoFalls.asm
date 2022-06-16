JohtoFalls_h:
	db OVERWORLD ; tileset
	db 10, 20 ; dimensions (y, x)
	dw JohtoFallsBlocks, JohtoFallsTextPointers, JohtoFallsScript ; blocks, texts, scripts
	db $00 ; connections
	dw JohtoFallsObject ; objects
