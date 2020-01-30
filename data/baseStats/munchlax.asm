db DEX_MUNCHLAX ; pokedex id. idk if will actually use but might as well have here.
db 135 ; base hp
db 85 ; base attack
db 40 ; base defense
db 5 ; base speed
db 65 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 17 ; catch rate, max potion/lefovers
db 154 ; base exp yield
INCBIN "pic/ymon/munchlax.pic",0,1 ; sprite dimensions
dw MunchlaxPicFront
dw MunchlaxPicBack
; attacks known at lvl 0
db DOUBLE_EDGE
db ZEN_HEADBUTT
db LICK
db COUNTER ;egg moves
db 5 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,11,12,13,14,15,16
	tmlearn 17,18,19,20,22,24
	tmlearn 25,26,27,29,31,32
	tmlearn 33,34,35,36,38,40
	tmlearn 44,46,48
	tmlearn 50,53,54
db BANK(MunchlaxPicFront)
