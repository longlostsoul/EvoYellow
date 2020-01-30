db DEX_MEGA_CHARIZARD ; pokedex id. using a dex slot for this is... less than optimal.
db 78 ; base hp
db 104 ; base attack
db 78 ; base defense
db 100 ; base speed
db 150 ; base special
db FIRE ; species type 1
db DRAGON ; species type 2
db SHINY_STONE
db 209 ; base exp yield
INCBIN "pic/ymon/megacharizard.pic",0,1 ; 77, sprite dimensions
dw MegaCharizardPicFront
dw MegaCharizardPicBack
; attacks known at lvl 0
db FLAMETHROWER
db TWISTER
db FLY
db SWORDS_DANCE
db 3 ; growth rate
; learnset
	tmlearn 1,3,5,6,7,8
	tmlearn 9,10,15
	tmlearn 17,18,19,20,23
	tmlearn 26,27,28,31,32
	tmlearn 33,34,38,39,40
	tmlearn 44
	tmlearn 50,51,52,54
db BANK(MegaCharizardPicFront)
