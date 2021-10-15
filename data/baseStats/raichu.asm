db DEX_RAICHU ; pokedex id
db 60 ; base hp
db 90 ; base attack
db 55 ; base defense
db 120 ; base speed
db 95 ; base special
db ELECTRIC ; species type 1
db ELECTRIC ; species type 2
db 52 ; catch rate, full heal
db 85 ; base exp yield
INCBIN "pic/ymon/raichu.pic",0,1 ; 77, sprite dimensions
dw RaichuPicFront
dw RaichuPicBack
; attacks known at lvl 0
db THUNDERSHOCK
db GROWL
db THUNDER_WAVE
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10,15
	tmlearn 17,19,20,24
	tmlearn 25,31,32
	tmlearn 33,34,35,39,40
	tmlearn 44,45
	tmlearn 50,53,55
db BANK(RaichuPicFront)
