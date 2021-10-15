db DEX_PERSIAN ; pokedex id
db 65 ; base hp
db 70 ; base attack
db 65 ; base defense
db 115 ; base speed
db 75 ; base special
db DARK ; species type 1
db STEEL ; species type 2
db FULL_HEAL ; catch rate
db 75 ; base exp yield / special defense. Stats boosted here for 'meowth starter version'
INCBIN "pic/ymon/persian.pic",0,1 ; 77, sprite dimensions
dw PersianPicFront
dw PersianPicBack
; attacks known at lvl 0
db SCRATCH
db METAL_CLAW
db BITE
db SCREECH
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,15,16
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50,51
db BANK(PersianPicFront)
