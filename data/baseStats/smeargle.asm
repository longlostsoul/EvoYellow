;SmeargleBaseStats:: kind of pointless to add unless I programm in sketch, but could give it a crazy movelist with all the most common sketched moves instead... idk. Smeargle doesn't seem to be very popular either, although I kind of like it that base attack is just freakin' awful. maybe boost from 20 to 50, at least..
	db DEX_SMEARGLE ; pokedex id
	db 55 ; base hp
	db 50 ; base attack
	db 35 ; base defense
	db 75 ; base speed
	db 33 ; base special
	db NORMAL ; species type 1
	db NORMAL ; species type 2
	db 79 ; catch rate
	db 106 ; base exp yield
	INCBIN "pic/ymon/smeargle.pic",0,1 ; 55, sprite dimensions
	dw SmearglePicFront
	dw SmearglePicBack
	; attacks known at lvl 0
	db SPORE
	db TRANSFORM
	db EXPLOSION
	db QUICK_ATTACK;EXTREME_SPEED
	db 4 ; growth rate
	; learnset
	tmlearn 1,2,3,4,5,6,7,8
	tmlearn 9,10,11,12,13,14,15,16
	tmlearn 17,18,19,20,21,22,23,24
	tmlearn 25,26,27,28,29,30,31,32
	tmlearn 33,34,35,36,37,38,39,40
	tmlearn 41,42,43,44,45,46,47,48
	tmlearn 49,50,51,52,53,54,55
	;tmlearn 0
	;tmlearn 0
	;tmlearn 0
	;tmlearn 0
	;tmlearn 0
	;tmlearn 0
	;tmlearn 0
	db Bank(SmearglePicFront) ; padding
