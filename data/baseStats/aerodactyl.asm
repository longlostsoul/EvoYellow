db DEX_AERODACTYL ; pokedex id
db 80 ; base hp
db 105 ; base attack
db 65 ; base defense
db 130 ; base speed
db 70 ; base special
db ROCK ; species type 1
db FLYING ; species type 2
db FULL_HEAL ; catch rate
db 202 ; base exp yield
INCBIN "pic/ymon/aerodactyl.pic",0,1 ; 77, sprite dimensions
dw AerodactylPicFront
dw AerodactylPicBack
; attacks known at lvl 0
db WING_ATTACK
db AGILITY
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 2,4,6,7
	tmlearn 9,10,15,16
	tmlearn 20,23
	tmlearn 31,32
	tmlearn 33,34,38,39,40
	tmlearn 43,44
	tmlearn 50,52
db BANK(AerodactylPicFront)
