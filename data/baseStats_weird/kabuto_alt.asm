db DEX_KABUTO ; pokedex id
db 30 ; base hp
db 80 ; base attack
db 90 ; base defense
db 55 ; base speed
db 45 ; base special
db GROUND ; species type 1
db WATER ; species type 2
db 33 ; catch rate
db 119 ; base exp yield
INCBIN "pic/ymon/kabuto.pic",0,1 ; 55, sprite dimensions
dw KabutoPicFront
dw KabutoPicBack
; attacks known at lvl 0
db SCRATCH
db HARDEN
db 0
db 0
db 0 ; growth rate
; learnset
	tmlearn 6,8
	tmlearn 9,10,11,12,13,14
	tmlearn 20
	tmlearn 31,32
	tmlearn 33,34,37,40
	tmlearn 44
	tmlearn 50,51,53
db BANK(KabutoPicFront)
