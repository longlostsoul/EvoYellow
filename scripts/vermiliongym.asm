VermilionGymScript:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	push hl
	call nz, VermilionGymScript_5ca4c
	pop hl
	bit 6, [hl]
	res 6, [hl]
	call nz, VermilionGymScript_5ca6d
	call EnableAutoTextBoxDrawing
	ld hl, VermilionGymTrainerHeader0
	ld de, VermilionGymScriptPointers
	ld a, [wVermilionGymCurScript]
	call ExecuteCurMapScriptInTable
	ld [wVermilionGymCurScript], a
	ret

VermilionGymScript_5ca4c:
	ld hl, Gym3CityName
	ld de, Gym3LeaderName
	jp LoadGymLeaderAndCityName

Gym3CityName:
	db "VERMILION CITY@"

Gym3LeaderName:
	db "LT.SURGE@"

VermilionGymScript_5ca6d:
	CheckEvent EVENT_2ND_LOCK_OPENED
	jr nz, .opened_second_lock
	ld a, $24
	jr .load_door_tile

.opened_second_lock
	ld a, SFX_GO_INSIDE
	call PlaySound
	ld a, $5
.load_door_tile
	ld [wNewTileBlockID], a
	lb bc, 2, 2
	predef_jump ReplaceTileBlock

VermilionGymScript_5ca8a:
	xor a
	ld [wJoyIgnore], a
	ld [wVermilionGymCurScript], a
	ld [wCurMapScript], a
	ret

VermilionGymScriptPointers:
	dw CheckFightingMapTrainers
	dw DisplayEnemyTrainerTextAndStartBattle
	dw EndTrainerBattle
	dw VermilionGymScript3

VermilionGymScript3:
	ld a, [wIsInBattle]
	cp $ff
	jp z, VermilionGymScript_5ca8a
	ld a, $f0
	ld [wJoyIgnore], a

VermilionGymScript_5caaa:
	ld a, $6
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_BEAT_LT_SURGE
	lb bc, TM_24, 1
	call GiveItem
	jr nc, .BagFull
	ld a, $7
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_TM24
	jr .set_gym_flags

.BagFull
	ld a, $8
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
.set_gym_flags
	ld hl, wObtainedBadges
	set 2, [hl]
	ld hl, wBeatGymFlags
	set 2, [hl]

	; deactivate gym trainers
	SetEventRange EVENT_BEAT_VERMILION_GYM_TRAINER_0, EVENT_BEAT_VERMILION_GYM_TRAINER_2

	jp VermilionGymScript_5ca8a

VermilionGymTextPointers:
	dw VermilionGymText1
	dw VermilionGymText2
	dw VermilionGymText3
	dw VermilionGymText4
	dw VermilionGymText5
	dw VermilionGymText6
	dw VermilionGymText7
	dw VermilionGymText8

VermilionGymTrainerHeaders:
VermilionGymTrainerHeader0:
	dbEventFlagBit EVENT_BEAT_VERMILION_GYM_TRAINER_0
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VERMILION_GYM_TRAINER_0
	dw VermilionGymBattleText1 ; TextBeforeBattle
	dw VermilionGymAfterBattleText1 ; TextAfterBattle
	dw VermilionGymEndBattleText1 ; TextEndBattle
	dw VermilionGymEndBattleText1 ; TextEndBattle

