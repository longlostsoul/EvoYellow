ReflectLightScreenEffect_:
	ld hl, wPlayerBattleStatus3
	ld de, wPlayerMoveEffect
	ld a, [H_WHOSETURN]
	and a
	jr z, .reflectLightScreenEffect
	ld hl, wEnemyBattleStatus3
	ld de, wEnemyMoveEffect
.reflectLightScreenEffect
	ld a, [de]
	cp SPIKES_EFFECT
	jr nz, .light
	set SpikesStatusUp, [hl]
	ld a,[H_WHOSETURN]
	and a
	jr z, .player
	ld a,1
	ld [wSurfingMinigameTrickFlags],a
	jr .spikes
.player
  ld a,1
	ld [wPrinterStatusFlags],a;temp flag I guess
.spikes
	ld hl, SpikesText
	jr .playAnim
.light
	cp LIGHT_SCREEN_EFFECT
	jr nz, .reflect
	bit HasLightScreenUp, [hl] ; is mon already protected by light screen?
	jr nz, .moveFailed
	set HasLightScreenUp, [hl] ; mon is now protected by light screen
	ld hl, LightScreenProtectedText
	jr .playAnim
.reflect
	bit HasReflectUp, [hl] ; is mon already protected by reflect?
	jr nz, .moveFailed
	set HasReflectUp, [hl] ; mon is now protected by reflect
	ld hl, ReflectGainedArmorText
.playAnim
	push hl
	ld hl, PlayCurrentMoveAnimation
	call Bankswitch3DtoF
	pop hl
	jp PrintText
.moveFailed
	ld c, 50
	call DelayFrames
	ld hl, PrintButItFailedText_
	jp Bankswitch3DtoF

DoEnemySpikes::
; ld hl, wEnemyBattleStatus3
; bit SpikesStatusUp, [hl] ; check for Spikes from the enemy to hurt you. couldn't get it to work properly this way ehh.
 ;jr nz, .no
  ld a, [wSurfingMinigameTrickFlags] ;temp flag I guess
	cp 1
	jr nz, .no
; res SpikesStatusUp, [hl]
 ld a, 25
 ld b,a
 ld a,[wBattleMonHP + 1]
 sub b
 ld [wBattleMonHP + 1],a
 ld [wHPBarNewHP],a
 ld hl, SpikesText
 jp PrintText
.no

 ret

DoSpikes:: ;hurts enemy, or should
 ;ld hl, wPlayerBattleStatus3
 ;bit SpikesStatusUp, [hl] ; check for Spikes
 ;jr z, .check1
 ld a, [wPrinterStatusFlags];crappy temp flag.
 cp 1
 jr nz, .no
;.check1
 ;ld a, 0
 ;ld [wPrinterStatusFlags],a ;0ing out if we want
 
 
; ld a, [H_WHOSETURN]
;	and a
;	jr z, .Player
;	jp .no
	;enemy did the switch and not the player, hopefully?
	
;	ld a, 15
; ld b, a
; ld a, [wEnemyMonHP + 1]
; sub b
; ld [wEnemyMonHP + 1],a
 ld hl, SpikesText
 call PrintText
 callba selfdamage ;hm, would need to mirror this above for link battles.
 jp .no
.no 
 ret
 
 ;####WEATHER~! Rain Dance, Sunny Day
 
GetWeather::

	ld de, wPlayerSelectedMove
	ld a, [H_WHOSETURN]
	and a
	jr z, .SunnyorRain
	ld de, wEnemySelectedMove
.SunnyorRain
  ld a, [de]
	cp SPLASH
	jr nz, .light

  ld a,7;it starts raining yay.
	ld [wUnusedD366],a;just some flag I repurposed.
	ret
.light
	ld a,3
	ld [wUnusedD366],a
	;do another one for sunny day.
	ret
	
;DoWeather:: ;accuracy over-ride not actually present/correctly working yet.
; ld a,[wUnusedD366] 
; cp 0
; jr nz, .cont
; ret
;.cont
; ld a,[wMoveType]
; cp ELECTRIC
; ret


WeatherBonus::
 ld a,[wUnusedD366]
 cp 0
 jr z,.ret
 cp 4
 jr c, .sun
 ld a,[wMoveType]
 cp WATER
 jr z, .cont
 cp ELECTRIC
 jr z, .cont
 cp FLYING
 jr z, .cont
.sun
 ld a,[wMoveType]
 cp FIRE
 jr z, .cont
 cp GRASS
 jr z, .cont
.cont
 ;bonus dmg
 	ld hl,wDamage + 1
	ld a,[hld]
	ld h,[hl]
	ld l,a    ; hl = damage
	ld b,h
	ld c,l    ; bc = damage
	srl b
	rr c      ; bc = floor(0.5 * damage)
	add hl,bc ; hl = floor(1.5 * damage)
; store damage
	ld a,h
	ld [wDamage],a
	ld a,l
	ld [wDamage + 1],a
	ld hl,wDamageMultipliers
	set 7,[hl]
.ret 
 ret

SubWeather:: ;last three turns?
 ld a,1
 ld b,a
 ld a,[wUnusedD366] ;rainy
 cp 4
 jr c, .check ;if it is bigger than this, it's rainy. smaller is sunny.
 sub b
 ld [wUnusedD366],a
 cp 4
 jr nz, .rain ;if it is 4, 0 it out
 ld a,0
 ld [wUnusedD366],a
 jr .rain
.check
 ld a, [wUnusedD366];sunny?
 cp 0
 jr z, .end
 sub b ;subtract b from a
 ld [wUnusedD366],a
 ld hl, SunnyText
 jp PrintText
.rain
 ld hl, WeatherRages
 jp PrintText
.end
 ret

WeatherRages:
 TX_FAR _RainingText
 db "@"

SunnyText
 TX_FAR _SunnyText
 db "@"

SpikesText:
	TX_FAR _SpikesText
	db "@"
	
LightScreenProtectedText:
	TX_FAR _LightScreenProtectedText
	db "@"

ReflectGainedArmorText:
	TX_FAR _ReflectGainedArmorText
	db "@"

Bankswitch3DtoF:
	ld b, BANK(BattleCore)
	jp Bankswitch
