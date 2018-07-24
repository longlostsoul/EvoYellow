db DEX_TYRANITAR ; pokedex id
db 100 ; base hp
db 134 ; base attack
db 110 ; base defense
db 61 ; base speed
db 95 ; base special
db ROCK ; species type 1
db DARK ; species type 2
db MAX_POTION ; catch rate
db 177 ; base exp yield
INCBIN "pic/ymon/tyranitar.pic",0,1 ; 66, sprite dimensions
dw TyranitarPicFront
dw TyranitarPicBack
; attacks known at lvl 0
db TACKLE
db DEFENSE_CURL
db BITE
db 0
db 5 ; growth rate
; learnset
	tmlearn 1,6,8
	tmlearn 9,10
	tmlearn 17,18,19,20,24
	tmlearn 25,26,27,28,31,32
	tmlearn 34,35,36,38
	tmlearn 44,45,47,48
	tmlearn 50,54
db BANK(TyranitarPicFront)
