db DEX_BUTTERFREE ; pokedex id
db 60 ; base hp
db 45 ; base attack
db 55 ; base defense
db 75 ; base speed
db 100 ; base special ;boost to make more viable
db BUG ; species type 1
db FLYING ; species type 2
db 46 ; catch rate
db 80 ; base exp yield
INCBIN "pic/ymon/butterfree.pic",0,1 ; 77, sprite dimensions
dw ButterfreePicFront
dw ButterfreePicBack
; attacks known at lvl 0
db STRING_SHOT
db TACKLE
db CONFUSION
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15
	tmlearn 20,21,22
	tmlearn 29,30,31,32
	tmlearn 33,34,39
	tmlearn 44,46
	tmlearn 50,52,55
db BANK(ButterfreePicFront)
