db DEX_GRAVELER ; pokedex id
db 55 ; base hp
db 95 ; base attack
db 115 ; base defense
db 35 ; base speed
db 45 ; base special
db GROUND; species type 1
db ELECTRIC ; species type 2
db 83 ; catch rate
db 134 ; base exp yield
INCBIN "pic/ymon/graveler.pic",0,1 ; 66, sprite dimensions
dw GravelerPicFront
dw GravelerPicBack
; attacks known at lvl 0
db TACKLE
db DEFENSE_CURL
db THUNDERSHOCK
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,6,8
	tmlearn 9,10
	tmlearn 17,18,19,20,24
	tmlearn 25,26,27,28,31,32
	tmlearn 34,35,36,38
	tmlearn 44,45,47,48
	tmlearn 50,54
db BANK(GravelerPicFront)
