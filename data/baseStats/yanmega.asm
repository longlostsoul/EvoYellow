db DEX_YANMEGA ; pokedex id
db 86 ; base hp
db 76 ; base attack
db 86 ; base defense
db 95 ; base speed
db 116 ; base special
db BUG ; species type 1
db DRAGON ; species type 2 ;originally flying, but, eh.
db 46 ; catch rate
db 56 ; base exp yield
INCBIN "pic/ymon/yanmega.pic",0,1 ; 77, sprite dimensions
dw YanmegaPicFront
dw YanmegaPicBack
; attacks known at lvl 0
db TACKLE
db DRAGONBREATH
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,4,6
	tmlearn 9,10,15,16
	tmlearn 20,21,22
	tmlearn 29,30,31,32
	tmlearn 33,34,39
	tmlearn 44,46
	tmlearn 50,52,55
db BANK(YanmegaPicFront)
