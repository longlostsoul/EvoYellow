  db DEX_CELEBI ; pokedex id
	db 100 ; base hp
	db 100 ; base attack
	db 100 ; base defense
	db 100 ; base speed
	db 100 ; base special
	db GRASS ; species type 1
	db PSYCHIC ; species type 2
	db 3 ; catch rate
	db 64 ; base exp yield
	INCBIN "pic/ymon/celebi.pic",0,1 ; 55, sprite dimensions
	dw CelebiPicFront
	dw CelebiPicBack
	; attacks known at lvl 0
	db RECOVER
	db CONFUSION
	db LEECH_SEED
	db FAIRYWIND
	db 3 ; growth rate
	; learnset
	tmlearn 3,6
	tmlearn 10,15
	tmlearn 20,21,22
	tmlearn 29,31,32
	tmlearn 33,34,35,39
	tmlearn 42,44,45,46
	tmlearn 50,55
	db Bank(CelebiPicFront) ; padding
