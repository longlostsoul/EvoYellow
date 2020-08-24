db DEX_SALANDIT ; pokedex id
	db 48 ; base hp
	db 44 ; base attack
	db 40 ; base defense
	db 77 ; base speed
	db 70 ; base special
	db POISON ; species type 1
	db FIRE ; species type 2
	db ETHER ; catch rate 80
	db 57 ; base exp yield
	INCBIN "pic/ymon/frontsalandit.pic",0,1 ; sprite dimensions
	dw SalanditPicFront
	dw SalanditPicBack
	; attacks known at lvl 0
	db POISON_GAS
	db SCRATCH
	db EMBER
	db HIDDEN_POWER
	db 3 ; growth rate
	; learnset
	tmlearn 2,6,7,8;2 Twister 6 Toxic 7 Iron Tail8 Body Slam
	tmlearn 9,10,15,16;9Takedown, 10Doubleedge,15 hyperbeam 16 Poison Jab
	tmlearn 20,23;20 rage 23 Dragonbreath
	tmlearn 28,31,32;28 Dig 31 Mimic 32 Double Team
	tmlearn 34,38,39,40;34 Mud Slap 38FireBlast 39 swift 40 Dark Pulse
	tmlearn 44;rest
	tmlearn 50,51,54,55;50substitute,cut,strength,flash
	db Bank(SalanditPicFront) ; padding
