CeladonMansion2Script:
	call EnableAutoTextBoxDrawing
	ret

CeladonMansion2TextPointers:
	dw CeladonMansion2Text1
	dw CelMansion2Text2

CeladonMansion2Text1:
	TX_ASM
	ld a, $4
	ld [wWhichTrade], a
	predef DoInGameTradeDialogue
	jp TextScriptEnd

;	TX_FAR _CeladonMansion2Text1
;	db "@"
CelMansion2Text2:
	TX_ASM
	ld a, $6
	ld [wWhichTrade], a
	predef DoInGameTradeDialogue
	jp TextScriptEnd