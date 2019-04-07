db DEX_GRANBULL ; pokedex id
db 90 ; base hp
db 120 ; base attack
db 75 ; base defense
db 45 ; base speed
db 60 ; base special
db FAIRY ; species type 1
db FAIRY ; species type 2
db 19 ; catch rate
db 69 ; base exp yield
INCBIN "pic/ymon/Granbull.pic",0,1 ; 55, sprite dimensions
dw GranbullPicFront
dw GranbullPicBack
; attacks known at lvl 0
db BITE
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,16
	tmlearn 20,24
	tmlearn 25,31,30,32
	tmlearn 34,39,40
	tmlearn 44,49
	tmlearn 50
db BANK(GranbullPicFront)
