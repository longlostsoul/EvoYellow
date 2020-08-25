ViridianMartScript:
	call ViridianMartScript_1d47d
	call EnableAutoTextBoxDrawing
	ld hl, ViridianMartScriptPointers
	ld a, [wViridianMarketCurScript]
	call JumpTable
	ret

ViridianMartScript_1d47d:
	CheckEvent EVENT_OAK_GOT_PARCEL
	jr nz, .asm_1d489
	ld hl, ViridianMartTextPointers
	jr .asm_1d48c
.asm_1d489
	ld hl, ViridianMartTextPointers + $a ; starts at ViridianCashierText
.asm_1d48c
	ld a, l
	ld [wMapTextPtr], a
	ld a, h
	ld [wMapTextPtr+1], a
	ret

ViridianMartScriptPointers:
	dw ViridianMartScript0
	dw ViridianMartScript1
	dw ViridianMartScript2
	dw VScript

ViridianMartScript0:
	call UpdateSprites
	ld a, $4
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	ld hl, wSimulatedJoypadStatesEnd
	ld de, RLEMovement1d4bb
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, $1
	ld [wViridianMarketCurScript], a
	ret

RLEMovement1d4bb:
	db D_LEFT, $01
	db D_UP, $02
	db $ff

ViridianMartScript1:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	ld a, $5
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID
	lb bc, OAKS_PARCEL, 1
	call GiveItem
	SetEvent EVENT_GOT_OAKS_PARCEL
	call StopAllMusic
	ld c, BANK(Music_MeetJessieJames)
	ld a, MUSIC_MEET_JESSIE_JAMES
	call PlayMusic
	ld a, $2
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID; ViridianMartText2
	ld a, $ff
	ld [wJoyIgnore], a
	ld a, $e
	;ld hl, MJessieJamesEndBattleText
	;ld de, MJessieJamesEndBattleText
	;call SaveEndBattleTextPointers
	ld a, OPP_ROCKET
	ld [wCurOpponent], a
	ld a, $2f
	ld [wTrainerNo], a
	xor a
	ld a, $3
	ld [wViridianMarketCurScript], a
	ret


ViridianMartScript2:
	CheckEventHL EVENT_02D
	ret z
	CheckAndSetEventReuseHL EVENT_02C
	ret nz
	ld a, HS_OLD_MAN
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_OLD_MAN_1
	ld [wMissableObjectIndex], a
	predef ShowObject
	ret

VScript:
  ld a, $3
	ld [hSpriteIndexOrTextID], a
	call DisplayTextID;ld hl, ViridianMartText3
	;call PrintText
  call GBFadeOutToBlack
	ld a, HS_MART_JAMES
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_MART_JESSIE
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_MEOWTH
	ld [wMissableObjectIndex], a
	predef HideObject
	call UpdateSprites
	call Delay3
	call GBFadeInFromBlack
	ld a, $2
	ld [wViridianMarketCurScript], a
	ret

ViridianMartTextPointers:
	dw ViridianMartText1
	dw ViridianMartText2
	dw ViridianMartText3
	dw ViridianMartText4
	dw ViridianMartText5
	dw ViridianCashierText
	dw ViridianMartText2
	dw ViridianMartText3
	;dw ViridianMartText6

ViridianMartText1:
	TX_FAR _ViridianMartText1
	db "@"

;ViridianMartText6:
;	TX_FAR _ViridianMartText6
;	db "@"

ViridianMartText4:
	TX_FAR _ViridianMartText4
	db "@"

ViridianMartText5:
	TX_FAR ViridianMartParcelQuestText
	TX_SFX_KEY_ITEM
	db "@"

ViridianMartText2:
	TX_FAR _ViridianMartText2
	db "@"

ViridianMartText3:
	TX_FAR _ViridianMartText3
	db "@"
