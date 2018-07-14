db DEX_WOOPER ; pokedex id
db 55 ; base hp
db 45 ; base attack
db 45 ; base defense
db 15 ; base speed
db 25 ; base special
db WATER ; species type 1
db GROUND ; species type 2
db 190 ; catch rate
db 210 ; base exp yield
INCBIN "pic/ymon/wooper.pic",0,1 ; 77, sprite dimensions
dw WooperPicFront
dw WooperPicBack
; attacks known at lvl 0
db BUBBLE
db TAIL_WHIP
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 17,18,19,20
	tmlearn 26,27,28,31,32
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 50,53,54
db BANK(WooperPicFront)
