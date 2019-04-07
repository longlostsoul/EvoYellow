  db DEX_BOMBSEEKER ; pokedex id
	db 85 ; base hp
	db 70 ; base attack
	db 80 ; base defense
	db 75 ; base speed
	db 95 ; base special
	db WATER ; species type 1
	db FIRE ; species type 2
	db POTION ; catch rate
	db 183 ; base exp yield
	INCBIN "pic/ymon/bombseeker.pic",0,1 ; sprite dimensions
	dw BombseekerPicFront
	dw BombseekerPicBack
	; attacks known at lvl 0
	db BUBBLE ; meant to be Present
	db EMBER
	db GROWL
	db HEADBUTT
	db 5 ; growth rate
	; learnset
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 20
	tmlearn 31,32
	tmlearn 34,38,40
	tmlearn 44
	tmlearn 50,53,54,55
	db Bank(BombseekerPicFront) ; padding
