db DEX_DITTO ; pokedex id
db 60 ; base hp
db 48 ; base attack
db 48 ; base defense
db 40 ; base speed
db 48 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 34 ; catch rate, HP UP
db 61 ; base exp yield
INCBIN "pic/ymon/ditto.pic",0,1 ; 55, sprite dimensions
dw DittoPicFront
dw DittoPicBack
; attacks known at lvl 0
db TRANSFORM
db TACKLE ;no more ditto on ditto endless battles
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
	tmlearn 0
db BANK(DittoPicFront)
