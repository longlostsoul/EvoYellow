Func_f1e70:
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, CeladonMansion1Text_f1e96
	call PrintText
	callab IsStarterPikachuInOurParty
	ret nc
	callab GetFirstMoninWhich
	call GetPartyMonName2 ;then use TX_RAM wcd6d, gives species name but close enough
	ld hl, CeladonMansionText_f1e9c
	call PrintText
	ld a, $0
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	call Func_f1ea2
	call PrintText
	ret

CeladonMansion1Text_f1e96:
	TX_FAR _CeladonMansion1Text2
	TX_WAIT_BUTTON
	db "@"

CeladonMansionText_f1e9c:
	TX_FAR _CeladonMansion1Text6
	TX_BUTTON_SOUND
	db "@"

Func_f1ea2:
  callba GetFirstMonSpecies
  ld a, [hl]
  cp RAICHU;Riachu at this point
  jr z, .Pika
  callab FirstPartymonHappy
  ld a,[wFlag]
  ld [wTemp],a
  cp 1 ;unhappy
  jr nc, .content ;bigger than
  jr .tables
.content
  cp 10
  jr nc, .happy
  ld b,100 ;looks cute
  jr .addb
.happy
  cp 30
  jr nc, .happiest
  ld b,145 ;looks tame or happy
  jr .addb
.happiest
  ld b, 200
.addb
  add b
  ld [wTemp],a
  jr .tables
.Pika
  ld a, [wPikachuHappiness]
  ld [wTemp],a
.tables
	ld hl, PikachuHappinessThresholds_f1eb9
.asm_f1ea5
	ld a, [hli]
	inc hl
	and a
	jr z, .asm_f1eb5
	ld b, a
	ld a, [wTemp];happiness
	cp b
	jr c, .asm_f1eb5
	inc hl
	inc hl
	jr .asm_f1ea5

.asm_f1eb5
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

PikachuHappinessThresholds_f1eb9
	dw  51,      CeladonMansion1Text_f1ed5
	dw 101,      CeladonMansion1Text_f1eda
	dw 131,      CeladonMansion1Text_f1edf
	dw 161,      CeladonMansion1Text_f1ee4
	dw 201,      CeladonMansion1Text_f1ee9
	dw 255,      CeladonMansion1Text_f1eee
	dbbw 0, $ff, CeladonMansion1Text_f1eee

CeladonMansion1Text_f1ed5:
	TX_FAR _CeladonMansion1Text7
	db "@"

CeladonMansion1Text_f1eda:
	TX_FAR _CeladonMansion1Text8
	db "@"

CeladonMansion1Text_f1edf:
	TX_FAR _CeladonMansion1Text9
	db "@"

CeladonMansion1Text_f1ee4:
	TX_FAR _CeladonMansion1Text10
	db "@"

CeladonMansion1Text_f1ee9:
	TX_FAR _CeladonMansion1Text11
	db "@"

CeladonMansion1Text_f1eee:
	TX_FAR _CeladonMansion1Text12
	db "@"
