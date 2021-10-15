db DEX_VAPOREON ; pokedex id
db 130 ; base hp
db 65 ; base attack
db 60 ; base defense
db 65 ; base speed
db 110 ; base special
db WATER ; species type 1
db WATER ; species type 2
db 33 ; catch rate
db 196 ; base exp yield
INCBIN "pic/ymon/vaporeon.pic",0,1 ; 66, sprite dimensions
dw VaporeonPicFront
dw VaporeonPicBack
; attacks known at lvl 0
db TACKLE
db SPLASH
db QUICK_ATTACK
db WATER_GUN
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,39
	tmlearn 44
	tmlearn 50,53
db BANK(VaporeonPicFront)
