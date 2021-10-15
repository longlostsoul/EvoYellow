db DEX_ZAPDOS ; pokedex id
db 90 ; base hp
db 90 ; base attack
db 85 ; base defense
db 100 ; base speed
db 125 ; base special
db FIGHTING ; species type 1
db FLYING ; species type 2
db 3 ; catch rate
db 216 ; base exp yield
INCBIN "pic/ymon/zapdos.pic",0,1 ; 77, sprite dimensions
dw ZapdosPicFront
dw ZapdosPicBack
; attacks known at lvl 0
db HI_JUMP_KICK
db DRILL_PECK
db SUBMISSION
db KARATE_CHOP
db 5 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 33,34,39
	tmlearn 43,44,45
	tmlearn 50,52,55
db BANK(ZapdosPicFront)
