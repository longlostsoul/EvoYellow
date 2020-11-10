;CrobatBaseStats: ; 3885a (e:485a)
db DEX_CROBAT ; pokedex id
db 85 ; base hp
db 90 ; base attack
db 80 ; base defense
db 130 ; base speed
db 80 ; base special
db POISON ; species type 1
db FAIRY ; species type 2
db 100 ; catch rate
db 204 ; base exp yield
INCBIN "pic/ymon/crobat.pic",0,1 ; 77, sprite dimensions
dw CrobatPicFront
dw CrobatPicBack
	db LEECH_LIFE
  db 0
  db 0
  db 0
db 0 ; growth rate
; learnset
	tmlearn 3,4,6,8
	tmlearn 9,10,15
	tmlearn 21
	tmlearn 30,31,32
	tmlearn 33,34,39
	tmlearn 41,42,43,44
	tmlearn 52
db BANK(CrobatPicFront)
