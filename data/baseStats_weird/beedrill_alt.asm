db DEX_BEEDRILL ; pokedex id
db 65 ; base hp
db 80 ; base attack
db 40 ; base defense
db 80 ; base speed
db 65 ; base special ;since no phys special split, boost special here to give it a little more of a fighting chance in battle when hit.
db BUG ; species type 1
db FIRE ; species type 2
db 46 ; catch rate
db 100 ; base exp yield, special defense
INCBIN "pic/ymon/beedrill.pic",0,1 ; 77, sprite dimensions
dw BeedrillPicFront
dw BeedrillPicBack
; attacks known at lvl 0
db FURY_ATTACK
db EMBER
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 3,6
	tmlearn 9,10,15
	tmlearn 20,21
	tmlearn 31,32
	tmlearn 33,34,39,40
	tmlearn 44
	tmlearn 50,51,52
db BANK(BeedrillPicFront)
