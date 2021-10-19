Museum2FScript:
	call EnableAutoTextBoxDrawing
	ret

Museum2FTextPointers:
	dw Museum2FText1
	dw Museum2FText2
	dw Museum2FText3
	dw Museum2FText4
	dw Museum2FText5
	dw Museum2FText6
	dw Museum2FText7

Museum2FText1:
  TX_ASM
  call ManualTextScroll
	ld hl, MuseumChallenge
	call PrintText
	call YesNoChoice	;prompt a yes/no choice
	ld a, [wCurrentMenuItem]	;load the player choice
	and a	;check the player choice
	jr z, .mgoodbye	;if yes, is 'ordinary citizen', jump
	;otherwise begin loading battle
	call StopAllMusic
	ld c, BANK(Music_MeetJessieJames)
	ld a, MUSIC_MEET_JESSIE_JAMES
	call PlayMusic
	ld hl, BattleMuseumPre
	call PrintText
	ld hl, wd72d;set the bits for triggering battle
	set 6, [hl]	;
	set 7, [hl]	;
	ld hl, MuseumVictory	;load text for when you win
	ld de, MuseumDefeat	;load text for when you lose
	call SaveEndBattleTextPointers	;save the win/lose text
	CheckEvent EVENT_908	;has elite 4 been beaten?
	jr z, .easyteam	;jump if not beaten
  ld a, $ff
	ld [wJoyIgnore], a
	ld a, $e
	ld a, OPP_ROCKET	;load the trainer type
	ld [wCurOpponent], a
	ld a, $2d
	ld [wTrainerNo], a	
	xor a
	ld [hJoyHeld], a
	ld [wJoyIgnore], a
	jp .mgoodbye
	
.easyteam
	ld a, [H_SPRITEINDEX]
	ld [wSpriteIndex], a
	call EngageMapTrainer
	call InitBattleEnemyParameters
	xor a
	ld [hJoyHeld], a
	jr .text2end
.mgoodbye
	ld hl, MuseumBye
	call PrintText
.text2end
	jp TextScriptEnd


Museum2FText2:
	TX_FAR _Museum2FText2
	db "@"

Museum2FText3:
	TX_FAR _Museum2FText3
	db "@"

Museum2FText4:
	TX_FAR _Museum2FText4
	db "@"

Museum2FText5:
	TX_ASM
	ld a, [wd472]
	bit 7, a
	jr nz, .asm_5c1f6
	ld hl, Museum2FText_5c20e
	call PrintText
	jr .asm_5c20b

.asm_5c1f6
	ld a, [wPikachuHappiness]
	cp 101
	jr c, .asm_5c205
	ld hl, Museum2FText_5c218
	call PrintText
	jr .asm_5c20b

.asm_5c205
	ld hl, Museum2FText_5c213
	call PrintText
.asm_5c20b
	jp TextScriptEnd

Museum2FText_5c20e:
	TX_FAR _Museum2FText5
	db "@"

Museum2FText_5c213:
	TX_FAR _Museum2FPikachuText1
	db "@"

Museum2FText_5c218:
	TX_FAR _Museum2FPikachuText2
	db "@"

Museum2FText6:
	TX_FAR _Museum2FText6
	db "@"

Museum2FText7:
	TX_FAR _Museum2FText7
	db "@"


MuseumChallenge:
	TX_FAR _MuseumChallenge
	db "@"

MuseumDefeat:
	TX_FAR _MuseumDefeat
	db "@"
	
MuseumVictory:
	TX_FAR _MuseumVictory
	db "@"

MuseumBye:
	TX_FAR _MuseumBye
	db "@"

BattleMuseumPre:
	TX_FAR _MuseumPre
	;TX_FAR _Museum2FText1
	db "@"