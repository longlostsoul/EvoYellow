db DEX_EXEGGUTOR ; pokedex id
db 95 ; base hp
db 95 ; base attack
db 85 ; base defense
db 55 ; base speed
db 125 ; base special
db GRASS ; species type 1
db DRAGON ; species type 2
db SUPER_POTION ; catch rate
db 212 ; base exp yield
INCBIN "pic/ymon/exeggutor.pic",0,1 ; 77, sprite dimensions
dw ExeggutorPicFront
dw ExeggutorPicBack
; attacks known at lvl 0
db BARRAGE
db HYPNOSIS
db DRAGON_RAGE
db 0
db 5 ; growth rate
; learnset
	tmlearn 2,6
	tmlearn 9,10,15
	tmlearn 20,21,22,23
	tmlearn 29,30,31,32
	tmlearn 33
	tmlearn 44,46,47
	tmlearn 50,51,54,55
db BANK(ExeggutorPicFront)
