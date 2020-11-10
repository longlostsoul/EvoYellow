db DEX_MAWILE ; pokedex id
db 50 ; base hp
db 100 ; base attack
db 125 ; base defense ;mega stats
db 50 ; base speed
db 55 ; base special
db STEEL ; species type 1
db FAIRY ; species type 2
db 99 ; catch rate
db 95 ; base exp yield
INCBIN "pic/ymon/mawile.pic",0,1 ; 66, sprite dimensions
dw MawilePicFront
dw MawilePicBack
; attacks known at lvl 0
db LICK
db BITE
db SLAM
db 0
db 3 ; growth rate
; learnset fix this later
	tmlearn 1,5,6,8
	tmlearn 9,10,15,16
	tmlearn 17,18,19,20,21,24
	tmlearn 25,29,30,31,32
	tmlearn 34,35,36,40
	tmlearn 42,44,46,47
	tmlearn 50,54
db BANK(MawilePicFront)
