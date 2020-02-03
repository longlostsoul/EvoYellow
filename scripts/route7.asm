Route7Script:
	call EnableAutoTextBoxDrawing
	ret

Route7TextPointers:
	dw Route7Text1
	dw Route7Tree1

Route7Text1:
	TX_FAR _Route7Text1
	db "@"
Route7Tree1:
	db $08 ; asm
	ld a, 14
	ld [wWhichTrade], a
	callba BerryTreeScript
	jp TextScriptEnd