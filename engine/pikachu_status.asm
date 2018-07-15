IsStarterPikachuInOurParty::
;  call IsStarterPikachuInOurParty2
;  jr nc, .checkR
;  ret
;.checkR
 ;call IsStarterRaichuInOurParty
 call IsaPokemonInOurParty ;redundant. at some point I'll clean up the code. >_>
 ret

IsStarterPikachuInOurParty2::
	ld hl, wPartySpecies
	ld de, wPartyMon1OTID
	ld bc, wPartyMonOT
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noPlayerPikachu
	cp PIKACHU + 1
;	jr z, .curMonPlayerPikachu
;	cp RAICHU + 1
	jr nz, .curMonNotPlayerPikachu
.curMonPlayerPikachu
;	ld h, d
;	ld l, e
;	ld a, [wPlayerID]
;	cp [hl]
;	jr nz, .curMonNotPlayerPikachu
;	inc hl
;	ld a, [wPlayerID+1]
;	cp [hl]
;	jr nz, .curMonNotPlayerPikachu
;	push de
;	push bc
;	ld hl, wPlayerName
;	ld d, $6 ; possible player length - 1
;.nameCompareLoop
;	dec d
	jr z, .sameOT
;	ld a, [bc]
;	inc bc
;	cp [hl]
;	inc hl
;	jr z, .nameCompareLoop
;	pop bc
;	pop de

.curMonNotPlayerPikachu
	ld hl, wPartyMon2 - wPartyMon1
	add hl, de
	ld d, h
	ld e, l
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	jr .loop

.sameOT
;	pop bc
;	pop de
;	ld h, d
;	ld l, e
;	ld bc, -NAME_LENGTH
;	add hl, bc
;	ld a, [hli]
;	or [hl]
;	jr z, .noPlayerPikachu ; XXX how is this determined?
	pop hl
	scf
	ret

.noPlayerPikachu
	pop hl
	and a
	ret
	
	
IsaPokemonInOurParty::
	ld hl, wPartySpecies
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noPlayerPoke
;	cp WHATEVERPOKE + 1
;	jr nz, .curMonNotPlayerPikachu
  call FirstPartymonHP
  cp 0
  jr z, .noPlayerPoke
	pop hl
	scf
	ret
.noPlayerPoke
	pop hl
	and a
	ret	
	
WhatPokemonFirst::
IsPikachuFirst::
	ld hl, wPartySpecies
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noPlayerPoke	
	cp PIKACHU + 1
	jr z, .curMonPlayerPikachu
	cp RAICHU + 1
	jr nz, .otherPlayerPoke
.curMonPlayerPikachu
  ld a,25
  pop hl
  ret
.otherPlayerPoke ;use cp against desired poke +1
  pop hl
  ret
.noPlayerPoke
  ld a,0
	pop hl
	ret	


LoadPokeFollowSprite::
  ld hl, wPartySpecies
	push hl
	pop hl
	ld a, [hli]
	push hl
	inc a
	jp z, .noPlayerPoke
	CP PIKACHU +1
	jr nz, .curMonNotThis0
	ld a, SPRITE_PIKACHU
.end
  pop hl
	scf
	ld [wSpriteSet], a
	ret
.noPlayerPoke
	pop hl
	and a
	ret	
.curMonNotThis0
	CP RAICHU +1
	jr nz, .curMonNotThis1
	ld a, SPRITE_RAICHU
	jr .end
.curMonNotThis1
	cp PERSIAN + 1
	jr nz, .curMonNotThis2
	ld a, SPRITE_PERSIAN
	jr .end
.curMonNotThis2
	cp BULBASAUR + 1
	jr nz, .curMonNotThis3b
	ld a, SPRITE_BULBASAUR
	jr .end
.curMonNotThis3b
	cp IVYSAUR + 1
	jr nz, .curMonNotThis3c
	ld a, SPRITE_BULBASAUR
	jr .end
.curMonNotThis3c
	cp VENUSAUR + 1
	jr nz, .curMonNotThis3
	ld a, SPRITE_BULBASAUR
	jr .end