VermilionGymTrainerHeader1:
	dbEventFlagBit EVENT_BEAT_VERMILION_GYM_TRAINER_1
	db ($2 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VERMILION_GYM_TRAINER_1
	dw VermilionGymBattleText2 ; TextBeforeBattle
	dw VermilionGymAfterBattleText2 ; TextAfterBattle
	dw VermilionGymEndBattleText2 ; TextEndBattle
	dw VermilionGymEndBattleText2 ; TextEndBattle

VermilionGymTrainerHeader2:
	dbEventFlagBit EVENT_BEAT_VERMILION_GYM_TRAINER_2
	db ($3 << 4) ; trainer's view range
	dwEventFlagAddress EVENT_BEAT_VERMILION_GYM_TRAINER_2
	dw VermilionGymBattleText3 ; TextBeforeBattle
	dw VermilionGymAfterBattleText3 ; TextAfterBattle
	dw VermilionGymEndBattleText3 ; TextEndBattle
	dw VermilionGymEndBattleText3 ; TextEndBattle

	db $ff

VermilionGymText1:
	TX_ASM
	CheckEvent EVENT_BEAT_LT_SURGE
	jr z, .engage_surge
	CheckEventReuseA EVENT_GOT_TM24
	jr nz, .after_win_text
	call z, VermilionGymScript_5caaa
	call DisableWaitingAfterTextDisplay
	jr .text_script_end

.after_win_text
	ld hl, VermilionGymText_5cb72
	call PrintText
	jr .text_script_end

.engage_surge
	ld hl, VermilionGymText_5cb6d
	call PrintText
	ld hl, wd72d
	set 6, [hl]
	set 7, [hl]
	ld hl, ReceivedThunderbadgeText
	ld de, ReceivedThunderbadgeText
	call SaveEndBattleTextPointers
	ld a, [H_SPRITEINDEX]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	ld a, $3
	ld [wGymLeaderNo], a
	xor a
	ld [hJoyHeld], a
	ld a, $3
	ld [wVermilionGymCurScript], a
	ld [wCurMapScript], a
.text_script_end
	jp TextScriptEnd

VermilionGymText_5cb6d:
	TX_FAR _VermilionGymText_5cb6d
	db "@"

VermilionGymText_5cb72:
	TX_FAR _VermilionGymText_5cb72
	db "@"

VermilionGymText6:
	TX_FAR _VermilionGymText_5cb77
	db "@"

VermilionGymText7:
	TX_FAR _ReceivedTM24Text
	TX_SFX_KEY_ITEM
	TX_FAR _TM24ExplanationText
	db "@"

VermilionGymText8:
	TX_FAR _TM24NoRoomText
	db "@"

ReceivedThunderbadgeText:
	TX_FAR _ReceivedThunderbadgeText
	db "@"

VermilionGymText2:
	TX_ASM
	ld hl, VermilionGymTrainerHeader0
	call TalkToTrainer
	jp TextScriptEnd

VermilionGymBattleText1:
	TX_FAR _VermilionGymBattleText1
	db "@"

VermilionGymEndBattleText1:
	TX_FAR _VermilionGymEndBattleText1
	db "@"

VermilionGymAfterBattleText1:
	TX_FAR _VermilionGymAfterBattleText1
	db "@"

VermilionGymText3:
	TX_ASM
	ld hl, VermilionGymTrainerHeader1
	call TalkToTrainer
	jp TextScriptEnd

VermilionGymBattleText2:
	TX_FAR _VermilionGymBattleText2
	db "@"

VermilionGymEndBattleText2:
	TX_FAR _VermilionGymEndBattleText2
	db "@"

VermilionGymAfterBattleText2:
	TX_FAR _VermilionGymAfterBattleText2
	db "@"

VermilionGymText4:
	TX_ASM
	ld hl, VermilionGymTrainerHeader2
	call TalkToTrainer
	jp TextScriptEnd

VermilionGymBattleText3:
	TX_FAR _VermilionGymBattleText3
	db "@"

VermilionGymEndBattleText3:
	TX_FAR _VermilionGymEndBattleText3
	db "@"

VermilionGymAfterBattleText3:
	TX_FAR _VermilionGymAfterBattleText3
	db "@"

VermilionGymText5:
	TX_ASM
	ld a, [wBeatGymFlags]
	bit 2, a
	jr nz, .beat_surge
	ld hl, VermilionGymText_5cbf4
	call PrintText
	jr .text_script_end

.beat_surge
  ResetEvent EVENT_BEAT_LT_SURGE
  ResetEventRange EVENT_BEAT_VERMILION_GYM_TRAINER_0, EVENT_BEAT_VERMILION_GYM_TRAINER_2
	ld hl, VermilionGymText_5cbf9
	call PrintText
.text_script_end
	jp TextScriptEnd

VermilionGymText_5cbf4:
	TX_FAR _VermilionGymText_5cbf4
	db "@"

VermilionGymText_5cbf9:
	TX_FAR _VermilionGymText_5cbf9
	db "@"
