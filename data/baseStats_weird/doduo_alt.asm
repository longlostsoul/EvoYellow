db DEX_DODUO ; pokedex id
db 35 ; base hp
db 85 ; base attack
db 45 ; base defense
db 75 ; base speed
db 35 ; base special
db GROUND ; species type 1
db FLYING ; species type 2
db 37 ; catch rate, carbos
db 96 ; base exp yield
INCBIN "pic/ymon/doduo.pic",0,1 ; 55, sprite dimensions
dw DoduoPicFront
dw DoduoPicBack
; attacks known at lvl 0
db PECK
db DIG
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 4,6,8
	tmlearn 9,10
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,40
	tmlearn 43,44
	tmlearn 49,50,52
db BANK(DoduoPicFront)
