db DEX_GOLEM ; pokedex id
db 80 ; base hp
db 110 ; base attack
db 130 ; base defense
db 45 ; base speed
db 55 ; base special
db ROCK ; species type 1
db ELECTRIC ; species type 2
db FULL_HEAL ; catch rate
db 177 ; base exp yield
INCBIN "pic/ymon/golem.pic",0,1 ; 66, sprite dimensions
dw GolemPicFront
dw GolemPicBack
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
db BANK(GolemPicFront)
