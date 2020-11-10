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
	ld [wPrinterHandshake],a
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
  ld a, [wPrinterHandshake] ;temp flag I guess
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
