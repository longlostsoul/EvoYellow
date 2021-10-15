MoveDeleterText1:
	db 8 ; asm
	ld hl, MoveDeleterGreetingText
	call PrintText
	jp TextScriptEnd

DeleteMove:
; d = move id
	ld b, 0
.searchLoop
	ld a, [hli]
	cp d
	jr z, .foundMoveLoop
	inc b
	jr .searchLoop
.foundMoveLoop
	ld a, b
	cp 3
	jr z, .zeroLastMove
	ld a, [hl]
	dec hl
	ld [hli], a
	push hl
	ld de, wPartyMon1PP - wPartyMon1Moves
	add hl, de
	ld a, [hld]
	ld [hl], a ; copy move's PP
	pop hl
	inc hl
	inc b
	jr .foundMoveLoop
.zeroLastMove
	dec hl
	xor a
	ld [hl], a
	ld de, wPartyMon1PP - wPartyMon1Moves
	add hl, de
	ld [hl], a ; clear last move's PP
	ret

PrepareDeletableMoveList:
; Places a list of the selected pokemon's moves at wDeletableMoves.
; First byte is count, and last byte is $ff.
; Input: party mon index = [wWhichPokemon]
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1Moves
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	; hl = pointer to mon's 4 moves
	ld b, 0 ; count of moves
	ld c, 4 + 1 ; 4 moves
	ld de, wEnemyNumHits + 1 ;wDeletableMoves + 1
.loop
	dec c
	jr z, .done
	ld a, [hli]
	and a
	jr z, .loop
	ld [de], a
	inc de
	inc b
	jr .loop
.done
	ld a, $ff  ; terminate the list
	ld [de], a
	ld a, b  ; store number of moves
	ld [wEnemyNumHits],a ;[wDeletableMoves], a
	ret

MoveDeleterGreetingText:
	TX_FAR _MoveDeleterGreetingText
	db "@"

MoveDeleterSaidYesText:
	TX_FAR _MoveDeleterSaidYesText
	db "@"

MoveDeleterWhichMoveText:
	TX_FAR _MoveDeleterWhichMoveText
	db "@"

MoveDeleterConfirmText:
	TX_FAR _MoveDeleterConfirmText
	db "@"

MoveDeleterForgotText:
	TX_FAR _MoveDeleterForgotText
	db "@"

MoveDeleterByeText:
	TX_FAR _MoveDeleterByeText
	db "@"

MoveDeleterOneMoveText:
	TX_FAR _MoveDeleterOneMoveText
	db "@"
