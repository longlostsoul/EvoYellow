  db DEX_FORRETRESS ; pokedex id
	db 75 ; base hp
	db 90 ; base attack
	db 140 ; base defense
	db 40 ; base speed
	db 60 ; base special
	db BUG  ; species type 1
	db STEEL  ; species type 2
	db FULL_HEAL ; catch rate.
	db 118 ; base exp yield
	INCBIN "pic/ymon/forretress.pic",0,1 ; 55, sprite dimensions
	dw ForretressPicFront
	dw ForretressPicBack
	; attacks known at lvl 0
	db TACKLE
	db 0 ; PROTECT
	db 0 ; SPIKES. Put Spikes and Forretress in game eventually?
	db 0
	db 0 ; growth rate
	; learnset
	tmlearn 6,8
	tmlearn 9,10
	tmlearn 18,20,21
	tmlearn 26,28,32
	tmlearn 33,34,36,39
	tmlearn 44
	tmlearn 50,54
	db Bank(ForretressPicFront) ; padding