.curMonNotThis3
	cp EEVEE + 1
	jr nz, .curMonNotThis4a
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4a
  cp SYLVEON + 1
	jr nz, .curMonNotThis4b
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4b
	cp UMBREON + 1
	jr nz, .curMonNotThis4c
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4c
	cp ESPEON + 1
	jr nz, .curMonNotThis4d
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4d
	cp FLAREON + 1
	jr nz, .curMonNotThis4e
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4e
	cp GLACEON + 1
	jr nz, .curMonNotThis4f
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4f
	cp JOLTEON + 1
	jr nz, .curMonNotThis4g
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4g
	cp VAPOREON + 1
	jr nz, .curMonNotThisEon
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThisEon
	cp LEAFEON + 1
	jr nz, .curMonNotThis4
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThis4
	cp DITTO + 1
	jr nz, .curMonNotThisDitto
	ld a, SPRITE_DITTO
	jr .end2
.curMonNotThisDitto
	cp SQUIRTLE + 1
	jr nz, .curMonNotThis5a
	ld a, SPRITE_SQUIRTLE
	jr .end2
.curMonNotThis5a
	cp WARTORTLE + 1
	jr nz, .curMonNotThis5b
	ld a, SPRITE_SQUIRTLE
	jr .end2 
.curMonNotThis5b
	cp LAPRAS + 1
	jr nz, .curMonNotThisM
	ld a, SPRITE_LAPRAS
	jr .end2
.curMonNotThisM
	cp GYARADOS + 1
	jr nz, .curMonNotThisFish
	ld a, SPRITE_GYARADOS
	jr .end2 
.curMonNotThisFish
	cp SEEL + 1
	jr nz, .curMonNotThisFishy
	ld a, SPRITE_SEEL
	jr .end2 
.curMonNotThisFishy
	cp DEWGONG + 1
	jr nz, .curMonNotThisFishfood
	ld a, SPRITE_SEEL
	jr .end2 
.curMonNotThisFishfood
	cp SANDSHREW + 1
	jr nz, .curMonNotThisShrew
	ld a, SPRITE_SANDSHREW
	jr .end2;relative value must be 8 bit
.curMonNotThisShrew
	cp SANDSLASH + 1
	jr nz, .curMonNotThisS
	ld a, SPRITE_SANDSHREW
.end2;so, we have multiple different endings here
  pop hl
	scf
	ld [wSpriteSet], a
	ret
.curMonNotThisS
	cp BLASTOISE + 1
	jr nz, .curMonNotThis5
	ld a, SPRITE_SQUIRTLE
	jr .end2
.curMonNotThis5
	cp CHARIZARD + 1
	jr nz, .curMonNotThis6a
	ld a, SPRITE_DRAGON
	jr .end2
.curMonNotThis6a
	cp CHARMELEON + 1
	jr nz, .curMonNotThis6b
	ld a, SPRITE_CHARMANDER
	jr .end2
.curMonNotThis6b
	cp CHARMANDER + 1
	jr nz, .curMonNotThisStarter
	ld a, SPRITE_CHARMANDER
	jr .end2
.curMonNotThisStarter
	cp DRAGONITE + 1
	jr nz, .curMonNotThisG
	ld a, SPRITE_DRAGON
	jr .end2
.curMonNotThisG
	cp ONIX + 1
	jr nz, .curMonNotThisMon
	ld a, SPRITE_SNAKE2
	jr .end2
.curMonNotThisMon
	cp EKANS + 1
	jr nz, .curMonNotThisMon2
	ld a, SPRITE_SNAKE2
	jr .end2
.curMonNotThisMon2
	cp ARBOK + 1
	jr nz, .curMonNotThisMon3
	ld a, SPRITE_SNAKE2
	jr .end2
.curMonNotThisMon3
	cp VOLTORB + 1
	jr nz, .curMonNotThisMon4
	ld a, SPRITE_BALL
	jr .end2
.curMonNotThisMon4
	cp ELECTRODE + 1
	jr nz, .curMonNotThisMon5
	ld a, SPRITE_BALL
	jr .end2
.curMonNotThisMon5
	cp MAGNEMITE + 1
	jr nz, .curMonNotThisMon6
	ld a, SPRITE_BALL
	jr .end2
.curMonNotThisMon6
	cp MAGNETON + 1
	jr nz, .curMonNotThisMon7
	ld a, SPRITE_BALL
	jr .resume
.curMonNotThisMon7
	cp MAGNEZONE + 1
	jr nz, .curMonNotThisMon8
	ld a, SPRITE_BALL
	jr .resume
.curMonNotThisMon8
	cp GLIGAR + 1
	jr nz, .curMonNotThisMon9
	ld a, SPRITE_ZUBAT
	jr .resume
.curMonNotThisMon9
	cp GLISCOR + 1
	jr nz, .curMonNotThisMon10
	ld a, SPRITE_ZUBAT
	jr .resume
