db DEX_TURBAN ; pokedex id ;Might just make this an alternate form of Cloyster instead. -shrug-
db 50 ; base hp
db 95 ; base attack
db 180 ; base defense
db 70 ; base speed
db 85 ; base special
db WATER ; species type 1
db STEEL ; species type 2
db 60 ; catch rate
db 203 ; base exp yield
INCBIN "pic/ymon/cloyster_turban.pic",0,1 ; 77, sprite dimensions
dw TurbanPicFront
dw TurbanPicBack
; attacks known at lvl 0
db WITHDRAW
db SUPERSONIC
db CLAMP
db AURORA_BEAM
db 5 ; growth rate
; learnset
	tmlearn 6
	tmlearn 9,10,11,12,13,14,15
	tmlearn 20
	tmlearn 30,31,32
	tmlearn 33,34,36,39
	tmlearn 44,47
	tmlearn 49,50,51,53
db BANK(TurbanPicFront)
