db DEX_OCTILLERY ; pokedex id
	db 75 ; base hp
	db 105 ; base attack
	db 75 ; base defense
	db 45 ; base speed
	db 105 ; base special
	db WATER ; species type 1
	db FIRE ; species type 2
	db FULL_HEAL ; catch rate
	db 75 ; base exp yield
	INCBIN "pic/ymon/octillery.pic",0,1 ; sprite dimensions
	dw OctilleryPicFront
	dw OctilleryPicBack
	; attacks known at lvl 0
	db WATER_GUN
	db BARRAGE
	db WATER_PULSE
	db 0
	db 0 ; growth rate
	; learnset
	tmlearn 6
	tmlearn 9,10,11,12,13,14,15,16
	tmlearn 20
	tmlearn 30,31,32
	tmlearn 33,34,36,39,40
	tmlearn 44,47
	tmlearn 49,50,53
	db Bank(OctilleryPicFront) ; padding
