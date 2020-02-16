;AipomBaseStats:: actually not sure if I want to add Aipom, it's not one of my favorite pokemon. Giving it a weird typing could make it more entertaining though. poison/fighting or somethin'. on other hand, if do that maybe just better off adding a newer gen poke I like better.
	db DEX_AMBIPOM ; pokedex id
	db 50 ; base hp
	db 70 ; base attack
	db 55 ; base defense
	db 85 ; base speed
	db 50 ; base special
	db NORMAL ; species type 1
	db NORMAL ; species type 2
	db 49 ; catch rate, hold nugget
	db 94 ; base exp yield
	INCBIN "pic/ymon/ambipom.pic",0,1 ; 55, sprite dimensions
	dw AmbipomPicFront
	dw AmbipomPicBack
	; attacks known at lvl 0
	db SCRATCH
	db TAIL_WHIP
	db MEGA_PUNCH
	db 0
	db 0 ; growth rate
	; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,16
	tmlearn 17,18,19,20,24
	tmlearn 25,28,31,32
	tmlearn 34,35,39,40
	tmlearn 44,48
	tmlearn 50,54
	db Bank(AmbipomPicFront) ; padding
