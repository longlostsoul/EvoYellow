db DEX_EXEGGCUTE ; pokedex id
db 60 ; base hp
db 40 ; base attack
db 80 ; base defense
db 40 ; base speed
db 60 ; base special
db GRASS ; species type 1
db PSYCHIC ; species type 2
db 83 ; catch rate, elixer
db 98 ; base exp yield
INCBIN "pic/ymon/exeggcute.pic",0,1 ; 77, sprite dimensions
dw ExeggcutePicFront
dw ExeggcutePicBack
; attacks known at lvl 0
db BARRAGE
db HYPNOSIS
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 6
	tmlearn 9,10
	tmlearn 20,22
	tmlearn 29,30,31,32
	tmlearn 33
	tmlearn 44,46,47
	tmlearn 50,51,55
db BANK(ExeggcutePicFront)
