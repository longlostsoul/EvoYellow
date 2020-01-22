db DEX_SIRFETCHD ; pokedex id
db 62 ; base hp
db 135 ; base attack
db 95 ; base defense
db 65 ; base speed
db 68 ; base special
db FIGHTING ; species type 1
db FLYING ; species type 2
db 35 ; catch rate, protein
db 94 ; base exp yield
INCBIN "pic/ymon/farfetchd.pic",0,1 ; 66, sprite dimensions
dw SirfetchdPicFront
dw SirfetchdPicBack
; attacks known at lvl 0
db PECK
db SAND_ATTACK
db KARATE_CHOP
db 0
db 0 ; growth rate
; learnset
	tmlearn 2,3,4,6,7,8
	tmlearn 9,10
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,37,39,40
	tmlearn 44
	tmlearn 50,51,52
db BANK(SirfetchdPicFront)
