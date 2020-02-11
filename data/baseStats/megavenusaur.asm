db DEX_MEGA_VENUSAUR ; pokedex id
db 80 ; base hp
db 100 ; base attack
db 123 ; base defense
db 80 ; base speed
db 122 ; base special
db GRASS ; species type 1
db POISON ; species type 2
db SHINY_STONE ; catch rate
db 208 ; base exp yield
INCBIN "pic/ymon/mega_venusaur.pic",0,1 ; 77, sprite dimensions
dw MegaVenusaurPicFront
dw MegaVenusaurPicBack
; attacks known at lvl 0
db TAKE_DOWN
db SLEEP_POWDER
db LEECH_SEED
db MEGA_DRAIN
db 3 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 9,10,15,16
	tmlearn 20,21,22
	tmlearn 26,31,32
	tmlearn 33,34
	tmlearn 44
	tmlearn 50,51
db BANK(MegaVenusaurPicFront)
