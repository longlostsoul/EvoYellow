;TangrowthBaseStats: ; 3903a (e:503a)
db DEX_TANGROWTH ; pokedex id
db 90 ; base hp
db 90 ; base attack
db 125 ; base defense
db 50 ; base speed
db 110 ; base special
db GRASS ; species type 1
db GRASS ; species type 2
db 47 ; catch rate
db 211 ; base exp yield
INCBIN "pic/ymon/tangrowth.pic",0,1 ; 66, sprite dimensions
dw TangrowthPicFront
dw TangrowthPicBack
	db ABSORB
  db 0
  db 0
  db 0
db 0 ; growth rate
; learnset
	tmlearn 3,6,8
	tmlearn 9,10,15
	tmlearn 21,22
	tmlearn 31,32
	tmlearn 34,35,40
	tmlearn 44
	tmlearn 50,51,54
db BANK(TangrowthPicFront)
