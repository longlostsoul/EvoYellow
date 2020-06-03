CeladonMansion5Script:
	call EnableAutoTextBoxDrawing
	ret

CeladonMansion5TextPointers:
	dw CeladonMansion5Text1
	dw CeladonMansion5Text2

CeladonMansion5Text1:
	TX_FAR _CeladonMansion5Text1
	db "@"

CeladonMansion5Text2:
	TX_ASM
	callab SetLevel30
	ld a,[wCurEnemyLVL]
	ld c, a
	ld b, EEVEE
	call GivePokemon
	jr nc, .asm_24365
	ld a, HS_CELADON_MANSION_5_GIFT
	ld [wMissableObjectIndex], a
	predef HideObject
.asm_24365
	jp TextScriptEnd
