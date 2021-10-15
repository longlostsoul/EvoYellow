db DEX_PONYTA ; pokedex id
db 50 ; base hp
db 85 ; base attack
db 55 ; base defense
db 90 ; base speed
db 65 ; base special
db PSYCHIC ; species type 1
db PSYCHIC ; species type 2
db 80 ; catch rate
db 152 ; base exp yield
INCBIN "pic/ymon/ponyta.pic",0,1 ; 66, sprite dimensions
dw PonytaPicFront
dw PonytaPicBack
; attacks known at lvl 0
db EMBER
db CONFUSION
db FAIRY_WIND
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,38,39,40
	tmlearn 44
	tmlearn 50
db BANK(PonytaPicFront)
