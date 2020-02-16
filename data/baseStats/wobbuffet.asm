db DEX_WOBBUFFET ; pokedex id
db 190 ; base hp
db 33 ; base attack
db 58 ; base defense
db 33 ; base speed
db 58 ; base special
db PSYCHIC ; species type 1
db PSYCHIC ; species type 2
db ETHER ; catch rate
db 20 ; base exp yield
INCBIN "pic/ymon/wobbuffet.pic",0,1 ; 66, sprite dimensions
dw WobbuffetPicFront
dw WobbuffetPicBack
; attacks known at lvl 0
db COUNTER
db MIRROR_COAT
db BABYDOLLEYES
db SPLASH
db 5 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
db BANK(WobbuffetPicFront)
