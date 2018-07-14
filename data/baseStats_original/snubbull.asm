db DEX_SNUBBULL ; pokedex id
db 60 ; base hp
db 80 ; base attack
db 50 ; base defense
db 30 ; base speed
db 40 ; base special
db FAIRY ; species type 1
db FAIRY ; species type 2
db 255 ; catch rate
db 69 ; base exp yield
INCBIN "pic/ymon/snubbull.pic",0,1 ; 55, sprite dimensions
dw SnubbullPicFront
dw SnubbullPicBack
; attacks known at lvl 0
db BITE
db GROWL
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 9,10,11,12,16
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 34,39,40
	tmlearn 44
	tmlearn 50
db BANK(SnubbullPicFront)
