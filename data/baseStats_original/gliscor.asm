db DEX_GLISCOR ; pokedex id
db 75 ; base hp
db 95 ; base attack
db 125 ; base defense
db 95 ; base speed
db 60 ; base special
db GROUND ; species type 1
db FLYING ; species type 2
db 35 ; catch rate
db 202 ; base exp yield
INCBIN "pic/ymon/gliscor.pic",0,1 ; 77, sprite dimensions
dw GliscorPicFront
dw GliscorPicBack
; attacks known at lvl 0
db GUST
db POISON_STING
db DIG
db 0
db 5 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15
	tmlearn 20,23
	tmlearn 31,32
	tmlearn 33,34,38,39
	tmlearn 43,44
	tmlearn 50,52
db BANK(GliscorPicFront)
