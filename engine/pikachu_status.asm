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


Pointer_PikaSprites:
db PIKACHU
db MARILL
db AZUMARILL
db $FF

Pointer_SeelSprites:
db SEEL
db DEWGONG

db $FF

Pointer_ShellSprites:
db OMASTAR
db OMANYTE
db SHELLDER
db KABUTOPS
db OCTILLERY
db CLOYSTER
db KABUTO
db $FF

Pointer_SquirtSprites
db SQUIRTLE
db WARTORTLE
db BLASTOISE
db WOOPER
db QUAGSIRE
db POLIWAG
db POLIWHIRL
db POLIWRATH
db POLITOED
db $FF

Pointer_FishSprites:
db MAGIKARP
db GOLDEEN
db SEAKING
db QWILFISH
db CHINCHOU
db LANTURN
db $FF

Pointer_MeowthSprites:
db MEOWTH
db SNEASEL
db WEAVILE
db $FF

Pointer_QuadSprites:
db RATTATA
db RATICATE
db TAUROS
db MILTANK
db GIRAFARIG
db PONYTA
db RAPIDASH
db RHYHORN
db $FF

Pointer_SnakeSprites:
db ONIX
db STEELIX
db EKANS
db ARBOK
db SALANDIT
db SALAZZLE
;db DRATINI ;might handle by dragon typing check instead
;db DRAGONAIR
;db DUNSPARCE
db $FF

Pointer_BatSprites:
db ZUBAT
db GOLBAT
db GLISCOR
db GLIGAR
db $FF

Pointer_DogSprites:
db HOUNDOUR
db GROWLITHE
db SUICUNE
db ENTEI
db HOUNDOOM
db RAIKOU
db ARCANINE
db FLAREON
db ABSOL
db $FF

Pointer_BallSprites:
db VOLTORB
db ELECTRODE
db MAGNEMITE
db MAGNETON
db MAGNEZONE
db KOFFING
db WEEZING
db $FF

Pointer_DittoSprites:
db DITTO
db MUK
db GRIMER
db $FF

Pointer_EeveeSprites:
db EEVEE
db ESPEON
;db FLAREON
db UMBREON
db VAPOREON
db JOLTEON
db LEAFEON
db SYLVEON
db GLACEON
db $FF

Pointer_CharmanderSprites:
db CHARMANDER
db CHARMELEON
db $FF

Pointer_DragonSprites
db CHARIZARD
db DRAGONITE
db AERODACTYL
db $FF

Pointer_BulbaSprites:
db BULBASAUR
db IVYSAUR
db VENUSAUR
db $FF

;Other grass mons all get single grass sprite, so get grass typing check instead.

GetFirstMonSpecies:
	ld hl, wPartySpecies
	;add hl, bc ;why did I add zero originally?
	ld a, [hl]
	ret
	
GetFirstMoninWhich:
	ld a, 0
	ld [wWhichPokemon],a
	;call GetPartyMonName2 uses this I think? could also use wWhichTrade
	ret

LoadPokeFollowSprite::
  ld hl, wPartySpecies
	push hl
	pop hl
	ld a, [hli]
	push hl
	inc a
	jp z, .noPlayerPoke
;	CP PIKACHU +1
;	jr nz, .curMonNotThis0
;	ld a, SPRITE_PIKACHU
  call GetFirstMonSpecies ;point to species properly for loop, no +1 --
	ld hl, Pointer_ShellSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThis0
	ld a, SPRITE_SHELL
	jr .end
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
  call GetFirstMonSpecies
  ld hl, Pointer_PikaSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisPika
	ld a, SPRITE_PIKACHU
	jr .end
.curMonNotThisPika
  call GetFirstMonSpecies
	CP RAICHU
	jr nz, .curMonNotThis1
	ld a, SPRITE_RAICHU
	jr .end
.curMonNotThis1
	cp PERSIAN
	jr nz, .curMonNotThis2
	ld a, SPRITE_PERSIAN
	jr .end
.curMonNotThis2
  call GetFirstMonSpecies
  ld hl, Pointer_BulbaSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThis3
	ld a, SPRITE_BULBASAUR
	jr .end
.curMonNotThis3
  call GetFirstMonSpecies
	ld hl, Pointer_EeveeSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisEon
	ld a, SPRITE_EEVEE
	jr .end
.curMonNotThisEon
  call GetFirstMonSpecies
	ld hl, Pointer_DittoSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisDitto
	ld a, SPRITE_DITTO
	jr .end
.curMonNotThisDitto
  call GetFirstMonSpecies
	ld hl, Pointer_SquirtSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThis5a
	ld a, SPRITE_SQUIRTLE
	jr .end
.curMonNotThis5a
  call GetFirstMonSpecies
	cp LAPRAS
	jr nz, .curMonNotThisM
	ld a, SPRITE_LAPRAS
	jr .end2
