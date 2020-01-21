  db DEX_CURSOLA ; pokedex id
	db 60 ; base hp
	db 95 ; base attack
	db 50 ; base defense
	db 30 ; base speed
	db 145 ; base special
	db WATER ; species type 1
	db GHOST ; species type 2
	db 60 ; catch rate
	db 99 ; base exp yield
	INCBIN "pic/ymon/cursola.pic",0,1 ; sprite dimensions
	dw CursolaPicFront
	dw CursolaPicBack
	; attacks known at lvl 0
	db TACKLE
	db HARDEN
	db LICK
	db DISABLE
	db 5 ; growth rate
	; learnset
	tmlearn 6,8
	tmlearn 9,10,11,12,13,14
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,36
	tmlearn 44
	tmlearn 50,53
	db BANK(CorsolaPicFront) ; padding