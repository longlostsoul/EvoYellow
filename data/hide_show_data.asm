; data for default hidden/shown
; objects for each map ($00-$F8)

; Table of 2-Byte pointers, one pointer per map,
; goes up to Map_F7, ends with $FFFF.
; points to table listing all missable object in the area
MapHSPointers:
	dw MapHS00
	dw MapHS01
	dw MapHS02
	dw MapHS03
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS0A
	dw MapHSXX
	dw MapHSXX
	dw MapHS0D
	dw MapHSXX
	dw MapHS0F
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS14
	dw MapHSXX
	dw MapHSXX
	dw MapHS17
	dw MapHSXX
	dw MapHSXX
	dw MapHS1A
	dw MapHS1B
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS21
	dw MapHSXX
	dw MapHS23
	dw MapHS24
	dw MapHSXX
	dw MapHSXX
	dw MapHS27
	dw MapHS28 ;oak'slab
	dw MapHSXX
	dw MapHSMart;viridian pokemart
	dw MapHSXX
	dw MapHSXX
	dw MapHS2D
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS33
	dw MapHS34
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS3B
	dw MapHSXX
	dw MapHS3D
	dw MapHSXX
	dw MapHS3F
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS53
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS58
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS60
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS66
	dw MapHS67
	dw MapHS68
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS6C
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS78
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS84
	dw MapHSXX
	dw MapHSXX
	dw MapHS87
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS8F
	dw MapHS90
	dw MapHS91
	dw MapHS92
	dw MapHS93
	dw MapHS94
	dw MapHS95
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS9B
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHS9F
	dw MapHSA0
	dw MapHSA1
	dw MapHSA2
	dw MapHSXX
	dw MapHSXX
	dw MapHSA5
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSB1
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSB5
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSC0
	dw MapHSXX
	dw MapHSC2
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSC6
	dw MapHSC7
	dw MapHSC8
	dw MapHSC9
	dw MapHSCA
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSCF
	dw MapHSD0
	dw MapHSD1
	dw MapHSD2
	dw MapHSD3
	dw MapHSD4
	dw MapHSD5
	dw MapHSD6
	dw MapHSD7
	dw MapHSD8
	dw MapHSD9
	dw MapHSDA
	dw MapHSDB
	dw MapHSDC
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSE2
	dw MapHSE3
	dw MapHSE4
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSE9
	dw MapHSEA
	dw MapHSEB
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSF4
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX
	dw MapHSXX ; beach house
	dw $FFFF

; Structure:
; 3 bytes per object
; [Map_ID][Object_ID][H/S]
;
; Program stops reading when either:
; a) Map_ID = $FF
; b) Map_ID ≠ currentMapID
;
; This Data is loaded into RAM at wd5ce-$D5F?. (wMissableObjectList)

; These constants come from the bytes for Predef functions:
Hide EQU $11 ; (HideObjectPredef - PredefPointers) / 3
Show EQU $15 ; (ShowObjectPredef - PredefPointers) / 3

MapHSXX:
	db $FF, $FF, $FF
MapHS00:
	db PALLET_TOWN, $01, Hide
MapHS01:
	db VIRIDIAN_CITY, $05, Show
	db VIRIDIAN_CITY, $07, Hide
	db VIRIDIAN_CITY, $08, Hide
MapHS02:
	db PEWTER_CITY, $03, Show
	db PEWTER_CITY, $05, Show
MapHS03:
	db CERULEAN_CITY, $01, Hide
	db CERULEAN_CITY, $02, Show
	db CERULEAN_CITY, $06, Hide
	db CERULEAN_CITY, $0A, Show
	db CERULEAN_CITY, $0B, Show
MapHS0A:
	db SAFFRON_CITY, $01, Show
	db SAFFRON_CITY, $02, Show
	db SAFFRON_CITY, $03, Show
	db SAFFRON_CITY, $04, Show
	db SAFFRON_CITY, $05, Show
	db SAFFRON_CITY, $06, Show
	db SAFFRON_CITY, $07, Show
	db SAFFRON_CITY, $08, Hide
	db SAFFRON_CITY, $09, Hide
	db SAFFRON_CITY, $0A, Hide
	db SAFFRON_CITY, $0B, Hide
	db SAFFRON_CITY, $0C, Hide
	db SAFFRON_CITY, $0D, Hide
	db SAFFRON_CITY, $0E, Show
	db SAFFRON_CITY, $0F, Hide
