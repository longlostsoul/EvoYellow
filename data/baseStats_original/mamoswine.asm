db DEX_MAMOSWINE ; pokedex id
db 110 ; base hp
db 130 ; base attack
db 80 ; base defense
db 80 ; base speed
db 70 ; base special
db GROUND ; species type 1
db ICE ; species type 2
db 120 ; catch rate
db 135 ; base exp yield
INCBIN "pic/ymon/mamoswine.pic",0,1 ; 77, sprite dimensions
dw MamoswinePicFront
dw MamoswinePicBack
; attacks known at lvl 0
db ICE_SHARD
db 0
db 0
db 0
db 5 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10
	tmlearn 20,24
	tmlearn 25,26,27,28,31,32
	tmlearn 34,38,40
	tmlearn 44,48
	tmlearn 50,54
db BANK(MamoswinePicFront)
