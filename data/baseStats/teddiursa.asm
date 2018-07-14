db DEX_TEDDIURSA ; pokedex id
db 60 ; base hp
db 80 ; base attack
db 50 ; base defense
db 40 ; base speed
db 50 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 130 ; catch rate
db 104 ; base exp yield
INCBIN "pic/ymon/teddiursa.pic",0,1 ; 77, sprite dimensions
dw TeddiursaPicFront
dw TeddiursaPicBack
; attacks known at lvl 0
db HEADBUTT
db GROWL
db TACKLE
db LEER
db 5 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,11,12,13,14,15,16
	tmlearn 17,18,19,20,22,24
	tmlearn 25,26,27,29,31,32
	tmlearn 33,34,35,36,38,40
	tmlearn 44,46,48
	tmlearn 50,53,54
db BANK(TeddiursaPicFront)
