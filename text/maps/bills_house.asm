_BillsHouseDontLeaveText::
	text "Whoa, don't go"
	line "anywhere, wait!"
	done

_BillsHouseText_1e865::
	text "Hiya! I'm a"
	line "#MON..."
	cont "...No I'm not!"

	para "Call me BILL!"
	line "I'm a true blue"
	cont "#MANIAC! Hey!"
	cont "What's with that"
	cont "skeptical look?"

	para "I'm not joshing"
	line "you, I screwed up"
	cont "an experiment and"
	cont "got combined with"
	cont "a #MON!"

	para "So, how about it?"
	line "Help me out here!"
	done

_BillsHouseText_1e86a::
	text "When I'm in the"
	line "TELEPORTER, go to"
	cont "my PC and run the"
	cont "Cell Separation"
	cont "System!"
	done

_BillsHouseText_1e86f::
	text "No!? Come on, you"
	line "gotta help a guy"
	cont "in deep trouble!"

	para "What do you say,"
	line "chief? Please?"
	cont "OK? All right!"
	prompt

_BillThankYouText::
	text "BILL: Yeehah!"
	line "Thanks, bud! I"
	cont "owe you one!"

	para "So, did you come"
	line "to see my #MON"
	cont "collection?"
	cont "You didn't?"
	cont "That's a bummer."

	para "I've got to thank"
	line "you... Oh here,"
	cont "maybe this'll do."
	prompt

_SSTicketReceivedText::
	text $52, " received"
	line "an @"
	TX_RAM wcf4b
	text "!@@"

_SSTicketNoRoomText::
	text "You've got too"
	line "much stuff, bud!"
	done

_BillsHouseText_1e8cb::
	text "That cruise ship,"
	line "S.S.ANNE, is in"
	cont "VERMILION CITY."
	cont "Its passengers"
	cont "are all trainers!"

	para "They invited me"
	line "to their party,"
	cont "but I can't stand"
	cont "fancy do's. Why"
	cont "don't you go"
	cont "instead of me?"
	done

_BillsHouseText_checkpc:: ;1e8da
	text "BILL: Look, bud,"
	line "just check out"
	cont "some of my rare"
	cont "#MON on my PC!"
	done


_BillText_challenge::
 text "I'm pretty darn"
 line "tough. Would you"
 cont "like to fight me?"
 done

_BillText_challenge2::
 text "I have a weaker"
 line "random team."
 cont "Fight it instead?"
 done


_BillText_prebattle::
 text "I'm one of the"
 line "toughest fights"
 cont "in the game!"
 done

_BillVictorySpeech::
 text "Do "
 line "you trade too?"
 prompt

_BillDefeatSpeech::
 text "You stood"
 line "no chance."
 prompt