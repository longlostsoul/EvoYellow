Route4Script:
	call EnableAutoTextBoxDrawing
	ld hl, Route4TrainerHeaders
	ld de, Route4ScriptPointers
	ld a, [wRoute4CurScript]
	call ExecuteCurMapScriptInTable
	ld [wRoute4CurScript], a
	ret

Route4ScriptPointers:
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle

Route4TextPointers:
	dw Route4Text1
	dw Route4Text2
	dw PickUpItemText
	dw PokeCenterSignText
	dw Route4Text5
	dw Route4Text6
	dw Route4Tree1
	dw Route4Tree2

Route4TrainerHeaders:
Route4TrainerHeader0:
	dbEventFlagBit EVENT_BEAT_ROUTE_4_TRAINER_0
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_ROUTE_4_TRAINER_0
	dw Route4BattleText1 ; TextBeforeBattle
	dw Route4AfterBattleText1 ; TextAfterBattle
	dw Route4EndBattleText1 ; TextEndBattle
	dw Route4EndBattleText1 ; TextEndBattle

	db $ff

Route4Text1:
	TX_FAR _Route4Text1
	db "@"

Route4Text2:
	TX_ASM
	ld hl, Route4TrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

Route4BattleText1:
	TX_FAR _Route4BattleText1
	db "@"

Route4EndBattleText1:
	TX_FAR _Route4EndBattleText1
	db "@"

Route4AfterBattleText1:
	TX_FAR _Route4AfterBattleText1
	db "@"

Route4Text5:
	TX_FAR _Route4Text5
	db "@"

Route4Text6:
	TX_FAR _Route4Text6
	db "@"

Route4Tree1:
	db $08 ; asm
	ld a, 8
	ld [wWhichTrade], a
	callba BerryTreeScript
	jp TextScriptEnd
	
Route4Tree2:
	db $08 ; asm
	ld a, 9
	ld [wWhichTrade], a
	callba BerryTreeScript
	jp TextScriptEnd