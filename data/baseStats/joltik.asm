	;Joltik, not spinarak.
	db DEX_SPINARAK ; pokedex id
	db 40 ; base hp
	db 60 ; base attack
	db 40 ; base defense
	db 30 ; base speed
	db 40 ; base special
	db BUG ; species type 1
	db ELECTRIC ; species type 2
	db 255 ; catch rate
	db 54 ; base exp yield
	INCBIN "pic/ymon/spinarak.pic",0,1 ; 66, sprite dimensions
	dw SpinarakPicFront
	dw SpinarakPicBack
	; attacks known at lvl 0
	db POISON_STING
	db STRING_SHOT
	db LICK
	db THUNDERSHOCK
	db 4 ; growth rate
	; learnset
	; learnset
	tmlearn 6,8
	tmlearn 9,10,15
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 33,34,39,40
	tmlearn 44,45
	tmlearn 50,55
	db Bank(SpinarakPicFront) ; padding