MapHS0D:
	db ROUTE_2, $01, Show
	db ROUTE_2, $02, Show
MapHS0F:
	db ROUTE_4, $03, Show
MapHS14:
	db ROUTE_9, $0A, Show
MapHS17:
	db ROUTE_12, $01, Show
	db ROUTE_12, $09, Show
	db ROUTE_12, $0A, Show
MapHS1A:
	db ROUTE_15, $0B, Show
MapHS1B:
	db ROUTE_16, $07, Show
MapHS21:
	db ROUTE_22, $01, Hide
	db ROUTE_22, $02, Hide
MapHS23:
	db ROUTE_24, $01, Show
	db ROUTE_24, $08, Show
MapHS24:
	db ROUTE_25, $0A, Show
MapHS27:
	db BLUES_HOUSE, $01, Show
	db BLUES_HOUSE, $02, Hide
	db BLUES_HOUSE, $03, Show
MapHS28:
	db OAKS_LAB, $01, Show
	db OAKS_LAB, $02, Show
	db OAKS_LAB, $03, Hide
	db OAKS_LAB, $04, Show
	db OAKS_LAB, $05, Show
	db OAKS_LAB, $06, Hide
MapHS2D:
	db VIRIDIAN_GYM, $01, Show
	db VIRIDIAN_GYM, $0B, Show
MapHS34:
	db MUSEUM_1F, $05, Show
MapHS3F: ; bulbasaur adoption house
	db CERULEAN_HOUSE_1, $02, Show
MapHSE4:
	db UNKNOWN_DUNGEON_1, $01, Show
	db UNKNOWN_DUNGEON_1, $02, Show
	db UNKNOWN_DUNGEON_1, $03, Show
	db UNKNOWN_DUNGEON_1, $04, Show
MapHS8F:
	db POKEMONTOWER_2, $01, Show
MapHS90:
	db POKEMONTOWER_3, $04, Show
MapHS91:
	db POKEMONTOWER_4, $04, Show
	db POKEMONTOWER_4, $05, Show
	db POKEMONTOWER_4, $06, Show
MapHS92:
	db POKEMONTOWER_5, $06, Show
MapHS93:
	db POKEMONTOWER_6, $04, Show
	db POKEMONTOWER_6, $05, Show
MapHS94:
	db POKEMONTOWER_7, $01, Hide ; jessie & james?
	db POKEMONTOWER_7, $02, Hide
	db POKEMONTOWER_7, $03, Show
MapHS95:
	db LAVENDER_HOUSE_1, $05, Hide
MapHS84:
	db CELADON_MANSION_5, $02, Show
MapHS87:
	db GAME_CORNER, $0B, Show
MapHS9B:
	db FUCHSIA_HOUSE_2, $02, Show
MapHSA5:
	db MANSION_1, $02, Show
	db MANSION_1, $03, Show
MapHSB1:
	db FIGHTING_DOJO, $06, Show
	db FIGHTING_DOJO, $07, Show
MapHSB5:
	db SILPH_CO_1F, $01, Hide
MapHS53:
	db POWER_PLANT, $01, Show
	db POWER_PLANT, $02, Show
	db POWER_PLANT, $03, Show
	db POWER_PLANT, $04, Show
	db POWER_PLANT, $05, Show
	db POWER_PLANT, $06, Show
	db POWER_PLANT, $07, Show
	db POWER_PLANT, $08, Show
	db POWER_PLANT, $09, Show
	db POWER_PLANT, $0A, Show
	db POWER_PLANT, $0B, Show
	db POWER_PLANT, $0C, Show
	db POWER_PLANT, $0D, Show
	db POWER_PLANT, $0E, Show
MapHSC2:
	db VICTORY_ROAD_2, $06, Show
	db VICTORY_ROAD_2, $07, Show
	db VICTORY_ROAD_2, $08, Show
	db VICTORY_ROAD_2, $09, Show
	db VICTORY_ROAD_2, $0A, Show
	db VICTORY_ROAD_2, $0D, Show
