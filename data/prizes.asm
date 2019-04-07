PrizeDifferentMenuPtrs:
	dw PrizeMenuMon1Entries
	dw PrizeMenuMon1Cost

	dw PrizeMenuMon2Entries
	dw PrizeMenuMon2Cost

	dw PrizeMenuTMsEntries
	dw PrizeMenuTMsCost

PrizeMenuMon1Entries:
	db RIOLU
	db NATU
	db REMORAID
	db "@"

PrizeMenuMon1Cost:
	coins 100
	coins 300
	coins 680
	db "@"

PrizeMenuMon2Entries:
	db GIRAFARIG
	db WOBBUFFET
	db PORYGON
	db "@"

PrizeMenuMon2Cost:
	coins 100
	coins 500
	coins 999
	db "@"

PrizeMenuTMsEntries:
	db TM_23
	db TM_15
	db TM_50
	db "@"

PrizeMenuTMsCost:
	coins 300
	coins 500
	coins 700
	db "@"
