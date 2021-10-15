db DEX_WEEZING ; pokedex id
db 65 ; base hp
db 90 ; base attack
db 120 ; base defense
db 60 ; base speed
db 85 ; base special
db POISON ; species type 1
db FAIRY ; species type 2
db 79 ; catch rate
db 173 ; base exp yield
INCBIN "pic/ymon/weezing.pic",0,1 ; 77, sprite dimensions
dw WeezingPicFront
dw WeezingPicBack
; attacks known at lvl 0
db TACKLE
db SMOG
db SLUDGE
db FAIRY_WIND
db 0 ; growth rate
; learnset
	tmlearn 6
	tmlearn 15
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 34,36,38,40
	tmlearn 44,47
	tmlearn 50
db BANK(WeezingPicFront)
