db DEX_RATICATE ; pokedex id
db 75 ; base hp
db 81 ; base attack
db 70 ; base defense
db 97 ; base speed
db 50 ; base special
db DARK ; species type 1
db DARK ; species type 2
db 80 ; catch rate
db 90 ; base exp yield
INCBIN "pic/ymon/raticate.pic",0,1 ; 66, sprite dimensions
dw RaticatePicFront
dw RaticatePicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db QUICK_ATTACK
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,13,14,15,16
	tmlearn 20,24
	tmlearn 25,28,31,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50,51
db BANK(RaticatePicFront)
