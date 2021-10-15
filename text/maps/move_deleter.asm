_MoveDeleterGreetingText::
	text "Umm..."

	para "Oh, yes, I'm the"
	line "MOVE DELETER."

	para "But you don't"
	line "need me, for"
	cont "HM moves."

	para "Mon should be"
	line "able to forget."
	done

_MoveDeleterSaidYesText::
	text "Which #MON"
	line "should forget a"
	cont "move?"
	prompt

_MoveDeleterWhichMoveText::
	text "Which move should"
	line "it forget, then?"
	done

_MoveDeleterConfirmText::
	text "Make it forget"
	line "@"
	TX_RAM wcf4b
	text "?"
	prompt

_MoveDeleterForgotText::
	text "@"
	TX_RAM wcf4b
	text " was"
	line "forgotten!"
	prompt

_MoveDeleterByeText::
	text "Come visit me"
	line "again!"
	done

_MoveDeleterOneMoveText::
	text "That #MON"
	line "knows only one"
	cont "move."
	done
