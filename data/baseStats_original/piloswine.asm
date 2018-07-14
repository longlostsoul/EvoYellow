db DEX_PILOSWINE ; pokedex id
db 100 ; base hp
db 100 ; base attack
db 80 ; base defense
db 50 ; base speed
db 60 ; base special
db GROUND ; species type 1
db ICE ; species type 2
db 52 ; catch rate
db 135 ; base exp yield
INCBIN "pic/ymon/piloswine.pic",0,1 ; 77, sprite dimensions
dw PiloswinePicFront
dw PiloswinePicBack
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
db BANK(PiloswinePicFront)
