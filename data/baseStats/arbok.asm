db DEX_ARBOK ; pokedex id
db 60 ; base hp
db 85 ; base attack
db 69 ; base defense
db 80 ; base speed
db 65 ; base special
db POISON ; species type 1
db DARK ; species type 2
db 99 ; catch rate, hold sun stone
db 147 ; base exp yield
INCBIN "pic/ymon/arbok.pic",0,1 ; 77, sprite dimensions
dw ArbokPicFront
dw ArbokPicBack
; attacks known at lvl 0
db WRAP
db LEER
db POISON_STING
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,15,16
	tmlearn 20,21
	tmlearn 26,27,28,31,32
	tmlearn 34,40
	tmlearn 44,48
	tmlearn 50,54
db BANK(ArbokPicFront)
