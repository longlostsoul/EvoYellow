db DEX_VICTREEBEL	 ; pokedex id
db 80 ; base hp
db 105 ; base attack
db 65 ; base defense
db 70 ; base speed
db 100 ; base special
db GRASS ; species type 1
db WATER ; species type 2
db 52 ; catch rate, full heal
db 191 ; base exp yield
INCBIN "pic/ymon/victreebel.pic",0,1 ; 77, sprite dimensions
dw VictreebelPicFront
dw VictreebelPicBack
; attacks known at lvl 0
db BUBBLEBEAM
db STUN_SPORE
db ACID
db RAZOR_LEAF
db 3 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 9,10,15,16
	tmlearn 20,21,22
	tmlearn 31,32
	tmlearn 33,34
	tmlearn 44
	tmlearn 50,51
db BANK(VictreebelPicFront)
