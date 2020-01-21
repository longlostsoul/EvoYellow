db DEX_ABSOL ; pokedex id
db 65 ; base hp
db 130 ; base attack
db 60 ; base defense
db 75 ; base speed
db 75 ; base special
db DARK ; species type 1
db DARK ; species type 2
db FULL_HEAL ; catch rate
db 79 ; base exp yield
INCBIN "pic/ymon/absol.pic",0,1 ; 55, sprite dimensions
dw AbsolPicFront
dw AbsolPicBack
; attacks known at lvl 0
db SCRATCH
db QUICK_ATTACK
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,15,16
	tmlearn 20,24
	tmlearn 25,31,30,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50
db BANK(AbsolPicFront)
