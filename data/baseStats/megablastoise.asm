db DEX_MEGA_BLASTOISE ; pokedex id
db 79 ; base hp
db 100 ; base attack
db 120 ; base defense
db 78 ; base speed
db 135 ; base special
db WATER ; species type 1
db WATER ; species type 2
db SHINY_STONE ; catch rate
db 210 ; base exp yield
INCBIN "pic/ymon/megablastoise.pic",0,1 ; 77, sprite dimensions
dw MegaBlastoisePicFront
dw MegaBlastoisePicBack
; attacks known at lvl 0
db BODY_SLAM
db EARTHQUAKE
db ICE_BEAM
db HYDRO_PUMP
db 3 ; growth rate
; learnset
	tmlearn 1,5,6,7,8
	tmlearn 9,10,11,12,13,14,15
	tmlearn 17,18,19,20
	tmlearn 26,27,28,31,32
	tmlearn 33,34,35,40
	tmlearn 44
	tmlearn 50,53,54
db BANK(MegaBlastoisePicFront)