.curMonNotThisMon10
	ld a,[wPartyMon1Type1]
 ; callab GetPartyMonSpriteID I didn't have much luck with this, also don't have enough sprites for all of them; they have to have full walksprites.
  ;cp SPRITE_MON              ; $0
	;cp SPRITE_BALL_M           ; $1
	;cp SPRITE_HELIX            ; $2
	cp FAIRY            
	jr nz, .curMonNotThisFairy
	ld a, SPRITE_CLEFAIRY
	jr .resume
.curMonNotThisFairy
	cp WATER           
	jr nz, .curMonNotThisWater
	ld a, SPRITE_FISH
	jr .resume
.curMonNotThisWater
  cp FIRE
	jr nz, .curMonNotThis6
	ld a, SPRITE_DOG
	jr .resume
.curMonNotThis6
	cp BUG              
	jr nz, .curMonNotThisBug
	ld a, SPRITE_BUTTERFREE
	jr .resume
.curMonNotThisBug
	cp GRASS       
	jr nz, .curMonNotThisGrass
	ld a, SPRITE_ODDISH
	jr .resume
.curMonNotThisGrass
;  cp ELECTRIC        
;	jr nz, .curMonNotThisBall
;	ld a, SPRITE_BALL
;	jr .resume
;.curMonNotThisBall
  cp DRAGON       
	jr nz, .curMonNotThisDragony
	ld a, SPRITE_SNAKE2
	jr .resume
.curMonNotThisDragony
  cp ROCK        
	jr nz, .curMonNotThis
	ld a, SPRITE_GEODUDE
	jr .resume
.curMonNotThis
  cp GHOST       
	jr nz, .curMonNotThisGhost
	ld a, SPRITE_GHOST
	jr .resume
.curMonNotThisGhost
  cp POISON       
	jr nz, .curMonNotThisPoison
	ld a, SPRITE_ZUBAT
	jr .resume
.curMonNotThisPoison
  ld a,[wPartyMon1Type2]
	cp FLYING
	jr nz, .curMonNotThisBird
	ld a, SPRITE_BIRD
	jr .resume
.curMonNotThisBird
	cp DARK        
	jr nz, .curMonNotThisredux
	ld a, SPRITE_MEOWTH
	jr .resume
.curMonNotThisredux
  ld a, SPRITE_SLOWBRO
  jr .resume
.resume
	ld [wSpriteSet], a
  pop hl
	scf
	ret

IsStarterRaichuInOurParty::
 ; call IsaPokemonInOurParty ;technically basically got replaced with this func, but can easily put it back if want just two followers again
	ld hl, wPartySpecies
	ld de, wPartyMon1OTID
	ld bc, wPartyMonOT
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noPlayerPikachu
	cp RAICHU + 1
	jr nz, .curMonNotPlayerPikachu
.curMonPlayerPikachu
;	ld h, d
;	ld l, e
;	ld a, [wPlayerID]
;	cp [hl]
;	jr nz, .curMonNotPlayerPikachu
;	inc hl
;	ld a, [wPlayerID+1]
;	cp [hl]
;	jr nz, .curMonNotPlayerPikachu
;	push de
;	push bc
;	ld hl, wPlayerName
;	ld d, $6 ; possible player length - 1
;.nameCompareLoop
;	dec d
	jr z, .sameOT
;	ld a, [bc]
;	inc bc
;	cp [hl]
;	inc hl
;	jr z, .nameCompareLoop
;	pop bc
;	pop de

.curMonNotPlayerPikachu
	ld hl, wPartyMon2 - wPartyMon1
	add hl, de
	ld d, h
	ld e, l
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	jr .loop

.sameOT
;	pop bc
;	pop de
;	ld h, d
;	ld l, e
;	ld bc, -NAME_LENGTH
;	add hl, bc
;	ld a, [hli]
;	or [hl]
;	jr z, .noPlayerPikachu ; XXX how is this determined?
	pop hl
	scf
	ret

.noPlayerPikachu
	pop hl
	and a
	ret


FirstPartymonHappy::
	ld hl, wPartyMon1
	ld bc,wPartyMon1HPExp - wPartyMon1 ;decided to base it off HP exp
	add hl,bc
	ld a,[hl]
	ret

FirstPartymonHP::
  ld hl, wPartyMon1
  ld bc,(wPartyMon1HP + 1) - wPartyMon1 ;check hp
	add hl,bc
	ld a,[hl]
	ret

