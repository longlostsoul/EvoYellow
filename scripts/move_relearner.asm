MoveRelearnerText1:
	TX_ASM
; Display the list of moves to the player.
	ld hl, MoveRelearnerGreetingText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jp nz, .exit
	xor a
	ldh [$9f], a
	ldh [$a1], a
	ld a, 5
	ldh [$a0], a  ; 500 money
	call HasEnoughMoney
	jr nc, .enoughMoney
	; not enough money
	ld hl, MoveRelearnerNotEnoughMoneyText
	call PrintText
	jp TextScriptEnd
.enoughMoney
	ld hl, MoveRelearnerSaidYesText
	call PrintText
	; Select pokemon from party.
	call SaveScreenTilesToBuffer2
	xor a
	ld [wListScrollOffset], a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wUpdateSpritesEnabled], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	push af
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	pop af
	jp c, .exit
	ld a, [wWhichPokemon]
	ld b, a
	;push bc
	;ld hl, PrepareRelearnableMoveList
	;ld b, Bank(PrepareRelearnableMoveList)
	;call Bankswitch ;
	;ld hl, MoveRelearnerWhichMoveText
	;call PrintText
	callab PrepareRelearnableMoveList 
	;ld a, [wLastFieldMoveID];[wRelearnableMoves]
	;and a
	;jr nz, .chooseMove
	;pop bc
	;ld hl, MoveRelearnerNoMovesText
	;call PrintText
	;jp TextScriptEnd
	;jp .exit
	; Charge 500 money
	xor a
	ld [wWhichTrade], a
	ld [wTrainerFacingDirection], a
	ld a, $5
	ld [wTrainerEngageDistance], a
	ld hl, wTrainerFacingDirection
	ld de, wPlayerMoney + 2
	ld c, $3
	predef SubBCDPredef
	ld hl, MoveRelearnerByeText
	call PrintText
	jp TextScriptEnd
.exit
	ld hl, MoveRelearnerByeText
	call PrintText
	jp TextScriptEnd

MoveRelearnerGreetingText:
	TX_FAR _MoveRelearnerGreetingText
	db "@"

MoveRelearnerSaidYesText:
	TX_FAR _MoveRelearnerSaidYesText
	db "@"

MoveRelearnerNotEnoughMoneyText:
	TX_FAR _MoveRelearnerNotEnoughMoneyText
	db "@"

MoveRelearnerWhichMoveText:
	TX_FAR _MoveRelearnerWhichMoveText
	db "@"

MoveRelearnerByeText:
	TX_FAR _MoveRelearnerByeText
	db "@"

MoveRelearnerNoMovesText:
	TX_FAR _MoveRelearnerNoMovesText
	db "@"
