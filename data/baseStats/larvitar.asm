db DEX_LARVITAR ; pokedex id
db 50 ; base hp
db 64 ; base attack
db 50 ; base defense
db 41 ; base speed
db 50 ; base special
db ROCK ; species type 1
db GROUND ; species type 2
db 52 ; catch rate, full heal
db 177 ; base exp yield
INCBIN "pic/ymon/larvitar.pic",0,1 ; 66, sprite dimensions
dw LarvitarPicFront
dw LarvitarPicBack
; attacks known at lvl 0
db TACKLE
db DEFENSE_CURL
db BITE
db 0
db 5 ; growth rate
; learnset
	tmlearn 1,6,7,8
	tmlearn 9,10
	tmlearn 17,18,19,20,24
	tmlearn 25,26,27,28,31,32
	tmlearn 34,35,36,38,40
	tmlearn 44,45,47,48
	tmlearn 50,54
db BANK(LarvitarPicFront)
