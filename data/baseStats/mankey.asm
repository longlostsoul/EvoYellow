db DEX_MANKEY ; pokedex id
db 40 ; base hp
db 80 ; base attack
db 35 ; base defense
db 70 ; base speed
db 35 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 190 ; catch rate
db 74 ; base exp yield
INCBIN "pic/ymon/mankey.pic",0,1 ; 55, sprite dimensions
dw MankeyPicFront
dw MankeyPicBack
; attacks known at lvl 0
db SCRATCH
db LEER
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10,16
	tmlearn 17,18,19,20,24
	tmlearn 25,28,31,32
	tmlearn 34,35,39,40
	tmlearn 44,48
	tmlearn 50,51,54
db BANK(MankeyPicFront)
