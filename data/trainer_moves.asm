; yellow has its own format.

; entry = trainerclass, trainerid, moveset+, 0
; moveset = partymon location, partymon's move, moveid 

SpecialTrainerMoves:
	db BUG_CATCHER,$f
	db 2,2,TACKLE
	db 2,3,BIDE
	db 0

	db YOUNGSTER,$e
	db 1,4,FISSURE
	db 0

	db BROCK,$1
	db 2,3,RAGE
	db 3,4,BIDE
	db 3,1,ROCK_TOMB
	db 5,1,ABSORB
	db 5,2,WATER_GUN
	db 5,3,CUT
	db 6,1,WING_ATTACK
	db 6,2,ROCK_TOMB
	db 0

	db MISTY,$1
	db 2,2,ICE_BEAM
	db 2,4,BUBBLEBEAM
	db 3,4,BUBBLEBEAM
	db 5,1,BUBBLEBEAM
	db 0

	db LT_SURGE,$1
	db 1,1,VOLT_TACKLE
	db 1,2,MEGA_PUNCH
	db 1,3,BIDE
	db 1,4,SURF
	db 0

	db ERIKA,$1
	db 1,3,GIGA_DRAIN
	db 2,1,RAZOR_LEAF
	DB 5,2,GIGA_DRAIN
	DB 5,1,EARTHQUAKE
	db 6,1,PETAL_DANCE
	db 0

	db KOGA,$1
	db 1,1,TOXIC
	db 1,2,DIG
	db 2,1,TOXIC
	db 3,3,FLAMETHROWER
	db 3,1,TOXIC
	db 3,2,DOUBLE_EDGE
	db 4,1,LEECH_LIFE
	db 4,2,DOUBLE_TEAM
	db 4,3,PSYCHIC_M
	db 4,4,TOXIC
	db 0

	db BLAINE,$1
	db 1,1,FLAMETHROWER
	db 1,4,CONFUSE_RAY
	db 3,1,FLAMETHROWER
	db 3,2,FIRE_BLAST
	db 3,3,REFLECT
	db 4,1,DIG
	db 0

	db SABRINA,$1
	db 1,1,FLASH
	db 3,1,MEGA_DRAIN
	db 3,4,PSYCHIC
	db 3,1,EXPLOSION
	db 4,1,PSYWAVE
	db 0

	db GIOVANNI,$3
	db 1,3,FISSURE
	db 2,2,THUNDERBOLT
	db 3,1,SURF
	db 3,3,ICE_BEAM
	db 4,1,EARTHQUAKE
	db 4,2,SLUDGE
	db 4,3,THUNDER
	db 5,1,ROCK_SLIDE
	db 5,4,EARTHQUAKE
	db 0

	db LORELEI,$1
	db 1,1,BLIZZARD
	db 2,1,HYDRO_PUMP
	db 2,2,ICE_BEAM
	db 3,3,SHADOW_BALL
	db 3,1,FIRE_BLAST
	db 3,2,EARTHQUAKE
	db 3,4,PSYCHIC_M
	db 4,1,PSYCHIC_M
	db 4,2,LOVELY_KISS
	db 4,3,WATER_PULSE
	db 4,4,ICE_PUNCH
	db 5,3,BLIZZARD
	db 5,4,THUNDERBOLT
	db 0

	db BRUNO,$1
	db 1,1,ROCK_SLIDE
	db 1,2,THUNDER_FANG
	db 1,4,DIG
	db 1,2,CRUNCH
	db 2,3,FIRE_PUNCH
	db 2,4,DOUBLE_TEAM
	db 3,1,DOUBLE_KICK
	db 3,2,BIDE
	db 3,4,DOUBLE_TEAM
	db 4,1,ROCK_SLIDE
	db 4,2,ICE_BEAM
	db 4,4,EARTHQUAKE
	db 5,4,DYNAMICPUNCH
	db 5,3,SHADOW_PUNCH
	db 5,2,ICE_PUNCH
	db,5,1,GIGA_IMPACT
	db 0

	db AGATHA,$1
	db 1,1,DREAM_EATER
	db 1,2,SHADOW_BALL
	db 1,3,HYPNOSIS
	db 1,4,MEGA_DRAIN
	db 2,2,TOXIC
	db 2,4,LEECH_LIFE
	db 3,2,FIRE_BLAST
	db 4,1,CRUNCH
	db,4,2,GUNK_SHOT
	db 4,3,ICE_FANG
	db 4,4,EARTHQUAKE
	db 6,2,PSYCHIC_M
	db 0

	db LANCE,$1
	db 1,1,HYPER_BEAM
	db 2,2,THUNDER_WAVE
	db 2,3,THUNDERBOLT
	db 2,1,BUBBLEBEAM
	db 2,4,ICE_BEAM
	db 3,3,EARTHQUAKE
	db 3,1,CRUNCH
	db 3,2,GIGA_IMPACT
	db 3,4,POWER_GEM
	db 4,1,EARTHQUAKE
	db 4,2,TOXIC
	db 4,3,FLY
	db 5,1,FIRE_BLAST
	db 5,2,FLY
	db 6,1,BLIZZARD
	db 6,2,HYPER_BEAM
	db 6,3,THUNDER
	db 6,4,OUTRAGE
	db 0

	db SONY3,$1
	db 1,3,EARTHQUAKE
	db 2,4,KINESIS
	db 3,4,LEECH_SEED
	db 4,1,ICE_BEAM
	db 5,1,CONFUSE_RAY
	db 5,4,FIRE_SPIN
	db 6,3,QUICK_ATTACK
	db 0

	db SONY3,$2
	db 1,3,EARTHQUAKE
	db 2,4,KINESIS
	db 3,4,LEECH_SEED
	db 4,1,THUNDERBOLT
	db 5,1,ICE_BEAM
	db 6,2,REFLECT
	db 6,3,QUICK_ATTACK
	db 0

	db SONY3,$3
	db 1,3,EARTHQUAKE
	db 2,4,KINESIS
	db 3,4,LEECH_SEED
	db 4,1,CONFUSE_RAY
	db 4,4,FIRE_SPIN
	db 5,1,THUNDERBOLT
	db 5,1,THUNDER_WAVE
	db 6,3,QUICK_ATTACK
	db 0

	db $ff
