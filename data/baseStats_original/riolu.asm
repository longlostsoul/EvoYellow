db DEX_RIOLU ; pokedex id
db 40 ; base hp
db 70 ; base attack
db 40 ; base defense
db 60 ; base speed
db 35 ; base special
db FIGHTING ; species type 1
db FIGHTING ; species type 2
db 35 ; catch rate
db 193 ; base exp yield
INCBIN "pic/ymon/riolu.pic",0,1 ; 77, sprite dimensions
dw RioluPicFront
dw RioluPicBack
; attacks known at lvl 0
db KARATE_CHOP
db LOW_KICK
db LEER
db METAL_CLAW
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,15
	tmlearn 17,18,19,20
	tmlearn 26,27,28,31,32
	tmlearn 34,35,38,40
	tmlearn 44,48
	tmlearn 50,54
db BANK(RioluPicFront)
