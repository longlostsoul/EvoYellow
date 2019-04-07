;EspeonBaseStats: ; 3926a (e:526a)
db DEX_ESPEON ; pokedex id
db 65 ; base hp
db 65 ; base attack
db 60 ; base defense
db 110 ; base speed
db 130 ; base special
db PSYCHIC ; species type 1
db PSYCHIC ; species type 2
db FULL_HEAL ; catch rate
db 196 ; base exp yield
INCBIN "pic/ymon/espeon.pic",0,1 ; 66, sprite dimensions
dw EspeonPicFront
dw EspeonPicBack
; move
db TACKLE
db 0
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 5,6,7,8
	tmlearn 9,10,15,16
	tmlearn 0
	tmlearn 28,29,30,31,32
	tmlearn 33,34,39,40
	tmlearn 42,44,46
	tmlearn 49,50,54
db BANK(EspeonPicFront)