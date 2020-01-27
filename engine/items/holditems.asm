	;######Player Hold Item Script!####

LoadPokeItem::
	ld hl, wPartyMon1CatchRate
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes ;now HL should point to our chosen mon's catch rate.
  ld a, [hl];[wBattleMonCatchRate] except that doesn't seem to update well, so we use this instead
  ret
  
MegaForms::
  call LoadPokeItem
  cp MOON_STONE
  jr z, .Darkify
  cp LOVE_STONE
  jr z, .Fairy
  cp FROST_STONE
  jr z, .Ice
  cp FIRE_STONE
  jr z, .Fireify
  cp THUNDER_STONE
  jr z, .Thunderit
  jp .sun
.Darkify
 ld a, DARK
 ld [wBattleMonType2],a
 ld a, DARK_PULSE
 ld [wBattleMonMoves],a
 ld a, [wBattleMonSpecies]
 cp GYARADOS
 jr z, .Mega2
 cp GENGAR
 jr z, .Mega2
 cp PERSIAN
 jr nz, .ret1
 ld a, STEEL
 ld [wBattleMonType],a
 jp .ret1
.Fairy
 ld a, [wBattleMonSpecies]
 cp RAICHU
 jr z, .Psychicify
 ld a, FAIRY
 ld [wBattleMonType],a
 ld a, [wBattleMonSpecies]
 cp RAPIDASH
 jr nz, .ret1
.Psychicify
 ld a, PSYCHIC
 ld [wBattleMonType2],a
 ld [wBattleMonMoves],a
.ret1
 callab PrintHoldItemText
 ret
.Ice
 ld a, ICE
 ld [wBattleMonType],a
 ld a, ICE_BEAM
 ld [wBattleMonMoves],a
 ld a, [wBattleMonSpecies]
 cp NINETALES
 jr nz, .iceshrew
 ld a, FAIRY
 ld [wBattleMonType2],a
.iceshrew
 cp SANDSLASH
 jr nz, .noStone
 ld a, STEEL
 ld [wBattleMonType2],a
 jp .print
.Thunderit
 ld a, ELECTRIC
 ld [wBattleMonType],a
 ld a, THUNDERBOLT
 ld [wBattleMonMoves],a
 jp .print
.Fireify
 ld a, FLAMETHROWER
 ld [wBattleMonMoves],a
 ld a, FIRE
 ld [wBattleMonType],a
 ld a, [wBattleMonSpecies]
 cp MAROWAK
 jr nz, .noStone
 ld a, GHOST
 ld [wBattleMonType2],a
 jp .print
.Mega2
	;ld a, MEGA_BLASTOISE ;mega form or other form pic change. Seems to work well.
	;ld de, wBattleMonSpecies ;put after copy data in LoadBattleMonFromParty
	;	ld [de], a
	call Megastats
	jp .print
.sun
  cp SUN_STONE
  jr nz, .noStone
  ld a, [wBattleMonSpecies]
  cp AMPHAROS
  jr z, .Mega
  cp AERODACTYL
  jr z, .Mega
  cp PINSIR ;probably could make this more efficient with a table.
  jr z, .Mega
  cp BEEDRILL
  jr z, .Mega
  cp VENUSAUR
  jr z, .Mega2
  cp BLASTOISE
  jr z, .Mega2
  cp CHARIZARD
  jr nz, .noCharm
.Mega
	;ld a, MEGA_CHARIZARD ;mega form or other form pic change. Seems to work well.
	;ld de, wBattleMonSpecies ;put after copy data in LoadBattleMonFromParty
	;ld [de], a
	call Megastats
.noCharm
	ld a, DRACO_METEOR
	ld [wBattleMonMoves],a
	ld a, DRAGON
	ld [wBattleMonType2],a
.print
  callab PrintHoldItemText
.noStone
  ret
  
