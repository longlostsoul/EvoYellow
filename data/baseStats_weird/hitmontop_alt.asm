;HitmontopBaseStats: ; 38f5a (e:4f5a)
db DEX_HITMONTOP ; pokedex id
db 50 ; base hp
db 95 ; base attack
db 95 ; base defense
db 70 ; base speed
db 110 ; base special
db FIGHTING ; species type 1
db STEEL ; species type 2
db 46 ; catch rate
db 139 ; base exp yield
INCBIN "pic/ymon/hitmontop.pic",0,1 ; 77, sprite dimensions
dw HitmontopPicFront
dw HitmontopPicBack
; move tutor compatibility flags
	db TACKLE
	db 0
	db 0
	db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10
	tmlearn 17,18,19
	tmlearn 26,27,31,32
	tmlearn 34,36,39,40
	tmlearn 44,48
	tmlearn 54
db BANK(HitmontopPicFront)
