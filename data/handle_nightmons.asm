HandleNightMons:
	; replace the 1, 4, and 7 grassmon slots
	ld hl, NightWildMonPointers
	ld a,[wCurMap]
	; get wild data for current map
	ld c,a
	ld b,0
	add hl,bc
	add hl,bc
	ld a,[hli]
	ld h,[hl]
	ld l,a       ; hl now points to wild data for current map
	ld a, [hli]
	cp $ff
	ret z
	ld [wGrassMons], a
	ld a, [hli]
	ld [wGrassMons+1], a
	ld a, [hli]
	ld [wGrassMons+6], a
	ld a, [hli]
	ld [wGrassMons+7], a
	ld a, [hli]
	ld [wGrassMons+12], a
	ld a, [hli]
	ld [wGrassMons+13], a
	ret

NightWildMonPointers:
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw Route1NightMons  ; ROUTE_1
	dw Route2NightMons  ; ROUTE_2
	dw Route3NightMons  ; ROUTE_3
	dw Route4NightMons  ; ROUTE_4
	dw Route5NightMons  ; ROUTE_5
	dw Route6NightMons  ; ROUTE_6
	dw Route7NightMons  ; ROUTE_7
	dw Route8NightMons  ; ROUTE_8
	dw Route9NightMons  ; ROUTE_9
	dw Route10NightMons ; ROUTE_10
	dw Route11NightMons ; ROUTE_11
	dw Route12NightMons ; ROUTE_12
	dw Route13NightMons ; ROUTE_13
	dw Route14NightMons ; ROUTE_14
	dw Route15NightMons ; ROUTE_15
	dw Route16NightMons ; ROUTE_16
	dw Route17NightMons ; ROUTE_17
	dw Route17NightMons ; ROUTE_18 ;duplicate
	dw NoNightMons ; ROUTE_19
	dw NoNightMons ; ROUTE_20
	dw Route21NightMons ; ROUTE_21
	dw Route22NightMons ; ROUTE_22
	dw Route23NightMons ; ROUTE_23
	dw Route24NightMons ; ROUTE_24
	dw Route25NightMons ; ROUTE_25
	dw NoNightMons      ; REDS_HOUSE_1F
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw ForestNightMons ; ViridianForest
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw MtMoonNightMons ; Mt.Moon1
	dw MtMoonNightMons ; Mt.Moon2
	dw MtMoonNightMons ; Mt.Moon3
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ; Rock Tunnel 1
	dw NoNightMons ; Power Plant
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ; Victory Road
	dw NoNightMons
	dw NoNightMons;Route2NightMons
	dw NoNightMons;Route10NightMons
	dw NoNightMons;Route12NightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ;Pokemon Tower Lavender 
	dw NoNightMons ;Pokemon Tower Lavender 
	dw Route8NightMons ;Pokemon Tower Lavender 
	dw Route8NightMons ;Pokemon Tower Lavender 
	dw Route8NightMons ;Pokemon Tower Lavender 
	dw Route8NightMons ;Pokemon Tower Lavender 
	dw Route8NightMons ;Pokemon Tower Lavender 
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ;Seafoam Island1
	dw NoNightMons ;Seafoam Island2
	dw NoNightMons ;Seafoam Island3
	dw NoNightMons ;Seafoam Island4
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ;Pokemn Mansion Cinnabar
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw HighLevelNightMons ;Seafoam Island
	dw NoNightMons
	dw HighLevelNightMons ; Victory Road
	dw NoNightMons
	dw NoNightMons
	dw DiglettNightMons ; Diglett Cave
	dw HighLevelNightMons ; Victory Road
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ;Pokemn Mansion Cinnabar
	dw NoNightMons ;Pokemn Mansion Cinnabar
	dw NoNightMons ;Pokemn Mansion Cinnabar
	dw NoNightMons ;Safari Zone
	dw NoNightMons ;Safari Zone
	dw NoNightMons ;Safari Zone
	dw NoNightMons ;Safari Zone
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw HighLevelNightMons ;Cerulean Cave
	dw HighLevelNightMons2 ;Cerulean Cave
	dw HighLevelNightMons3 ;Cerulean Cave
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons ; Rock tunnel 2
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons
	dw NoNightMons

NoNightMons:
	db $ff
	
ForestNightMons:
	db 4, HOOTHOOT
	db 5, PIKACHU
	db 5, SPINARAK

DiglettNightMons:
	db 20, ZUBAT
	db 20, KOFFING
	db 15, LARVITAR

MtMoonNightMons:
	db 9, ZUBAT
	db 10, PARAS
	db 12, CLEFAIRY

Route1NightMons:
	db 3, HOOTHOOT
	db 3, HOOTHOOT
	db 5, RATTATA

Route2NightMons:
	db 3, RATTATA
	db 4, ZUBAT
	db 6, HOOTHOOT

Route3NightMons:
	db 9, SMEARGLE
	db 10, GLIGAR
	db 12, CLEFAIRY

Route4NightMons:
	db 10, ZUBAT
	db 12, PARAS
	db 9, EKANS

Route5NightMons:
	db 15, MEOWTH
	db 14, ODDISH
	db 16, NOCTOWL

Route6NightMons:
	db 14, DROWZEE
	db 16, MEOWTH
	db 18, GOLDUCK

Route7NightMons:
	db 20, NOCTOWL
	db 15, MURKROW
	db 19, HOUNDOUR

Route8NightMons:
	db 15, GASTLY
	db 18, HAUNTER
	db 20, NOCTOWL

Route9NightMons:
	db 16, HOOTHOOT
	db 18, VENOMOTH
	db 20, RATICATE

Route10NightMons:
	db 16, QUAGSIRE
	db 15, VENONAT
	db 20, RATICATE

Route11NightMons:
	db 16, MEOWTH
	db 15, RATTATA
	db 18, HYPNO

Route12NightMons:
	db 25, GLOOM
	db 28, WEEPINBELL
	db 29, POLIWHIRL

Route13NightMons:
	db 25, NOCTOWL
	db 28, QUAGSIRE
	db 29, VENOMOTH

Route14NightMons:
	db 26, GLOOM
	db 30, VENONAT
	db 30, VENOMOTH

Route15NightMons:
	db 26, ABSOL
	db 32, VENOMOTH
	db 30, GLOOM

Route16NightMons:
	db 22, GRIMER
	db 30, MUK
	db 23, MURKROW

Route17NightMons:
	db 26, GRIMER
	db 28, POLIWHIRL
	db 29, KRABBY

Route21NightMons:
	db 25, HERACROSS
	db 15, RIOLU
	db 25, RATICATE

Route22NightMons:
	db 2, POLIWAG
	db 4, WOOPER
	db 5, PSYDUCK

Route23NightMons:
	db 40, SLOWPOKE
	db 41, POLIWHIRL
	db 36, SLOWBRO

Route24NightMons:
	db 12, POLIWAG
	db 14, PSYDUCK
	db 13, ODDISH

Route25NightMons:
	db 12, ODDISH
	db 14, VENONAT
	db 13, SNEASEL

HighLevelNightMons:
	db 45, ABSOL
	db 45, HOUNDOOM
	db 46, SLOWKING
	
HighLevelNightMons2:
	db 55, TYRANITAR
	db 55, HOUNDOOM
	db 56, WEAVILE
	
HighLevelNightMons3:
	db 55, MAGMORTAR
	db 55, ELECTIVIRE
	db 56, MAGNEZONE