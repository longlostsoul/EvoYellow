_AddPartyMon:
; Adds a new mon to the player's or enemy's party.
; [wMonDataLocation] is used in an unusual way in this function.
; If the lower nybble is 0, the mon is added to the player's party, else the enemy's.
; If the entire value is 0, then the player is allowed to name the mon.
	ld de, wPartyCount
	ld a, [wMonDataLocation]
	and $f
	jr z, .next
	ld de, wEnemyPartyCount
.next
	ld a, [de]
	inc a
	cp PARTY_LENGTH + 1
	ret nc ; return if the party is already full
	ld [de], a
	ld a, [de]
	ld [hNewPartyLength], a
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	ld a, [wcf91]
	ld [de], a ; write species of new mon in party list
	inc de
	ld a, $ff ; terminator
	ld [de], a
	ld hl, wPartyMonOT
	ld a, [wMonDataLocation]
	and $f
	jr z, .next2
	ld hl, wEnemyMonOT
.next2
	ld a, [hNewPartyLength]
	dec a
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
	ld hl, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	ld a, [wMonDataLocation]
	and a
	jr nz, .skipNaming
	ld hl, wPartyMonNicks
	ld a, [hNewPartyLength]
	dec a
	call SkipFixedLengthTextEntries
	ld a, NAME_MON_SCREEN
	ld [wNamingScreenType], a
	predef AskName
.skipNaming
	ld hl, wPartyMons
	ld a, [wMonDataLocation]
	and $f
	jr z, .next3
	ld hl, wEnemyMons
.next3
	ld a, [hNewPartyLength]
	dec a
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld e, l
	ld d, h
	push hl
	ld a, [wcf91]
	ld [wd0b5], a
	call GetMonHeader
	ld hl, wMonHeader
	ld a, [hli]
	ld [de], a ; species
	inc de
	pop hl
	push hl
	ld a, [wMonDataLocation]
	and $f
	ld a, $98     ; set enemy trainer mon IVs to fixed average values
	ld b, $88
	jr nz, .next4

; If the mon is being added to the player's party, update the pokedex.
	ld a, [wcf91]
	ld [wd11e], a
	push de
	predef IndexToPokedex
	pop de
	ld a, [wd11e]
	dec a
	ld c, a
	ld b, FLAG_TEST
	ld hl, wPokedexOwned
	call FlagAction
	ld a, c ; whether the mon was already flagged as owned
	ld [wUnusedD153], a ; not read
	ld a, [wd11e]
	dec a
	ld c, a
	ld b, FLAG_SET
	push bc
	call FlagAction
	pop bc
	ld hl, wPokedexSeen
	call FlagAction

	pop hl
	push hl

	ld a, [wIsInBattle]
	and a ; is this a wild mon caught in battle?
	jr nz, .copyEnemyMonData

; Not wild.
	call Random ; generate random IVs
	ld b, a
	call Random

.next4
	push bc
	ld bc, wPartyMon1DVs - wPartyMon1
	add hl, bc
	pop bc
	ld [hli], a
	ld [hl], b         ; write IVs
	ld bc, (wPartyMon1HPExp - 1) - (wPartyMon1DVs + 1)
	add hl, bc
	ld a, 1
	ld c, a
	xor a
	ld b, a
	call CalcStat      ; calc HP stat (set cur Hp to max HP)
	ld a, [H_MULTIPLICAND+1]
	ld [de], a
	inc de
	ld a, [H_MULTIPLICAND+2]
	ld [de], a
	inc de
	xor a
	ld [de], a         ; box level
	inc de
	ld [de], a         ; status ailments
	inc de
	jr .copyMonTypesAndMoves
.copyEnemyMonData
	ld bc, wEnemyMon1DVs - wEnemyMon1
	add hl, bc
	ld a, [wEnemyMonDVs] ; copy IVs from cur enemy mon
	ld [hli], a
	ld a, [wEnemyMonDVs + 1]
	ld [hl], a
	ld a, [wEnemyMonHP]    ; copy HP from cur enemy mon
	ld [de], a
	inc de
	ld a, [wEnemyMonHP+1]
	ld [de], a
	inc de
	xor a
	ld [de], a                ; box level
	inc de
	ld a, [wEnemyMonStatus]   ; copy status ailments from cur enemy mon
	ld [de], a
	inc de
.copyMonTypesAndMoves
	ld hl, wMonHTypes
	ld a, [hli]       ; type 1
	ld [de], a
	inc de
	ld a, [hli]       ; type 2
	ld [de], a
	inc de
	ld a, [hli]       ; catch rate (held item in gen 2)
	ld [de], a
	
	ld a, [wIsInBattle]
	and a ; is this a wild mon caught in battle?
	jr z, .notBattle
	ld hl, wEnemyMonMoves ;not wild, snagged/stolen
	jr .writeMoves
