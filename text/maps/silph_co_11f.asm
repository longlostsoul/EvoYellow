_SilphCoPresidentText::
	text "PRESIDENT: Thank"
	line "you for saving"
	cont "SILPH!"

	para "I will never"
	line "forget you saved"
	cont "us in our moment"
	cont "of peril!"

	para "I have to thank"
	line "you in some way!"

	para "Because I am rich,"
	line "I can give you"
	cont "anything!"

	para "Here, maybe this"
	line "will do!"
	prompt

_ReceivedSilphCoMasterBallText::
	text $52, " got a"
	line "@"
	TX_RAM wcf4b
	text "!@@"

_SilphCo10Text_6231c::
	text "PRESIDENT: You"
	line "can't buy that"
	cont "anywhere!"

	para "It's our secret"
	line "prototype MASTER"
	cont "BALL!"

	para "It will catch any"
	line "#MON without"
	cont "fail!"

	para "You should be"
	line "quiet about using"
	cont "it, though."
	done

_SilphCoMasterBallNoRoomText::
	text "You have no"
	line "room for this."
	done

_SilphCo11Text2::
	text "SECRETARY: Thank"
	line "you for rescuing"
	cont "all of us!"

	para "We admire your"
	line "courage."
	done

_SilphCo11Text3::
	text "Ah, <PLAYER>!"
	line "So we meet again!"

	para "The PRESIDENT and"
	line "I are discussing"
	cont "national security"
	cont "concerning a MON."

	para "Keep your nose"
	line "out of grown-up"
	cont "matters..."

	para "or, experience a"
	line "world of pain!"
	done

_SilphCo10Text_62330::
	text "Arrgh!!"
	line "I lost again!?"
	prompt

_SilphCo10Text_62335::
	text "Blast it all!"
	line "You ruined our"
	cont "plans for SILPH!"

	para "But, TEAM ROCKET"
	line "will never fall!"

	para $52, "! Never"
	line "forget that all"
	cont "#MON exist"
	cont "for TEAM ROCKET!"

	para "I must go, but I"
	line "shall return!"
	done

_SilphCo11BattleText2::
	text "Halt! Do you have"
	line "an appointment"
	cont "with my BOSS?"
	done

_SilphCo11EndBattleText2::
	text "Gaah!"
	line "Demolished!"
	prompt

_SilphCo11AfterBattleText2::
	text "Watch your step,"
	line "my BOSS likes his"
	cont "#MON tough!"
	done
