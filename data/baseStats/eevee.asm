db DEX_EEVEE ; pokedex id
db 65 ; base hp
db 75 ; base attack ;partner eevee had higher stats
db 70 ; base defense
db 75 ; base speed
db 65 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 52 ; catch rate, full heal
db 92 ; base exp yield
INCBIN "pic/ymon/eevee.pic",0,1 ; 55, sprite dimensions
dw EeveePicFront
dw EeveePicBack
; attacks known at lvl 0
db TACKLE
db LEER
db GROWL;LEECH_SEED let's go eevee had a move kinda like leech seed, idk.
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,39,40
	tmlearn 44
	tmlearn 50,51,52,53,54
db BANK(EeveePicFront)