MapHS58:
	db BILLS_HOUSE, $01, Show
	db BILLS_HOUSE, $02, Hide
	db BILLS_HOUSE, $03, Hide
MapHS33:
	db VIRIDIAN_FOREST, $07, Show
	db VIRIDIAN_FOREST, $08, Show
	db VIRIDIAN_FOREST, $09, Show
MapHS3B:
	db MT_MOON_1, $08, Show
	db MT_MOON_1, $09, Show
	db MT_MOON_1, $0A, Show
	db MT_MOON_1, $0B, Show
	db MT_MOON_1, $0C, Show
	db MT_MOON_1, $0D, Show
MapHS3D:
	db MT_MOON_3, $02, Hide
	db MT_MOON_3, $06, Hide
	db MT_MOON_3, $07, Show
	db MT_MOON_3, $08, Show
	db MT_MOON_3, $09, Show
	db MT_MOON_3, $0A, Show
MapHS60:
	db SS_ANNE_2, $02, Hide
MapHS66:
	db SS_ANNE_8, $0A, Show
MapHS67:
	db SS_ANNE_9, $06, Show
	db SS_ANNE_9, $09, Show
MapHS68:
	db SS_ANNE_10, $09, Show
	db SS_ANNE_10, $0A, Show
	db SS_ANNE_10, $0B, Show
MapHSC6:
	db VICTORY_ROAD_3, $05, Show
	db VICTORY_ROAD_3, $06, Show
	db VICTORY_ROAD_3, $0A, Show
MapHSC7:
	db ROCKET_HIDEOUT_1, $06, Show
	db ROCKET_HIDEOUT_1, $07, Show
MapHSC8:
	db ROCKET_HIDEOUT_2, $02, Show
	db ROCKET_HIDEOUT_2, $03, Show
	db ROCKET_HIDEOUT_2, $04, Show
	db ROCKET_HIDEOUT_2, $05, Show
MapHSC9:
	db ROCKET_HIDEOUT_3, $03, Show
	db ROCKET_HIDEOUT_3, $04, Show
MapHSCA:
	db ROCKET_HIDEOUT_4, $01, Show
	db ROCKET_HIDEOUT_4, $02, Hide
	db ROCKET_HIDEOUT_4, $03, Hide
	db ROCKET_HIDEOUT_4, $05, Show
	db ROCKET_HIDEOUT_4, $06, Show
	db ROCKET_HIDEOUT_4, $07, Show
	db ROCKET_HIDEOUT_4, $08, Hide
	db ROCKET_HIDEOUT_4, $09, Hide
MapHSCF:
	db SILPH_CO_2F, $01, Show
	db SILPH_CO_2F, $02, Show
	db SILPH_CO_2F, $03, Show
	db SILPH_CO_2F, $04, Show
	db SILPH_CO_2F, $05, Show
MapHSD0:
	db SILPH_CO_3F, $02, Show
	db SILPH_CO_3F, $03, Show
	db SILPH_CO_3F, $04, Show
MapHSD1:
	db SILPH_CO_4F, $02, Show
	db SILPH_CO_4F, $03, Show
	db SILPH_CO_4F, $04, Show
	db SILPH_CO_4F, $05, Show
	db SILPH_CO_4F, $06, Show
	db SILPH_CO_4F, $07, Show
MapHSD2:
	db SILPH_CO_5F, $02, Show
	db SILPH_CO_5F, $03, Show
	db SILPH_CO_5F, $04, Show
	db SILPH_CO_5F, $05, Show
	db SILPH_CO_5F, $06, Show
	db SILPH_CO_5F, $07, Show
	db SILPH_CO_5F, $08, Show
MapHSD3:
	db SILPH_CO_6F, $06, Show
	db SILPH_CO_6F, $07, Show
	db SILPH_CO_6F, $08, Show
	db SILPH_CO_6F, $09, Show
	db SILPH_CO_6F, $0A, Show
MapHSD4:
	db SILPH_CO_7F, $05, Show
	db SILPH_CO_7F, $06, Show
	db SILPH_CO_7F, $07, Show
	db SILPH_CO_7F, $08, Show
	db SILPH_CO_7F, $09, Show
	db SILPH_CO_7F, $0A, Show
	db SILPH_CO_7F, $0B, Show
	db SILPH_CO_7F, $0C, Show
