db DEX_NOCTOWL ; pokedex id
	db 100 ; base hp
	db 50 ; base attack
	db 50 ; base defense
	db 70 ; base speed
	db 86 ; base special
	db GHOST ; species type 1
	db FLYING ; species type 2
	db 52 ; catch rate
	db 162 ; base exp yield
	INCBIN "pic/ymon/noctowl.pic",0,1 ; 77, sprite dimensions
	dw NoctowlPicFront
	dw NoctowlPicBack
	; attacks known at lvl 0
	db TACKLE
	db GROWL
	db PECK
	db NIGHT_SHADE
	db 0 ; growth rate
	; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15
	tmlearn 20
	tmlearn 30,31,32,33
	tmlearn 33,34,39,40
	tmlearn 42,43,44
	tmlearn 50,52
	db BANK(NoctowlPicFront) ; padding
