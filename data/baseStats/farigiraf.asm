db DEX_FARIGIRAF ; pokedex id
	db 120 ; base hp
	db 90 ; base attack
	db 70 ; base defense
	db 60 ; base speed
	db 110 ; base special
	db NORMAL  ; species type 1
	db PSYCHIC ; species type 2
	db 60 ; catch rate
	db 149 ; base exp yield
	INCBIN "pic/ymon/girafarig.pic",0,1 ; 55, sprite dimensions
	dw GirafarigPicFront
	dw GirafarigPicBack
	; attacks known at lvl 0
	db SLAM
	db GROWL
	db DOUBLE_KICK
	db PSYCHIC
	db 0 ; growth rate
	; learnset
	tmlearn 6
	tmlearn 9
	tmlearn 24
	tmlearn 25,26,29,30,31,32
	tmlearn 34,39
	tmlearn 42,44
	tmlearn 50,54
	db Bank(GirafarigPicFront) ; padding
