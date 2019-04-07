db DEX_BERURUN ; pokedex id
db 65 ; base hp
db 70 ; base attack
db 60 ; base defense
db 115 ; base speed
db 65 ; base special
db DARK ; species type 1
db GHOST ; species type 2
db FULL_HEAL ; catch rate
db 148 ; base exp yield
INCBIN "pic/ymon/berurun.pic",0,1 ; 77, sprite dimensions
dw BerurunPicFront
dw BerurunPicBack
; attacks known at lvl 0
db SCRATCH
db LICK
db BITE
db SCREECH
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,15,16
	tmlearn 20,24
	tmlearn 25,31,30,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50
db BANK(BerurunPicFront)
