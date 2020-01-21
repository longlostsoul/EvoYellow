db DEX_MR_RIME ; pokedex id
db 80 ; base hp
db 85 ; base attack
db 75 ; base defense
db 70 ; base speed
db 110 ; base special
db PSYCHIC ; species type 1
db ICE ; species type 2
db 46 ; catch rate
db 136 ; base exp yield
INCBIN "pic/ymon/mrrime.pic",0,1 ; 66, sprite dimensions
dw MrRimePicFront
dw MrRimePicBack
; attacks known at lvl 0
db CONFUSION
db BARRIER
db ICE_BEAM
db 0
db 0 ; growth rate
; learnset
	tmlearn 1,5,6,8
	tmlearn 9,10,15
	tmlearn 17,18,19,20,22,24
	tmlearn 25,29,30,31,32
	tmlearn 33,34,35,40
	tmlearn 44,45,46
	tmlearn 50,55
db BANK(MrRimePicFront)
