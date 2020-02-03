GetPredefPointer:
 ; Store the contents of the register
 ; pairs (hl, de, bc) at wPredefRegisters.
 ; Then put the bank and address of predef
 ; wPredefID in [wPredefBank] and hl.

	ld a, h
	ld [wPredefRegisters], a
	ld a, l
	ld [wPredefRegisters + 1], a

	ld hl, wPredefRegisters + 2
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a

	ld a, b
	ld [hli], a
	ld [hl], c

	ld hl, PredefPointers
	ld de, 0

	ld a, [wPredefID]
	ld e, a
	add a
	add e
	ld e, a
	jr nc, .nocarry
	inc d

.nocarry
	add hl, de
	ld d, h
	ld e, l

	; get bank of predef routine
	ld a, [de]
	ld [wPredefBank], a

	; get pointer
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a

	ret

PredefPointers::
 ; these are pointers to ASM routines.
 ; they appear to be used in overworld map scripts.
	const_def
	add_predef DrawPlayerHUDAndHPBar
	add_predef CopyUncompressedPicToTilemap
	add_predef AnimateSendingOutMon
	add_predef ScaleSpriteByTwo
	add_predef LoadMonBackPic
	add_predef CopyDownscaledMonTiles
	add_predef Func_f0a7
	add_predef HealParty
	add_predef MoveAnimation
	add_predef DivideBCDPredef
	add_predef DivideBCDPredef2
	add_predef AddBCDPredef
	add_predef SubBCDPredef
	add_predef DivideBCDPredef3
	add_predef DivideBCDPredef4
	add_predef InitPlayerData
	add_predef FlagActionPredef
	add_predef HideObject
	add_predef IsObjectHidden
	add_predef ApplyOutOfBattlePoisonDamage
	add_predef AnyPartyAlive
	add_predef ShowObject
	add_predef ShowObject2
	add_predef ReplaceTileBlock
	add_predef InitPlayerData2
	add_predef LoadTilesetHeader
	add_predef LearnMoveFromLevelUp
	add_predef LearnMove
	add_predef GetQuantityOfItemInBag

	predef_const CheckForHiddenObjectOrBookshelfOrCardKeyDoor
	predef_const GiveItem
	dbw $03, CheckForHiddenObjectOrBookshelfOrCardKeyDoor ; home bank
	dbw $03, GiveItem ; home bank

	add_predef InvertBGPal_4Frames
	add_predef FindPathToPlayer
	add_predef PredefShakeScreenVertically
	add_predef CalcPositionOfPlayerRelativeToNPC
	add_predef ConvertNPCMovementDirectionsToJoypadMasks
	add_predef PredefShakeScreenHorizontally
	add_predef UpdateHPBar
	add_predef HPBarLength
	add_predef Diploma_TextBoxBorder
	add_predef DoubleOrHalveSelectedStats
	add_predef ShowPokedexMenu
	add_predef EvolutionAfterBattle
	add_predef SaveSAVtoSRAM0
	add_predef InitOpponent
	add_predef CableClub_Run
	add_predef DrawBadges
	add_predef ExternalClockTradeAnim
	add_predef BattleTransition
	add_predef CopyTileIDsFromList
	add_predef PlayIntro
	add_predef GetMoveSoundB
	add_predef FlashScreen
	add_predef GetTileAndCoordsInFrontOfPlayer
	add_predef StatusScreen
	add_predef StatusScreen2
	add_predef InternalClockTradeAnim
	add_predef TrainerEngage
	add_predef IndexToPokedex
	add_predef DisplayPicCenteredOrUpperRight
	add_predef UsedCut
	add_predef ShowPokedexData
	add_predef WriteMonMoves
	add_predef SaveSAV
	add_predef LoadSGB
	add_predef MarkTownVisitedAndLoadMissableObjects
	add_predef SetPartyMonTypes
	add_predef CanLearnTM
	add_predef TMToMove
	add_predef _RunPaletteCommand
	add_predef StarterDex
	add_predef _AddPartyMon
	add_predef UpdateHPBar2
	add_predef DrawEnemyHUDAndHPBar
	add_predef LoadTownMap_Nest
	add_predef PrintMonType
	add_predef EmotionBubble
	add_predef EmptyFunc3 ; return immediately
	add_predef AskName
	add_predef PewterGuys
	add_predef SaveSAVtoSRAM2
	add_predef LoadSAV2
	add_predef LoadSAV
	add_predef SaveSAVtoSRAM1
	add_predef DoInGameTradeDialogue
	add_predef HallOfFamePC
	add_predef DisplayDexRating

	predef_const _LeaveMapAnim
	predef_const EnterMapAnim
	dbw $1E, _LeaveMapAnim ; wrong bank
	dbw $1E, EnterMapAnim ; wrong bank
	add_predef GetTileTwoStepsInFrontOfPlayer
	add_predef CheckForCollisionWhenPushingBoulder
	add_predef PrintStrengthTxt
	add_predef PickUpItem
	add_predef PrintMoveType
	add_predef LoadMovePPs
	add_predef DrawHP
	add_predef DrawHP2
	add_predef DisplayElevatorFloorMenu
	add_predef OaksAideScript
	add_predef TryFieldMove
