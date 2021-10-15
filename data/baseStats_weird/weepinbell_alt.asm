db DEX_WEEPINBELL ; pokedex id
db 65 ; base hp
db 90 ; base attack
db 50 ; base defense
db 55 ; base speed
db 85 ; base special
db GRASS ; species type 1
db WATER ; species type 2
db 62 ; catch rate
db 151 ; base exp yield
INCBIN "pic/ymon/weepinbell.pic",0,1 ; 66, sprite dimensions
dw WeepinbellPicFront
dw WeepinbellPicBack
; attacks known at lvl 0
db VINE_WHIP
db GROWTH
db WRAP
db BUBBLE
db 3 ; growth rate
; learnset
	tmlearn 3,6
	tmlearn 9,10,16
	tmlearn 20,21,22
	tmlearn 31,32
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 50,51
db BANK(WeepinbellPicFront)
