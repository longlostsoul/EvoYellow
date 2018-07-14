;HoundourBaseStats:
db DEX_HOUNDOUR ; pokedex id
db 45 ; base hp
db 60 ; base attack
db 30 ; base defense
db 65 ; base speed
db 80 ; base special
db FIRE ; species type 1
db DARK ; species type 2
db 65 ; catch rate
db 91 ; base exp yield
INCBIN "pic/ymon/houndour.pic",0,1 ; 55, sprite dimensions
dw HoundourPicFront
dw HoundourPicBack
; moves
	db EMBER
	db 0
	db 0
	db 0
db 5 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 9,10,16
	tmlearn 22,23
	tmlearn 28,30,32,33
	tmlearn 34,37,38,39,40
	tmlearn 41,42,43,44
	tmlearn 54
db BANK(HoundourPicFront)