Megastats::
	ld a, [wBattleMonAttack + 1]
	ld b, 50
	add b
	ld [wBattleMonAttack + 1], a
 ret
  
;MonSpeciesOverride::
 ;call LoadEnemyItem
 ;cp ITEM
 ;jr nz, .nostone
   ;Do stuff
  ;ld a, [wWhichPokemon] 
	;ld bc, wPartyMon2 - wPartyMon1
	;ld hl, wPartyMon1Species; for full over-ride, will act like is the poke on level up which may not be desirable, put after LoadBattleMonFromParty in core
	;call AddNTimes
	;ld a, MEWTWO
	; ld [hl],a ;could over-ride the taking PartyMon as input.
	;jp .don
 ;.nostone
   ;ld a, [wWhichPokemon]
	;ld bc, wPartyMon2 - wPartyMon1
	;ld hl, wPartyMon1Species
	;call AddNTimes
;.don
 ;ret
  
  
PlayerBerries::
  ;callab PrintHoldItemText
  call LoadPokeItem
  cp FULL_HEAL
  ;is it potionz?
  jr nz, .IsItOther
  ld a,[wBattleMonStatus]
  cp 0
  jr nz, .ret
.cleanstatus
  ld a,0
  ld [wBattleMonStatus],a
  callab PrintCUREBerryText
  call RidBerry
.ret
  ret
.IsItOther
  call LoadPokeItem
  cp ANTIDOTE
  ;is it antidote?
  jr nz, .IsItBurn
  ld hl,wBattleMonStatus
	bit PSN,[hl]
  jr nz, .cleanstatus
  ret
.IsItBurn
  cp BURN_HEAL
  ;is it antidote?
  jr nz, .IsItPara
  ld a,[wBattleMonStatus]
  ld hl,wBattleMonStatus
	bit BRN,[hl]
  jr nz, .cleanstatus
  ret
.IsItPara
  cp PARLYZ_HEAL
  ;is it paralyzed?
  jr nz, .isitHeal
  ld [wTemp],a
  ld hl,wBattleMonStatus
	bit PAR,[hl]
  jr z,.ret
  ld a,0
  ld [wBattleMonStatus],a
  callab PrintCUREBerryText
  call RidBerry
	ld a,99
  ret
.isitHeal
  cp MAX_POTION ;leftovers
  jr nz, .super
  ld a,[wBattleMonHP + 1]
  ld b, 2
  add b
  ld b,a
  ld a,[wBattleMonMaxHP+1]
  cp b
  jr c, .MaxLeftovers
  ld a,b
.MaxLeftovers
  ld [wBattleMonHP + 1], a
	callab PrintLeftovers
  jr .NoUseBerry
.super
  cp SITRUS_BERRY;is it berry?
  jr nz, .IsItOther2
  ld b,35 
  jr .UseHealBerry
.IsItOther2
  cp ORAN_BERRY;is it berry?
  jr nz, .IsItPot
  ld b,15
  jr .UseHealBerry
.IsItPot
  cp POTION;is it salve? Having Potion be a holdable is useful for giving wilds higher catchrates, since shares spot with wild's item.
  jr nz, .NoUseBerry
  ld b,30
.UseHealBerry
	callab PrintHealBerryText;test
  ld a, [wBattleMonHP + 1]
  ld b, a
  ld a,[wBattleMonMaxHP +1]
  cp b
  jr z, .NoUseBerry ;If battlemon hp = Maxhp, don't use.
  ld a, [wBattleMonHP + 1]
	cp 30;less than this health, use a held item.
  jr nc, .NoUseBerry ;if bigger than above, don't use
  ld a,[wBattleMonHP + 1]
  ;ld b, 10
  add b
  ld b,a 
  ld a,[wBattleMonMaxHP +1]
  cp b
  jr nc, .ContUseItem ;if maxhp bigger than b, continue
	ld a,[wBattleMonMaxHP +1] ; full restore
	ld b,a
