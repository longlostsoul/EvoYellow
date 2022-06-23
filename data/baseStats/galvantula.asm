;Galvantula
	db DEX_ARIADOS ; pokedex id
	db 70 ; base hp
	db 77 ; base attack
	db 60 ; base defense
	db 108 ; base speed
	db 97 ; base special
	db BUG ; species type 1
	db ELECTRIC ; species type 2
	db 99 ; catch rate
	db 134 ; base exp yield
	INCBIN "pic/ymon/ariados.pic",0,1 ; 66, sprite dimensions
	dw AriadosPicFront
	dw AriadosPicBack
	; attacks known at lvl 0
	db THUNDERSHOCK
	db STRING_SHOT
	db CONSTRICT
	db LICK
	db 4 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 9,10,15
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 33,34,39,40
	tmlearn 44,45
	tmlearn 50,55
	db Bank(AriadosPicFront) ; padding