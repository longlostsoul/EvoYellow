BerryTreeScript::
; Display the "It's a fruit-bearing tree." text
	call EnableAutoTextBoxDrawing
	ld hl, FruitTreeText
	call PrintText
	
; Check to see if the player can get a berry from this tree right now
	ld a, [wWhichTrade] ; Which tree is this?
	dec a
	ld c, a ; We need this in register c
	ld b, 2 ; We want to read this value to see if it's been taken or not
	ld hl, W_BERRYTREEFLAGS
	predef FlagActionPredef
	ld a, c ; Let's get the result of that check
	and a ; Make sure the flag isn't set
	jp nz, .NothingHereScript ; If it is, you got the berry, so the tree is empty
	
; Time to give the berry
	ld a, [wWhichTrade]
	dec a
	ld c, a
	ld b, 0
	ld hl, BerryTable
	add hl, bc
	ld a, [hl]
	ld b, a
	ld c, 1
	call GiveItem
	jr nc, .BagFull
	
; Mark the berry as taken
	ld a, [wWhichTrade] ; Which tree is this?
	dec a
	ld c, a ; We need this in c
	ld b, 1 ; We want to set this tree's bit
	ld hl, W_BERRYTREEFLAGS
	predef FlagActionPredef
	
; Show "Found (Berry Name)!" text
	ld hl, FoundBerryText
	jr .print
	
; Runs if the berry has already been taken from this tree
.NothingHereScript
	ld hl, NoBerryText
	jr .print
	
; Runs when the bag is full
.BagFull
	ld hl, PackFullText
.print
	call PrintText
	ret
	
FruitTreeText:
	text "It's a fruit-"
	line "bearing tree."
	prompt
	db "@"
	
NoBerryText:
	text "Looks like there's"
	line "nothing here."
	done
	db "@"
	
FoundBerryText:
	TX_FAR _FoundItemText
	db $0B
	db "@"
	
PackFullText:
	TX_FAR _NoMoreRoomForItemText
	db "@"
	
	
; The table is not terminated, so don't use invalid tree numbers
BerryTable:
	db ORAN_BERRY;ORAN_BERRY  ; Route 1
	db PARLYZ_HEAL;CHERI  ; Route 2, Tree 1
	db ANTIDOTE;PECHA_BERRY  ; Pewter City, Tree 1
	db AWAKENING;CHESTO_BERRY ; Pewter City, Tree 2
	db PARLYZ_HEAL;CHERI_BERRY  ; route 8
	db SITRUS_BERRY ; route 11
	db ANTIDOTE;PECHA route 5
	db ORAN_BERRY  ; route 4
	db FULL_HEAL;LUM_BERRY    ; route 4
	db ANTIDOTE;PECHA_BERRY  ; route 15
	db PARLYZ_HEAL;ORAN_BERRY  ; route 16
	db ANTIDOTE;PECHA_BERRY  ; Route 2, Tree 2
	db FULL_HEAL;;ORAN_BERRY   ; Viridian Forest
	db SITRUS_BERRY;SITRUS_BERRY ; Route 7
	db SITRUS_BERRY;SITRUS_BERRY   ; none
	db SITRUS_BERRY;SITRUS_BERRY   ; none
	
BerryReset::
; Called to reset berry trees
; Happens when the berry counter hits 0
	ld a, [wBerryStepCounter + 1]
	cp a, $4
	ret nz
	xor a
	ld hl, W_BERRYTREEFLAGS
	ld [hli],a
	ld [hli],a
	ld [hli],a
	ld [hl],a
	;daycare
	ld hl, wDayCareInUse
	bit 0, [hl];anybody there?
	ret z
	set 2,[hl];set baby
	ret
	
;BerryReset:: ;Shorter reset, good for testing.
; Called to reset berry trees
; Happens when the berry counter hits 0
	;xor a
	;ld hl, W_BERRYTREEFLAGS
	;ld [hli],a
	;ld [hl],a
	;ret