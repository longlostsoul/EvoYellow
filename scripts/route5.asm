Route5Script:
	call EnableAutoTextBoxDrawing
	ret

Route5TextPointers:
	dw Route5Text1
	dw Route5Tree1

Route5Text1:
	TX_FAR _Route5Text1
	db "@"


Route5Tree1:
	db $08 ; asm
	ld a, 7
	ld [wWhichTrade], a
	callba BerryTreeScript
	jp TextScriptEnd