.curMonNotThisM
	cp GYARADOS
	jr nz, .curMonNotThisFish
	ld a, SPRITE_GYARADOS
	jr .end2
.curMonNotThisFish
  call GetFirstMonSpecies
	ld hl, Pointer_QuadSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotTauroslike
	ld a, SPRITE_TAUROS
	jr .end2
.curMonNotTauroslike
  call GetFirstMonSpecies
	ld hl, Pointer_SeelSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisFishfood
	ld a, SPRITE_SEEL
	;jr .end2;relative value must be 8 bit
.end2;so, we have multiple different endings here
  pop hl
	scf
	ld [wSpriteSet], a
	ret
.curMonNotThisFishfood
  call GetFirstMonSpecies
	ld hl, Pointer_CharmanderSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisStarter
	ld a, SPRITE_CHARMANDER
	jr .end2
.curMonNotThisStarter
  call GetFirstMonSpecies
	ld hl, Pointer_DragonSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisGuy
	ld a, SPRITE_DRAGON
	jr .end2
.curMonNotThisGuy
	call GetFirstMonSpecies
	ld hl, Pointer_SnakeSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisMon
	ld a, SPRITE_SNAKE2
	jr .resume2
.curMonNotThisMon
	call GetFirstMonSpecies
	ld hl, Pointer_BallSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisMonBall
	ld a, SPRITE_BALL
	jr .resume2
.curMonNotThisMonBall
	call GetFirstMonSpecies
	ld hl, Pointer_BatSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThisZub
	ld a, SPRITE_ZUBAT
	jr .resume2
.curMonNotThisZub
  call GetFirstMonSpecies
	ld hl, Pointer_DogSprites
	ld de, $1
	call IsInArray
	jr nc, .curMonNotThis6
	ld a, SPRITE_DOG
	jr .resume
.curMonNotThis6
  call GetFirstMonSpecies
	ld hl, Pointer_MeowthSprites
	ld de, $1
	call IsInArray
	jr nc,  .curMonNotThis_types
	ld a, SPRITE_MEOWTH
	;jr .resume2
;.curMonNotThissneeze
.resume2;so, we have multiple different endings here
  pop hl
	scf
	ld [wSpriteSet], a
	ret
.curMonNotThis_types
	ld a,[wPartyMon1Type1]
 ; callab GetPartyMonSpriteID I didn't have much luck with this. I might try it again though, this current set up is still a bit inefficient, although since requires full walksprites I'd still have to go through each sprite type and load a new sprite.
 ;In hindsight, I think one reason it may not have worked could be bank switching, since I noticed putting the pointers to the lists in this bank made them work much better. For now, since have to change sprites anyway, this works.
 ;ld b, Bank(pointers)	ld hl, pointers	ld input? call Bankswitch
  ;cp SPRITE_MON              ; $0
	;cp SPRITE_BALL_M           ; $1
	;cp SPRITE_HELIX            ; $2
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
  cp GROUND       
	jr nz, .curMonNotThisPoison
	ld a, SPRITE_SANDSHREW
	jr .resume
.curMonNotThisPoison
  ld a,[wPartyMon1Type2]
	cp FLYING
	jr nz, .curMonNotThisBird
	ld a, SPRITE_BIRD
	jr .resume
.curMonNotThisBird
  cp FAIRY            
	jr nz, .curMonNotThisFairy
	ld a, SPRITE_CLEFAIRY
	jr .resume
.curMonNotThisFairy
	cp PSYCHIC     
	jr nz, .curMonNotThisredux
	ld a, SPRITE_MEW
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


FirstPartymonHappy:: ;checks against stat exp of a few stats and uses highest
	ld hl, wPartyMon1
	ld bc,wPartyMon1HPExp - wPartyMon1 ;decided to base it off HP exp
	add hl,bc
	ld a,[hl]
	ld [wFlag],a ;loaded hp into wflag
	
	ld hl, wPartyMon1
	ld bc,wPartyMon1AttackExp - wPartyMon1 ;alt happy stat
	add hl,bc
	ld a,[hl]
	ld b,a ;new stat into b
	ld a,[wFlag];loaded hp into a
	cp b
	jr nc, .bigger ;hp is bigger
	ld a,b
	ld [wFlag],a;new stat into wFlag
.bigger
	ld hl, wPartyMon1
	ld bc,wPartyMon1SpeedExp - wPartyMon1 ;compare to this now.
	add hl,bc
	ld a,[hl]
	ld b,a ;hl into b
	ld a,[wFlag];loaded hp or att into a
	cp b
	jr nc, .biggerthanb
	ld a,b
	ld [wFlag],a;att into wFlag, if it is higher, then it is the happy stat.
	
.biggerthanb
  ld a,[wFlag]
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
