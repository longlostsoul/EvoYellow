db DEX_YANMA ; pokedex id
db 65 ; base hp
db 65 ; base attack
db 45 ; base defense
db 95 ; base speed
db 75 ; base special
db BUG ; species type 1
db FLYING ; species type 2
db 46 ; catch rate
db 50 ; base exp yield
INCBIN "pic/ymon/yanma.pic",0,1 ; 77, sprite dimensions
dw YanmaPicFront
dw YanmaPicBack
; attacks known at lvl 0
db TACKLE
db 0
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15
	tmlearn 20,21,22
	tmlearn 29,30,31,32
	tmlearn 33,34,39
	tmlearn 44,46
	tmlearn 50,52,55
db BANK(YanmaPicFront)
