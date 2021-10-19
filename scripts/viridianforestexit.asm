ViridianForestExitScript:
	jp EnableAutoTextBoxDrawing

ViridianForestExitTextPointers:
	dw ViridianForestExitText1
	dw ViridianForestExitText2

ViridianForestExitText1:
	TX_FAR _ViridianForestExitText1
	TX_ASM
	ld hl, RematchTrainerText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	jr z, .Refight
	jp .end
.Refight
	ResetEventRange EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_0,EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_4,1
	ResetEvent EVENT_90B
.end
	jp TextScriptEnd

RematchTrainerText::
 TX_FAR _RematchTrainerText
 db "@"

ViridianForestExitText2:
	TX_FAR _ViridianForestExitText2
	db "@"