.ContUseItem
  ld a, b
	ld [wBattleMonHP + 1],a
	;ld [wHPBarNewHP],a
;.RidBerry
	call RidBerry
.NoUseBerry
  ret
  
FRZorSLPBerry::
  call LoadPokeItem
  cp AWAKENING
  ;is it asleep. call PlayerBerries in CheckPlayerStatusConditions.
  jr nz, .IsItFreeze
  ld [wTemp],a;override wTemp in case something else did.
  ld hl,wBattleMonStatus
	ld a,[hl]
	and a,SLP
  jr z, .ret
;.WakeUp
	call RidBerry
	callab PrintSleepBerryText
	ld a,100
	ld [wTemp],a ;do it again to our 'wake up' msg, handled in core.
  ret
.IsItFreeze
  cp ICE_HEAL
  jr nz, .ret
  ld [wTemp],a
  ld hl,wBattleMonStatus
	bit FRZ,[hl] ; frozen?
  jr z, .ret
  callab PrintCUREBerryText
	call RidBerry
	ld a,101
	ld [wTemp],a
.ret
	ret  

RidBerry::
  ld hl, wPartyMon1CatchRate
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes ;now HL should point to our chosen mon's catch rate.
  ld a,0 ;could put ether, coin or nugget, if a 'finder' kind of mon like Meowth. bank is currently overfull so I'll do that later.
  ld [hl], a ;replace with diff item after use...use battlemon instead to not work permanently? or just don't repl. with anything!
  ;ld [wBattleMonCatchRate],a 
	ret

EnemyBerries::
 ;ENEMY HOLD ITEMS
  ld a, [wEnemyMonCatchRate];
  cp MAX_HOLD ;Enemies with catch rate lower than that should use items.
  jr nc, .NoUseBerry
  ;callab PrintHoldItemText2 ;debug to check is holding item indeed
  cp FULL_HEAL ;is it potionz?
  jr nz, .IsItOther
  ld a,[wEnemyMonStatus]
  cp 0
  jr z, .NoUseBerry
  ld a,0
  ld [wEnemyMonStatus],a
  callab PrintHoldItemText2
  jr .NoUseBerry
.IsItOther
  cp MAX_POTION ;leftovers
  jr nz, .super
  ld a,[wEnemyMonHP + 1]
  ld b, 2
  add b
  ld b,a
  ld a,[wEnemyMonMaxHP+1]
  cp b
  jr c, .MaxLeftovers
  ld a,b
.MaxLeftovers
  ld [wEnemyMonHP + 1], a
	callab PrintLeftovers;PrintHoldItemText2
  jr .NoUseBerry
.super
  ld a, [wEnemyMonHP + 1]
  ld b, a
  ld a,[wEnemyMonMaxHP +1]
  cp b
  jr z, .NoUseBerry ;If battlemon hp = Maxhp, don't use.
  ld a, [wEnemyMonHP + 1]
  ld b,30 ;enemies are so weak and so rarely use potions, let em always have a good healberry
  ld a, [wEnemyMonHP+1]
 ; cp 0
 ; jr z, .NoUseBerry
	cp 50;less than this health, use a held item.
  jr nc, .NoUseBerry ;if bigger than, don't use
  add b
  ld b,a 
  ld a,[wEnemyMonMaxHP+1]
  cp b
  ld a, b
  jr nc, .ContUseItem ;if maxhp bigger than hp+30, continue
	ld a,[wEnemyMonMaxHP+1] ; full restore instead
.ContUseItem
	ld [wEnemyMonHP+1],a
  ld a,MAX_HOLD
  ld [wEnemyMonCatchRate], a ;replace with diff item after use...doesn't seem to work permanently, but could do check after catching elsewhere and if this specific value turn it into 0. anyway, will make a poke easier to catch by at least 1. >_>
  callab PrintHoldItemText2
.NoUseBerry
  ret