IsThisPartymonStarterPikachu_Box::
	ld hl, wBoxMon1
	ld bc, wBoxMon2 - wBoxMon1
	ld de, wBoxMonOT
	jr asm_fce21

IsThisPartymonStarterPikachu_Party::
IsThisPartymonStarterPikachu::
	ld hl, wPartyMon1
	ld bc, wPartyMon2 - wPartyMon1
	ld de, wPartyMonOT
asm_fce21:
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [hl]
	cp RAICHU
  ;cp PERSIAN
	jr nz, .isPika
	jr .yes
.isPika
	cp PIKACHU
  ;cp MEOWTH
	jr nz, .notPlayerPikachu
.yes
	ld bc, wPartyMon1OTID - wPartyMon1
	add hl, bc
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .notPlayerPikachu
	inc hl
	ld a, [wPlayerID+1]
	cp [hl]
	jr nz, .notPlayerPikachu
	ld h, d
	ld l, e
	ld a, [wWhichPokemon]
	ld bc, NAME_LENGTH
	call AddNTimes
	ld de, wPlayerName
	ld b, $6
.loop
	dec b
	jr z, .isPlayerPikachu
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr z, .loop
.notPlayerPikachu
	and a
	ret

.isPlayerPikachu
	scf
	ret

UpdatePikachuMoodAfterBattle::
; because d is always $82 at this function, it serves to
; ensure Pikachu's mood is at least 130 after battle
	push de
	call IsStarterPikachuInOurParty
	pop de
	ret nc
	ld a, d
	cp 128
	ld a, [wPikachuMood]
	jr c, .d_less_than_128 ; we never jump
	cp d
	jr c, .load_d_into_mood
	ret

.d_less_than_128
	cp d
	ret c
.load_d_into_mood
	ld a, d
	ld [wPikachuMood], a
	ret

CheckPikachuFaintedOrStatused::
; function to test if Pikachu is alive?
	xor a
	ld [wWhichPokemon], a
	ld hl, wPartyCount
.loop
	inc hl
	ld a, [hl]
	cp $ff
	jr z, .dead_or_not_in_party
	push hl
	call IsThisPartymonStarterPikachu_Party
	pop hl
	jr nc, .next
	ld a, [wWhichPokemon]
	ld hl, wPartyMon1HP
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes
	ld a, [hli]
	or [hl]
	ld d, a
	inc hl
	inc hl
	ld a, [hl] ; status
	and a
	jr nz, .alive
	jr .dead_or_not_in_party

.next
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	jr .loop

.alive
	scf
	ret

.dead_or_not_in_party
	and a
	ret

IsSurfingPikachuInThePlayersParty::
	ld hl, wPartySpecies
	ld de, wPartyMon1Moves
	ld bc, wPartyMonOT
	push hl
.loop
	pop hl
	ld a, [hli]
	push hl
	inc a
	jr z, .noSurfingPlayerPikachu
	cp RAICHU+1
	jr nz, .isitsurfpika
	jr .yes
.isitsurfpika
	cp PIKACHU+1
	jr nz, .curMonNotSurfingPlayerPikachu
.yes
	ld h, d
	ld l, e
	push hl
	push bc
	ld b, NUM_MOVES
.moveSearchLoop
	ld a, [hli]
	cp SURF
	jr z, .foundSurfingPikachu
	dec b
	jr nz, .moveSearchLoop
	pop bc
	pop hl
	jr .curMonNotSurfingPlayerPikachu

.foundSurfingPikachu
	pop bc
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, [wPlayerID]
	cp [hl]
	jr nz, .curMonNotSurfingPlayerPikachu
	inc hl
	ld a, [wPlayerID+1]
	cp [hl]
	jr nz, .curMonNotSurfingPlayerPikachu
	push de
	push bc
	ld hl, wPlayerName
	ld d, $6
.nameCompareLoop
	dec d
	jr z, .foundSurfingPlayerPikachu
	ld a, [bc]
	inc bc
	cp [hl]
	inc hl
	jr z, .nameCompareLoop
	pop bc
	pop de
.curMonNotSurfingPlayerPikachu
	ld hl, wPartyMon2 - wPartyMon1
	add hl, de
	ld d, h
	ld e, l
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	jr .loop

.foundSurfingPlayerPikachu
	pop bc
	pop de
	pop hl
	scf
	ret

.noSurfingPlayerPikachu
	pop hl
	and a
	ret
