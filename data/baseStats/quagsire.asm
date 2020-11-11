db DEX_QUAGSIRE ; pokedex id
db 95 ; base hp
db 85 ; base attack
db 85 ; base defense
db 35 ; base speed
db 65 ; base special
db WATER ; species type 1
db GROUND ; species type 2
db 36 ; catch rate
db 210 ; base exp yield
INCBIN "pic/ymon/quagsire.pic",0,1 ; 77, sprite dimensions
dw QuagsirePicFront
dw QuagsirePicBack
; attacks known at lvl 0
db TACKLE
db SPLASH
db BUBBLE
db WATER_GUN
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 17,18,19,20
	tmlearn 26,27,28,31,32
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 50,53,54
db BANK(QuagsirePicFront)
