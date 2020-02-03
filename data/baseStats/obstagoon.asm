  db DEX_OBSTAGOON ; pokedex id
	db 78 ; base hp
	db 70 ; base attack
	db 61 ; base defense
	db 100 ; base speed
	db 55 ; base special
	db DARK ; species type 1
	db NORMAL ; species type 2
	db 90 ; catch rate
	db 128 ; base exp yield
	INCBIN "pic/bmon/obstagoon.pic",0,1 ; 55, sprite dimensions
	dw ObstagoonPicFront
	dw ObstagoonPicBack
	; attacks known at lvl 0
	db TACKLE
	db GROWL
	db BITE
	db HEADBUTT
	db 0 ; growth rate
	; learnset
	tmlearn 6,8
	tmlearn 9,10,11,12,14
	tmlearn 20,24
	tmlearn 25,28,31,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50,51,53,54
	db Bank(ObstagoonPicFront) ; padding