db DEX_NINETALES ; pokedex id
db 73 ; base hp
db 76 ; base attack
db 75 ; base defense
db 100 ; base speed
db 100 ; base special
db FIRE ; species type 1
db FIRE ; species type 2
db FULL_HEAL ; catch rate
db 178 ; base exp yield
INCBIN "pic/ymon/ninetales.pic",0,1 ; 77, sprite dimensions
dw NinetalesPicFront
dw NinetalesPicBack
; attacks known at lvl 0
db EMBER
db SHADOW_BALL
db QUICK_ATTACK
db ROAR
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,15
	tmlearn 20
	tmlearn 28,31,30,32
	tmlearn 33,34,38,39,40
	tmlearn 44,49
	tmlearn 50,51
db BANK(NinetalesPicFront)
