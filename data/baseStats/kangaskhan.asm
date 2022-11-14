db DEX_KANGASKHAN ; pokedex id
db 105 ; base hp
db 95 ; base attack
db 80 ; base defense
db 90 ; base speed
db 65 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 36 ; catch rate, item iron
db 175 ; base exp yield
INCBIN "pic/ymon/kangaskhan.pic",0,1 ; 77, sprite dimensions
dw KangaskhanPicFront
dw KangaskhanPicBack
; attacks known at lvl 0
db COMET_PUNCH
db RAGE
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 17,18,19,20,24
	tmlearn 25,26,27,31,32
	tmlearn 34,35,38,40
	tmlearn 44,48
	tmlearn 50,53,54
db BANK(KangaskhanPicFront)
