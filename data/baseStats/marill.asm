db DEX_MARILL ; pokedex id
db 70 ; base hp
db 20 ; base attack
db 50 ; base defense
db 50 ; base speed
db 50 ; base special
db WATER ; species type 1
db FAIRY ; species type 2
db 83 ; catch rate
db 66 ; base exp yield
INCBIN "pic/ymon/marill.pic",0,1 ; 55, sprite dimensions
dw MarillPicFront
dw MarillPicBack
; attacks known at lvl 0
db TACKLE
db TAIL_WHIP
db 0
db 0
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,11,12,13,14
	tmlearn 17,18,19,20
	tmlearn 28,31,32
	tmlearn 33,34,40
	tmlearn 44
	tmlearn 50,53,54
db BANK(MarillPicFront)