.notBattle

	ld a, [wcf91]
	cp KADABRA
	jr nz, .skipGivingTwistedSpoon
	ld a, $60 ; twistedspoon in gen 2
	ld [de], a
.skipGivingTwistedSpoon
	ld hl, wMonHMoves
.writeMoves
	ld a, [hli]
	inc de
	push de
	ld [de], a
	ld a, [hli]
	inc de
	ld [de], a
	ld a, [hli]
	inc de
	ld [de], a
	ld a, [hli]
	inc de
	ld [de], a
	push de
	dec de
	dec de
	dec de
	xor a
	ld [wLearningMovesFromDayCare], a
	predef WriteMonMoves
	pop de
	ld a, [wPlayerID]  ; set trainer ID to player ID
	inc de
	ld [de], a
	ld a, [wPlayerID + 1]
	inc de
	ld [de], a
	push de
	ld a, [wCurEnemyLVL]
	ld d, a
	callab CalcExperience
	pop de
	inc de
	ld a, [hExperience] ; write experience
	ld [de], a
	inc de
	ld a, [hExperience + 1]
	ld [de], a
	inc de
	ld a, [hExperience + 2]
	ld [de], a
	xor a
	ld b, NUM_STATS * 2
.writeEVsLoop              ; set all EVs to 0
	inc de
	ld [de], a
	dec b
	jr nz, .writeEVsLoop
	inc de
	inc de
	pop hl
	call AddPartyMon_WriteMovePP
	inc de
	ld a, [wCurEnemyLVL]
	ld [de], a
	inc de
	ld a, [wIsInBattle]
	dec a
	jr nz, .calcFreshStats
	ld hl, wEnemyMonMaxHP
	ld bc, $a
	call CopyData          ; copy stats of cur enemy mon
	pop hl
	jr .done
.calcFreshStats
	pop hl
	ld bc, wPartyMon1HPExp - 1 - wPartyMon1
	add hl, bc
	ld b, $0
	call CalcStats         ; calculate fresh set of stats
.done
	scf
	ret

LoadMovePPs:
	call GetPredefRegisters
	; fallthrough
AddPartyMon_WriteMovePP:
	ld b, NUM_MOVES
.pploop
	ld a, [hli]     ; read move ID
	and a
	jr z, .empty
	dec a
	push hl
	push de
	push bc
	ld hl, Moves
	ld bc, MoveEnd - Moves
	call AddNTimes
	ld de, wcd6d
	ld a, BANK(Moves)
	call FarCopyData
	pop bc
	pop de
	pop hl
	ld a, [wcd6d + 5] ; PP is byte 5 of move data
.empty
	inc de
	ld [de], a
	dec b
	jr nz, .pploop ; there are still moves to read
	ret

; adds enemy mon [wcf91] (at position [wWhichPokemon] in enemy list) to own party
; used in the cable club trade center
_AddEnemyMonToPlayerParty:
	ld hl, wPartyCount
	ld a, [hl]
	cp PARTY_LENGTH
	scf
	ret z            ; party full, return failure
	inc a
	ld [hl], a       ; add 1 to party members
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [wcf91]
	ld [hli], a      ; add mon as last list entry
	ld [hl], $ff     ; write new sentinel
	ld hl, wPartyMons
	ld a, [wPartyCount]
	dec a
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld e, l
	ld d, h
	ld hl, wLoadedMon
	call CopyData    ; write new mon's data (from wLoadedMon)
	ld hl, wPartyMonOT
	ld a, [wPartyCount]
	dec a
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
	ld hl, wEnemyMonOT
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
	ld bc, NAME_LENGTH
	call CopyData    ; write new mon's OT name (from an enemy mon)
	ld hl, wPartyMonNicks
	ld a, [wPartyCount]
	dec a
	call SkipFixedLengthTextEntries
	ld d, h
	ld e, l
	ld hl, wEnemyMonNicks
	ld a, [wWhichPokemon]
	call SkipFixedLengthTextEntries
	ld bc, NAME_LENGTH
	call CopyData    ; write new mon's nickname (from an enemy mon)
	ld a, [wcf91]
	ld [wd11e], a
	predef IndexToPokedex
	ld a, [wd11e]
	dec a
	ld c, a
	ld b, FLAG_SET
	ld hl, wPokedexOwned
	push bc
	call FlagAction ; add to owned pokemon
	pop bc
	ld hl, wPokedexSeen
	call FlagAction ; add to seen pokemon
	and a
	ret                  ; return success
