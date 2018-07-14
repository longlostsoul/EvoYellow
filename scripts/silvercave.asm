SilverCaveScript:
	call EnableAutoTextBoxDrawing
	ld hl, SilverCaveTrainerHeaders
	ld de, SilverCaveScriptPointers
	ld a, [wRoute4CurScript]
	call ExecuteCurMapScriptInTable
	ld [wRoute4CurScript], a
	ret
;this is all pretty much just terrible junk coding. >_> however, I did eventually get it to work.

SilverCaveScriptPointers:
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle

SilverCaveTextPointers:
	dw SilverCaveText1
	dw SilverCaveText2

SilverCaveTrainerHeaders:
SilverCaveTrainerHeader1:
	dbEventFlagBit EVENT_BEAT_ROUTE_4_TRAINER_1 ;actually this one already exists elsewhere >_> don't feel like risking having it not work due to being on the 'wrong' spote or whatevs though, annoying thing. not that it worked well...
	db ($2 << 4) ; trainer's view range, 4 << 4 for instance.
	dwEventFlagAddress EVENT_BEAT_ROUTE_4_TRAINER_1
	dw SilverCaveBattleText1 ; TextBeforeBattle
	dw SilverCaveAfterBattleText1 ; TextAfterBattle
	dw SilverCaveEndBattleText1 ; TextEndBattle
	dw SilverCaveEndBattleText1 ; TextEndBattle

SilverCaveTrainerHeader2:
	dbEventFlagBit EVENT_BEAT_ROUTE_4_TRAINER_0
	db ($0 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_ROUTE_4_TRAINER_0
	dw SilverCaveBattleText2 ; TextBeforeBattle
	dw SilverCaveAfterBattleText2 ; TextAfterBattle
	dw SilverCaveEndBattleText2 ; TextEndBattle
	dw SilverCaveEndBattleText2 ; TextEndBattle
	db $ff

SilverCaveText1:
	TX_ASM
	ld hl, SilverCaveTrainerHeader1
	jr SilverCaveTalkToTrainer2

SilverCaveText2:
	TX_ASM
	ld hl, SilverCaveTrainerHeader2
SilverCaveTalkToTrainer:
	call TalkToTrainer
	SetEvent EVENT_BEAT_ROUTE_4_TRAINER_0
	jp TextScriptEnd	

SilverCaveTalkToTrainer2:
	call TalkToTrainer
	SetEvent EVENT_BEAT_ROUTE_4_TRAINER_1
	jp TextScriptEnd

SilverCaveBattleText1:
	TX_FAR _SilverCaveBattleText1
	db "@"

SilverCaveEndBattleText1:
	;SetEvent EVENT_BEAT_ROUTE_4_TRAINER_0
	TX_FAR _SilverCaveEndBattleText1
	db "@"

SilverCaveAfterBattleText1:
  ;SetEvent EVENT_BEAT_ROUTE_4_TRAINER_0
	TX_FAR _SilverCaveAfterBattleText1
	db "@"

SilverCaveBattleText2:
	TX_FAR _SilverCaveBattleText2
	db "@"

SilverCaveEndBattleText2:
 ; SetEvent EVENT_BEAT_ROUTE_4_TRAINER_1
	TX_FAR _SilverCaveEndBattleText2
	db "@"

SilverCaveAfterBattleText2:
 ; SetEvent EVENT_BEAT_ROUTE_4_TRAINER_1
	TX_FAR _SilverCaveAfterBattleText2
	db "@"
