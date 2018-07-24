PlayerBerries::
	;######Player Hold Item Script!####
	ld hl, wPartyMon1CatchRate
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes ;now HL should point to our chosen mon's catch rate.
  ld a, [hl];[wBattleMonCatchRate] except doesn't seem to update well
  cp FULL_HEAL;,PARLYZ_HEAL;;cp antidote laters for moar kinds. would need to put elsewhere for sleeping mons as sleepers can't attack unless we add on sleeptalk. ;is it potionz?
  jr nz, .IsItOther
  ld a,[wBattleMonStatus]
  cp 0
  jr z, .NoUseBerry
  ld a,0
  ld [wBattleMonStatus],a
  ;callab PrintHoldItemText
  jr .RidBerry
.IsItOther
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
	callab PrintHoldItemText
  jr .NoUseBerry
.super
  cp SUPER_POTION;is it potionz
  jr nz, .IsItOther2
  ld b,30 
  jr .UseHealBerry
.IsItOther2
  cp POTION;is it potionz?
  jr nz, .NoUseBerry
  ld b,15
.UseHealBerry
	;callab PrintHoldItemText;test
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
.RidBerry
	ld hl, wPartyMon1CatchRate
	ld a, [wPlayerMonNumber]
	ld bc, wPartyMon2 - wPartyMon1
	call AddNTimes ;now HL should point to our chosen mon's catch rate.
  ld a,0 ;could put ether, coin or nugget, if a 'finder' kind of mon like Meowth. bank is currently overfull so I'll do that later.
  ld [hl], a ;replace with diff item after use...use battlemon instead to not work permanently? or just don't repl. with anything!
  ;ld [wBattleMonCatchRate],a 
	callab PrintHoldItemText
.NoUseBerry
  ret

EnemyBerries::
 ;ENEMY HOLD ITEMS
  ld a, [wEnemyMonCatchRate];
  cp 99 ;Enemies with catch rate lower than that should use items.
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
	callab PrintHoldItemText2
  jr .NoUseBerry
.super
  ld b,30 ;enemies are so weak and so rarely use potions, let em have a good healberry
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
  ld a,100
  ld [wEnemyMonCatchRate], a ;replace with diff item after use...doesn't seem to work permanently, but could do check after catching elsewhere and if this specific value turn it into 0. anyway, will make a poke easier to catch by at least 1. >_>
  callab PrintHoldItemText2
.NoUseBerry
  ret