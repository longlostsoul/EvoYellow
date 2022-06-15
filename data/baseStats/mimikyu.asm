db DEX_MIMIKYU ; pokedex id
db 55 ; base hp
db 90 ; base attack
db 80 ; base defense
db 96 ; base speed
db 50 ; base special
db GHOST ; species type 1
db FAIRY ; species type 2
db 99 ; catch rate
db 105 ; base exp yield
INCBIN "pic/ymon/mimikyu.pic",0,1 ; 66, sprite dimensions
dw MimikyuPicFront
dw MimikyuPicBack
; attacks known at lvl 0
db LICK
db CONFUSE_RAY
db TACKLE
db 0
db 3 ; growth rate
; learnset // same as gengar atm.
	tmlearn 1,5,6,8
	tmlearn 9,10,15,16
	tmlearn 17,18,19,20,21,24
	tmlearn 25,29,30,31,32
	tmlearn 34,35,36,40
	tmlearn 42,44,46,47
	tmlearn 50,54
db BANK(MimikyuPicFront)
