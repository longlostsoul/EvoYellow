db DEX_PIKACHU ; pokedex id
db 45 ; base hp ;partner pikachu stats
db 80 ; base attack
db 50 ; base defense
db 120 ; base speed
db 75 ; base special
db ELECTRIC ; species type 1
db ELECTRIC ; species type 2
db 20 ; catch rate
db 60 ; base exp yield. if I ever do special defense split this will be the stat replaced.
INCBIN "pic/ymon/pikachu.pic",0,1 ; 55, sprite dimensions
dw PikachuPicFront
dw PikachuPicBack
; attacks known at lvl 0
db THUNDERSHOCK
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10
	tmlearn 17,19,20,24
	tmlearn 25,31,32
	tmlearn 33,39,40
	tmlearn 44,45
	tmlearn 50,52,53,54,55
db BANK(PikachuPicFront)
