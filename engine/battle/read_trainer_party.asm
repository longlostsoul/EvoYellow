ReadTrainer:

; don't change any moves in a link battle
	ld a,[wLinkState]
	and a
	ret nz

; set [wEnemyPartyCount] to 0, [wEnemyPartyMons] to FF
; XXX first is total enemy pokemon?
; XXX second is species of first pokemon?
	ld hl,wEnemyPartyCount
	xor a
	ld [hli],a
	dec a
	ld [hl],a

; get the pointer to trainer data for this class
	ld a,[wTrainerClass] ; get trainer class
	dec a
	add a
	ld hl,TrainerDataPointers
	ld c,a
	ld b,0
	add hl,bc ; hl points to trainer class
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[wTrainerNo]
	ld b,a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.outer
	dec b
	jr z,.IterateTrainer
.inner
	ld a,[hli]
	and a
	jr nz,.inner
	jr .outer

; if the first byte of trainer data is FF,
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
; else the first byte is the level of every pokemon on the team
.IterateTrainer
	ld a,[hli]
	cp $FF ; is the trainer special?
	jr z,.SpecialTrainer ; if so, check for special moves
	ld [wCurEnemyLVL],a
	ld a,[wMode]
	cp 0 ;is it normal mode? then skip over-ride.
  jr z, .LoopTrainerData
  call ModifyTrainerLevel ;new code, average the levels.
  ;ld a, [wPartyMon1Level] ;older code to let party member 1 decide
  ;ld [wCurEnemyLVL],a
.LoopTrainerData
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jp z, .AddAdditionalMoveData
	ld [wcf91],a ; write species somewhere (XXX why?)
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push hl
	call AddPartyMon
	pop hl
	jr .LoopTrainerData
.SpecialTrainer
; if this code is being run:
; - each pokemon has a specific level
;      (as opposed to the whole team being of the same level)
; - if [wLoneAttackNo] != 0, one pokemon on the team has a special move
	ld a,[hli]
	and a ; have we reached the end of the trainer data?
	jr z,.AddAdditionalMoveData
	ld [wCurEnemyLVL],a
  ld a,[wMode]
  cp 0
  jr z, .notMode
  call ModifyTrainerLevel
.notMode
	ld a,[hli]
	ld [wcf91],a
	ld a,ENEMY_PARTY_DATA
	ld [wMonDataLocation],a
	push hl
	call AddPartyMon
	pop hl
	jr .SpecialTrainer
.AddAdditionalMoveData
; does the trainer have additional move data?
	ld a, [wTrainerClass]
	ld b, a
	ld a, [wTrainerNo]
	ld c, a
	ld hl, SpecialTrainerMoves
.loopAdditionalMoveData
	ld a, [hli]
	cp $ff
	jr z, .FinishUp
	cp b
	jr nz, .asm_39c46
	ld a, [hli]
	cp c
	jr nz, .asm_39c46
	ld d, h
	ld e, l
.writeAdditionalMoveDataLoop
	ld a, [de]
	inc de
	and a
	jp z, .FinishUp
	dec a
	ld hl, wEnemyMon1Moves
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld a, [de]
	inc de
	dec a
	ld c, a
	ld b, 0
	add hl,bc
	ld a, [de]
	inc de
	ld [hl], a
	jr .writeAdditionalMoveDataLoop
.asm_39c46
	ld a, [hli]
	and a
	jr nz, .asm_39c46
	jr .loopAdditionalMoveData
.FinishUp
; clear wAmountMoneyWon addresses
	xor a
	ld de,wAmountMoneyWon
	ld [de],a
	inc de
	ld [de],a
	inc de
	ld [de],a
	ld a,[wCurEnemyLVL]
	ld b,a
.LastLoop
; update wAmountMoneyWon addresses (money to win) based on enemy's level
	ld hl,wTrainerBaseMoney + 1
	ld c,2 ; wAmountMoneyWon is a 3-byte number
	push bc
	predef AddBCDPredef
	pop bc
	inc de
	inc de
	dec b
	jr nz,.LastLoop ; repeat wCurEnemyLVL times
	ret
	
ModifyTrainerLevel: ;Pokemon Roaming Red, average trainer levels and make Elite still higher level, make things a little more balanced.
	push af
	push bc
	push de
	push hl
	ld b, 0
	ld d, 0
	ld a, [wPartyCount]
	ld c, a
	ld hl, wPartyMon1Level
.searchLevel
	ld a, [hl]	
	cp d
	jp c, .noHigherLevel
	ld d, a	
.noHigherLevel	
	push bc
	ld bc, 44
	add hl, bc
	pop bc
	inc b
	ld a, b
	cp c
	jp nz, .searchLevel
.levelFound
	call Random
	and %0011
	ld b, a
	call Random
	and %0001
	cp 0
	jp z, .subtract	
	ld a, d	
	add b	
	jp .doneApplyingVariance	
.subtract
	ld a, d		
	sub b	
.doneApplyingVariance	
	ld b, a 
	ld a, [wCurOpponent];[wEngagedTrainerClass]
	cp $E5 ; Giovanni
	jp z, .applyPlusFive
	cp $E6 ; ROCKET
	jp z, .applyPlusThree
	cp $E7; Cooltrainer male
	jp z, .applyPlusThree
	cp $E8 ; Cooltrainer female
	jp z, .applyPlusThree
	cp $E9 ; Bruno
	jp z, .applyPlusFive
	cp $EA ; Brock
	jp z, .applyPlusFive
	cp $EB ; Misty
	jp z, .applyPlusFive
	cp $EC ; Lt. Surge
	jp z, .applyPlusFive
	cp $ED ; Erika
	jp z, .applyPlusFive
	cp $EE ; Koga
	jp z, .applyPlusFive
	cp $EF ; Blaine
	jp z, .applyPlusFive
	cp $F0 ; Sabrina
	jp z, .applyPlusFive
	cp $F3 ; Rival Final
	jp z, .applyPlusFive
	cp $F4 ; Lorelei
	jp z, .applyPlusFive
	cp $F6 ; Agatha
	jp z, .applyPlusFive
	cp $F7 ; Lance
	jp z, .applyPlusFive
	ld a, b
	jp .doneApplyingBoost
.applyPlusThree
	ld a, b
	add 3
	jp .doneApplyingBoost
.applyPlusFive	
	ld a, b
	add 5
.doneApplyingBoost	
	ld [wCurEnemyLVL],a
	pop hl
	pop de
	pop bc
	pop af	
	ret
