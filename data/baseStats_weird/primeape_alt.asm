db DEX_PRIMEAPE ; pokedex id
db 65 ; base hp
db 105 ; base attack
db 60 ; base defense
db 95 ; base speed
db 60 ; base special
db FIGHTING ; species type 1
db DARK ; species type 2
db FULL_HEAL ; catch rate
db 149 ; base exp yield
INCBIN "pic/ymon/primeape.pic",0,1 ; 77, sprite dimensions
dw PrimeapePicFront
dw PrimeapePicBack
; attacks known at lvl 0
db SCRATCH
db BITE
db LOW_KICK
db KARATE_CHOP
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,15,16
	tmlearn 17,18,19,20,24
	tmlearn 25,28,31,32
	tmlearn 34,35,39,40
	tmlearn 44,48
	tmlearn 50,54
db BANK(PrimeapePicFront)
