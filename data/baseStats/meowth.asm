db DEX_MEOWTH ; pokedex id
db 50 ; base hp
db 65 ; base attack
db 55 ; base defense
db 90 ; base speed
db 50 ; base special
db NORMAL ; species type 1
db STEEL ; species type 2
db 250 ; catch rate
db 40 ; base exp yield
INCBIN "pic/ymon/meowthgalar.pic",0,1 ; 55, sprite dimensions
dw MeowthPicFront
dw MeowthPicBack
; attacks known at lvl 0
db AMNESIA ;egg move
db HYPNOSIS;egg move
db SCRATCH
db GROWL
db 0 ; growth rate
; learnset
	tmlearn 6,7,8
	tmlearn 9,10,11,12,16
	tmlearn 20,24
	tmlearn 25,31,32
	tmlearn 34,35,39,40
	tmlearn 44
	tmlearn 50,51,52,53,54
db BANK(MeowthPicFront)
