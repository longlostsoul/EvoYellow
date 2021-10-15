db DEX_SHARPEDO ; pokedex id
db 70 ; base hp
db 120 ; base attack
db 40 ; base defense
db 95 ; base speed
db 95 ; base special
db WATER ; species type 1
db DARK ; species type 2
db 80 ; catch rate
db 40 ; base exp yield
INCBIN "pic/ymon/frontikarisharpedo.pic",0,1 ; 77, sprite dimensions
dw SharpedoPicFront
dw SharpedoPicBack
; attacks known at lvl 0
db BITE
db BUBBLE
db HEADBUTT
db 0
db 0 ; growth rate
; learnset need to update this if want to use
	tmlearn 1,5,6,8
	tmlearn 10,11,12,13,14,15,16
	tmlearn 17,18,19,20
	tmlearn 26,27,28,29,30,31,32
	tmlearn 33,34,38,39,40
	tmlearn 44,45,46
	tmlearn 50,53,54,55
db BANK(SharpedoPicFront)