MapHSD5:
	db SILPH_CO_8F, $02, Show
	db SILPH_CO_8F, $03, Show
	db SILPH_CO_8F, $04, Show
MapHSE9:
	db SILPH_CO_9F, $02, Show
	db SILPH_CO_9F, $03, Show
	db SILPH_CO_9F, $04, Show
MapHSEA:
	db SILPH_CO_10F, $01, Show
	db SILPH_CO_10F, $02, Show
	db SILPH_CO_10F, $03, Show
	db SILPH_CO_10F, $04, Show
	db SILPH_CO_10F, $05, Show
	db SILPH_CO_10F, $06, Show
MapHSEB:
	db SILPH_CO_11F, $03, Show
	db SILPH_CO_11F, $04, Show
	db SILPH_CO_11F, $05, Show
	db SILPH_CO_11F, $06, Show
MapHSF4:
	db $F4, $02, Show
MapHSD6:
	db MANSION_2, $02, Show
MapHSD7:
	db MANSION_3, $03, Show
	db MANSION_3, $04, Show
MapHSD8:
	db MANSION_4, $03, Show
	db MANSION_4, $04, Show
	db MANSION_4, $05, Show
	db MANSION_4, $06, Show
	db MANSION_4, $08, Show
MapHSD9:
	db SAFARI_ZONE_EAST, $01, Show
	db SAFARI_ZONE_EAST, $02, Show
	db SAFARI_ZONE_EAST, $03, Show
	db SAFARI_ZONE_EAST, $04, Show
MapHSDA:
	db SAFARI_ZONE_NORTH, $01, Show
	db SAFARI_ZONE_NORTH, $02, Show
MapHSDB:
	db SAFARI_ZONE_WEST, $01, Show
	db SAFARI_ZONE_WEST, $02, Show
	db SAFARI_ZONE_WEST, $03, Show
	db SAFARI_ZONE_WEST, $04, Show
MapHSDC:
	db SAFARI_ZONE_CENTER, $01, Show
MapHSE2:
	db UNKNOWN_DUNGEON_2, $01, Show
	db UNKNOWN_DUNGEON_2, $02, Show
	db UNKNOWN_DUNGEON_2, $03, Show
	db UNKNOWN_DUNGEON_2, $04, Show
MapHSE3:
	db UNKNOWN_DUNGEON_3, $01, Show
	db UNKNOWN_DUNGEON_3, $02, Show
	db UNKNOWN_DUNGEON_3, $03, Show
	db UNKNOWN_DUNGEON_3, $04, Show
	db UNKNOWN_DUNGEON_3, $05, Show
MapHS6C:
	db VICTORY_ROAD_1, $03, Show
	db VICTORY_ROAD_1, $04, Show
MapHS78:
	db CHAMPIONS_ROOM, $02, Hide
MapHSC0:
	db SEAFOAM_ISLANDS_1, $01, Show
	db SEAFOAM_ISLANDS_1, $02, Show
MapHS9F:
	db SEAFOAM_ISLANDS_2, $01, Hide
	db SEAFOAM_ISLANDS_2, $02, Hide
MapHSA0:
	db SEAFOAM_ISLANDS_3, $01, Hide
	db SEAFOAM_ISLANDS_3, $02, Hide
MapHSA1:
	db SEAFOAM_ISLANDS_4, $02, Show
	db SEAFOAM_ISLANDS_4, $03, Show
	db SEAFOAM_ISLANDS_4, $05, Hide
	db SEAFOAM_ISLANDS_4, $06, Hide
MapHSA2:
	db SEAFOAM_ISLANDS_5, $01, Hide
	db SEAFOAM_ISLANDS_5, $02, Hide
	db SEAFOAM_ISLANDS_5, $03, Show

MapHS27Copy:
; doesn't seem to be referenced
	db VIRIDIAN_MART, $01, Show
	db VIRIDIAN_MART, $02, Show
	db VIRIDIAN_MART, $03, Show
MapHSMart:
; new
	db VIRIDIAN_MART, $04, Show
	db VIRIDIAN_MART, $02, Show
	db VIRIDIAN_MART, $03, Show

	db $FF, $01, Show
