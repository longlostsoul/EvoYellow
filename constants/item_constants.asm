const_value = 1

	const MASTER_BALL   ; $01
	const ULTRA_BALL    ; $02
	const GREAT_BALL    ; $03
	const POKE_BALL     ; $04
	const TOWN_MAP      ; $05
	const BICYCLE       ; $06
	const SURFBOARD     ; $07 buggy?
	const SAFARI_BALL   ; $08
	const POKEDEX       ; $09
	const MOON_STONE    ; $0A 10
	const ANTIDOTE      ; $0B Pecha Berry
	const BURN_HEAL     ; $0C 
	const ICE_HEAL      ; $0D Renamed to a berry
	const AWAKENING     ; $0E Renamed Chesto Berry
	const PARLYZ_HEAL   ; $0F 15 Cheri Berry
	const FULL_RESTORE  ; $10 16
	const MAX_POTION    ; $11 17 Leftovers, can still heal with it, but also hold it.
	const HYPER_POTION  ; $12 18
	const SUPER_POTION  ; $13 19 Renamed Moomoo Milk, same effect as before though.
	const POTION        ; $14 20
	const BOULDERBADGE  ; $15 21
	const CASCADEBADGE  ; $16 22
SAFARI_BAIT           EQU $15 ; overload
SAFARI_ROCK           EQU $16 ; overload
	const THUNDERBADGE  ; $17
	const RAINBOWBADGE  ; $18
	const SOULBADGE     ; $19
	const MARSHBADGE    ; $1A
	const VOLCANOBADGE  ; $1B
	const EARTHBADGE    ; $1C
	const ESCAPE_ROPE   ; $1D
	const REPEL         ; $1E 29
	const OLD_AMBER     ; $1F 30
	const FIRE_STONE    ; $20 31
	const THUNDER_STONE ; $21 32
	const WATER_STONE   ; $22 33
	const HP_UP         ; $23 34
	const PROTEIN       ; $24 35
	const IRON          ; $25 36
	const CARBOS        ; $26 37
	const CALCIUM       ; $27 38
	const RARE_CANDY    ; $28 39
	const DOME_FOSSIL   ; $29 40
	const HELIX_FOSSIL  ; $2A 42
	const SECRET_KEY    ; $2B 43
	const SNAG_BALL   ; $2C "?????" 44
	const BIKE_VOUCHER  ; $2D 45
	const X_ACCURACY    ; $2E 46
	const LEAF_STONE    ; $2F 47
	const CARD_KEY      ; $30 48
	const NUGGET        ; $31 49
	const PP_UP_2       ; $32 50
	const POKE_DOLL     ; $33 51
	const FULL_HEAL     ; $34 52 Lum Berry
	const REVIVE        ; $35 53
	const MAX_REVIVE    ; $36 54
	const GUARD_SPEC    ; $37 55
	const SUPER_REPEL   ; $38 56
	const MAX_REPEL     ; $39 57
	const DIRE_HIT      ; $3A 58
	const COIN          ; $3B 59
	const FRESH_WATER   ; $3C 60
	const SODA_POP      ; $3D 61
	const LEMONADE      ; $3E 62
	const S_S_TICKET    ; $3F 3
	const GOLD_TEETH    ; $40 4
	const X_ATTACK      ; $41 65
	const X_DEFEND      ; $42 66
	const X_SPEED       ; $43 7
	const X_SPECIAL     ; $44 68
	const COIN_CASE     ; $45 69
	const OAKS_PARCEL   ; $46 70
	const ITEMFINDER    ; $47 71
	const SILPH_SCOPE   ; $48 72
	const POKE_FLUTE    ; $49 73
	const LIFT_KEY      ; $4A 74
	const EXP_ALL       ; $4B 75
	const OLD_ROD       ; $4C 76
	const GOOD_ROD      ; $4D 77
	const SUPER_ROD     ; $4E 78
	const PP_UP         ; $4F 79
	const ETHER         ; $50 80
	const MAX_ETHER     ; $51 81
	const ELIXER        ; $52 82
	const MAX_ELIXER    ; $53 83
	const FLOOR_B2F     ; $54 84
	const FLOOR_B1F     ; $55 85
	const FLOOR_1F      ; $56 86
	const FLOOR_2F      ; $57 87
	const FLOOR_3F      ; $58 88
	const FLOOR_4F      ; $59 89
	const FLOOR_5F      ; $5A 90
	const FLOOR_6F      ; $5B 91
	const FLOOR_7F      ; $5C 92
	const FLOOR_8F      ; $5D 93
	const FLOOR_9F      ; $5E 94
	const FLOOR_10F     ; $5F 95
	const FLOOR_11F     ; $60 96
	const FLOOR_B4F     ; $61 97
	const SUN_STONE     ; $62 98
	const FROST_STONE    ; $63 99
	const LOVE_STONE     ; $64 100
  const SHINY_STONE;this and below not currently in use 101
  const KINGS_ROCK;102
 	const STEEL_COAT;103
	const QUICK_CLAW;104
	const EVOLITE;105
;	const LUCKY_EGG
	const SITRUS_BERRY;106
	const ORAN_BERRY;107

const_value = $C4

	const HM_01         ; $C4
	const HM_02         ; $C5
	const HM_03         ; $C6
	const HM_04         ; $C7
	const HM_05         ; $C8
	const TM_01         ; $C9
	const TM_02         ; $CA
	const TM_03         ; $CB
	const TM_04         ; $CC
	const TM_05         ; $CD
	const TM_06         ; $CE
	const TM_07         ; $CF
	const TM_08         ; $D0
	const TM_09         ; $D1
	const TM_10         ; $D2
	const TM_11         ; $D3
	const TM_12         ; $D4
	const TM_13         ; $D5
	const TM_14         ; $D6
	const TM_15         ; $D7
	const TM_16         ; $D8
	const TM_17         ; $D9
	const TM_18         ; $DA
	const TM_19         ; $DB
	const TM_20         ; $DC
	const TM_21         ; $DD
	const TM_22         ; $DE
	const TM_23         ; $DF
	const TM_24         ; $E0
	const TM_25         ; $E1
	const TM_26         ; $E2
	const TM_27         ; $E3
	const TM_28         ; $E4
	const TM_29         ; $E5
	const TM_30         ; $E6
	const TM_31         ; $E7
	const TM_32         ; $E8
	const TM_33         ; $E9
	const TM_34         ; $EA
	const TM_35         ; $EB
	const TM_36         ; $EC
	const TM_37         ; $ED
	const TM_38         ; $EE
	const TM_39         ; $EF
	const TM_40         ; $F0
	const TM_41         ; $F1
	const TM_42         ; $F2
	const TM_43         ; $F3
	const TM_44         ; $F4
	const TM_45         ; $F5
	const TM_46         ; $F6
	const TM_47         ; $F7
	const TM_48         ; $F8
	const TM_49         ; $F9
	const TM_50         ; $FA
