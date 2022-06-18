JohtoFallsScript:
	call EnableAutoTextBoxDrawing
	ld hl, JohtoFallsTrainerHeaders
	ld de, JohtoFallsScriptPointers
	ld a, [wRoute4CurScript] ;Point to where the trainer flags are default stored I think. However it is possible to over-ride this by manually specifying event flags.
	call ExecuteCurMapScriptInTable
	ld [wRoute4CurScript], a
	ret

JohtoFallsScriptPointers:
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle

JohtoFallsTextPointers:
	dw JohtoFallsText1
	dw JohtoFallsText2

JohtoFallsTrainerHeaders:
JohtoFallsTrainerHeader1:
	dbEventFlagBit EVENT_90B ;I believe this is free.
	db ($2 << 4) ; trainer's view range, 4 << 4 for instance.
	dwEventFlagAddress EVENT_90B
	dw JohtoFallsBattleText1 ; TextBeforeBattle
	dw JohtoFallsAfterBattleText1 ; TextAfterBattle
	dw JohtoFallsEndBattleText1 ; TextEndBattle
	dw JohtoFallsEndBattleText1 ; TextEndBattle

JohtoFallsTrainerHeader2:
	dbEventFlagBit EVENT_90C
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_90C
	dw JohtoFallsBattleText2 ; TextBeforeBattle
	dw JohtoFallsAfterBattleText2 ; TextAfterBattle
	dw JohtoFallsEndBattleText2 ; TextEndBattle
	dw JohtoFallsEndBattleText2 ; TextEndBattle
	db $ff

JohtoFallsText1:
	TX_ASM
	ld hl, JohtoFallsTrainerHeader1
	jr JohtoFallsTalkToTrainer2

JohtoFallsText2:
	TX_ASM
	ld hl, JohtoFallsTrainerHeader2
JohtoFallsTalkToTrainer:
	call TalkToTrainer
	SetEvent EVENT_90A
	jp TextScriptEnd	

JohtoFallsTalkToTrainer2:
	call TalkToTrainer
	SetEvent EVENT_909
	jp TextScriptEnd

JohtoFallsBattleText1:
	TX_FAR _JohtoFallsBattleText1
	db "@"

JohtoFallsEndBattleText1:
	TX_FAR _JohtoFallsEndBattleText1
	db "@"

JohtoFallsAfterBattleText1:
	TX_FAR _JohtoFallsAfterBattleText1
	db "@"

JohtoFallsBattleText2:
	TX_FAR _JohtoFallsBattleText2
	db "@"

JohtoFallsEndBattleText2:
	TX_FAR _JohtoFallsEndBattleText
	db "@"

JohtoFallsAfterBattleText2:
	TX_FAR _JohtoFallsAfterBattleText2
	db "@"
