; INPUTS - Mon DVs in de, species in wGenderTemp
; OUTPUT - Mon's gender in wGenderTemp
GetMonGender::
	ld hl, MonGenderRatios
	ld a, [wGenderTemp]
	dec a
	ld c, a
	ld b, 0
	add hl, bc ; hl now points to the species gender ratio
	
; Attack DV
	ld a, [de]
	and $f0
	ld b, a
; Speed DV
	inc de
	ld a, [de]
	and $f0
	swap a
; Put them together
	or b
	ld b, a ; b now has the combined DVs
	
; Get the gender ratio
	ld a, [hl]
	
; Check for always one or another
	cp NO_GENDER
	jr z, .genderless
	
	cp FEMALE_ONLY
	jr z, .female
	
	and a ; MALE_ONLY
	jr z, .male
	
; Compare the ratio to the value we found earlier
	cp b
	jr c, .male
	
.female
	ld a, FEMALE
	jr .done
.male
	ld a, MALE
	jr .done
.genderless
	ld a, GENDERLESS
.done
	ld [wGenderTemp], a
	ret
	
MonGenderRatios:
	db FEMALE_ONLY; Kangaskhan
	db MALE_ONLY; NidoranM
	db FEMALE_75_PERCENT; Clefairy
	db SAME_BOTH_GENDERS; Spearow
	db NO_GENDER; Voltorb
	db MALE_ONLY; Nidoking
	db SAME_BOTH_GENDERS; Slowbro
	db SAME_BOTH_GENDERS; Lickitung
	db SAME_BOTH_GENDERS; Exeggcute
	db SAME_BOTH_GENDERS; Grimer
	db SAME_BOTH_GENDERS; Gengar
	db FEMALE_ONLY; NidoranF
	db FEMALE_ONLY; Nidoqueen
	db SAME_BOTH_GENDERS; Cubone
	db MALE_88_PERCENT; Rhyhorn
	db SAME_BOTH_GENDERS; Lapras
	db SAME_BOTH_GENDERS; Arcanine
	db NO_GENDER; Mew
	db SAME_BOTH_GENDERS; Gyarados
	db SAME_BOTH_GENDERS; Shellder
	db SAME_BOTH_GENDERS; Tentacool
	db SAME_BOTH_GENDERS; Gastly
	db SAME_BOTH_GENDERS; Scyther
	db NO_GENDER; Staryu
	db SAME_BOTH_GENDERS; Pinsir
	db SAME_BOTH_GENDERS; Tangela
	db SAME_BOTH_GENDERS; Growlithe
	db SAME_BOTH_GENDERS; Onix
	db SAME_BOTH_GENDERS; Fearow
	db SAME_BOTH_GENDERS; Pidgey
	db SAME_BOTH_GENDERS; Slowpoke
	db MALE_75_PERCENT; Kadabra
	db MALE_75_PERCENT; Graveler
	db FEMALE_ONLY; Chansey
	db MALE_75_PERCENT; Machoke
	db MALE_ONLY; Mr.Mime
	db MALE_ONLY; Hitmonlee
	db MALE_ONLY; Hitmonchan
	db SAME_BOTH_GENDERS; Arbok
	db SAME_BOTH_GENDERS; Parasect
	db SAME_BOTH_GENDERS; Psyduck
	db SAME_BOTH_GENDERS; Drowzee
	db MALE_75_PERCENT; Golem
	db SAME_BOTH_GENDERS; Magmar
	db SAME_BOTH_GENDERS; Electabuzz
	db NO_GENDER; Magneton
	db SAME_BOTH_GENDERS; Koffing
	db SAME_BOTH_GENDERS; Mankey
	db SAME_BOTH_GENDERS; Seel
	db SAME_BOTH_GENDERS; Diglett
	db MALE_ONLY; Tauros
	db SAME_BOTH_GENDERS; Farfetch'd
	db SAME_BOTH_GENDERS; Venonat
	db SAME_BOTH_GENDERS; Dragonite
	db SAME_BOTH_GENDERS; Doduo
	db SAME_BOTH_GENDERS; Poliwag
	db FEMALE_ONLY; Jynx
	db NO_GENDER; Moltres
	db NO_GENDER; Articuno
	db NO_GENDER; Zapdos
	db NO_GENDER; Ditto
	db SAME_BOTH_GENDERS; Meowth
	db SAME_BOTH_GENDERS; Krabby
	db SAME_BOTH_GENDERS; Vulpix
	db SAME_BOTH_GENDERS; Ninetales
	db SAME_BOTH_GENDERS; Pikachu
	db SAME_BOTH_GENDERS; Raichu
	db SAME_BOTH_GENDERS; Dratini
	db SAME_BOTH_GENDERS; Dragonair
	db SAME_BOTH_GENDERS; Kabuto
	db SAME_BOTH_GENDERS; Kabutops
	db SAME_BOTH_GENDERS; Horsea
	db SAME_BOTH_GENDERS; Seadra
	db SAME_BOTH_GENDERS; Sandshrew
	db SAME_BOTH_GENDERS; Sandslash
	db SAME_BOTH_GENDERS; Omanyte
	db SAME_BOTH_GENDERS; Omastar
	db FEMALE_75_PERCENT; Jigglypuff
	db FEMALE_75_PERCENT; Wigglytuff
	db SAME_BOTH_GENDERS; Eevee
	db SAME_BOTH_GENDERS; Flareon
	db SAME_BOTH_GENDERS; Jolteon
	db SAME_BOTH_GENDERS; Vaporeon
	db MALE_75_PERCENT; Machop
	db SAME_BOTH_GENDERS; Zubat
	db SAME_BOTH_GENDERS; Ekans
	db SAME_BOTH_GENDERS; Paras
	db SAME_BOTH_GENDERS; Poliwhirl
	db SAME_BOTH_GENDERS; Poliwrath
	db SAME_BOTH_GENDERS; Weedle
	db SAME_BOTH_GENDERS; Kakuna
	db SAME_BOTH_GENDERS; Beedrill
	db SAME_BOTH_GENDERS; Dodrio
	db SAME_BOTH_GENDERS; Primeape
	db SAME_BOTH_GENDERS; Dugtrio
	db SAME_BOTH_GENDERS; Venomoth
	db SAME_BOTH_GENDERS; Dewgong
	db SAME_BOTH_GENDERS; Caterpie
	db SAME_BOTH_GENDERS; Metapod
	db SAME_BOTH_GENDERS; Butterfree
	db MALE_75_PERCENT; Machamp
	db SAME_BOTH_GENDERS; Golduck
	db SAME_BOTH_GENDERS; Hypno
	db SAME_BOTH_GENDERS; Golbat
	db SAME_BOTH_GENDERS; Mewtwo
	db SAME_BOTH_GENDERS; Snorlax
	db SAME_BOTH_GENDERS; Magikarp
	db SAME_BOTH_GENDERS; Muk
	db SAME_BOTH_GENDERS; Kingler
	db SAME_BOTH_GENDERS; Cloyster
	db NO_GENDER; Electrode
	db FEMALE_ONLY; Clefable
	db SAME_BOTH_GENDERS; Weezing
	db SAME_BOTH_GENDERS; Persian
	db SAME_BOTH_GENDERS; Marowak
	db SAME_BOTH_GENDERS; Haunter
	db MALE_75_PERCENT; Abra
	db MALE_75_PERCENT; Alakazam
	db SAME_BOTH_GENDERS; Pidgeotto
	db SAME_BOTH_GENDERS; Pidgeot
	db NO_GENDER; Starmie
	db SAME_BOTH_GENDERS; Tentacruel
	db SAME_BOTH_GENDERS; Goldeen
	db SAME_BOTH_GENDERS; Seaking
	db SAME_BOTH_GENDERS; Ponyta
	db SAME_BOTH_GENDERS; Rapidash
	db SAME_BOTH_GENDERS; Rattata
	db SAME_BOTH_GENDERS; Raticate
	db SAME_BOTH_GENDERS; Nidorino
	db SAME_BOTH_GENDERS; Nidorina
	db MALE_75_PERCENT; Geodude
	db NO_GENDER; Porygon
	db SAME_BOTH_GENDERS; Aerodactyl
	db NO_GENDER; Magnemite
	db SAME_BOTH_GENDERS; Oddish
	db SAME_BOTH_GENDERS; Gloom
	db SAME_BOTH_GENDERS; Vileplume
	db SAME_BOTH_GENDERS; Bellsprout
	db SAME_BOTH_GENDERS; Weepinbell
	db SAME_BOTH_GENDERS; Victreebel
	db SAME_BOTH_GENDERS ; Toge
	db SAME_BOTH_GENDERS ; T
	db SAME_BOTH_GENDERS ; togekiss
	db SAME_BOTH_GENDERS ; H
	db SAME_BOTH_GENDERS ; Hound
	db SAME_BOTH_GENDERS ; Hera
	db SAME_BOTH_GENDERS ;Crobat
	db SAME_BOTH_GENDERS ; Sneasel 
	db SAME_BOTH_GENDERS ; weavile
	db SAME_BOTH_GENDERS ; skarm
	db FEMALE_75_PERCENT ; misdreavus
	db FEMALE_75_PERCENT ; Mismag
	db FEMALE_ONLY ; Milk
	db SAME_BOTH_GENDERS ; chin
	db SAME_BOTH_GENDERS ; lanturn
	db SAME_BOTH_GENDERS ; slug
	db SAME_BOTH_GENDERS ; MagG
	db MALE_ONLY ; Tyrogue
	db MALE_ONLY ; Hitmontop
	db SAME_BOTH_GENDERS ; Murkrow
	db SAME_BOTH_GENDERS ; Honchkrow
	db SAME_BOTH_GENDERS ; Marill
	db SAME_BOTH_GENDERS ; Azumarill
	db SAME_BOTH_GENDERS ; Swinub
	db SAME_BOTH_GENDERS ; Pilo
	db SAME_BOTH_GENDERS ; Mamo
	db SAME_BOTH_GENDERS ; Wooper
	db SAME_BOTH_GENDERS ; Quag
	db SAME_BOTH_GENDERS ; Yanma
	db SAME_BOTH_GENDERS ; Yanmega
	db NO_GENDER ; Poryonz
	db SAME_BOTH_GENDERS ; phanpy
	db SAME_BOTH_GENDERS ; donphan
	db SAME_BOTH_GENDERS ; gligar
	db SAME_BOTH_GENDERS ; gliscor
	db SAME_BOTH_GENDERS ; teddiursa
	db SAME_BOTH_GENDERS ; ursaring
	db SAME_BOTH_GENDERS ; snubbull
	db SAME_BOTH_GENDERS ; granbull
	db SAME_BOTH_GENDERS ; larvitar
	db SAME_BOTH_GENDERS ; pupi
	db SAME_BOTH_GENDERS ; tyran
	db SAME_BOTH_GENDERS ;STANTLER ABSOL
	db NO_GENDER;const DEX_CORSOLA
  db SAME_BOTH_GENDERS;const DEX_HOOTHOOT
  db SAME_BOTH_GENDERS;const DEX_NOCTOWL
  db FEMALE_ONLY;const DEX_SUNKERN
  db FEMALE_ONLY;const DEX_SUNFLORA now salandit
  db SAME_BOTH_GENDERS;  const DEX_HOPPIP
  db SAME_BOTH_GENDERS;const DEX_JUMPLUFF
  db SAME_BOTH_GENDERS;const DEX_SKIPLOOM
  db SAME_BOTH_GENDERS;const DEX_MAREEP
  db SAME_BOTH_GENDERS;const DEX_FLAAFFY
  db SAME_BOTH_GENDERS;const DEX_AMPHAROS
  db SAME_BOTH_GENDERS;const DEX_NATU
  db SAME_BOTH_GENDERS;const DEX_XATU
  db SAME_BOTH_GENDERS;const DEX_REMORAID 
  db SAME_BOTH_GENDERS;const DEX_OCTILLERY
  db MALE_75_PERCENT;const DEX_SENTRET MR_RIME or was supposed to be, doesn't seem like it :P
db SAME_BOTH_GENDERS;const SIR_FETCHD
db SAME_BOTH_GENDERS;const DEX_QWILFISH
db NO_GENDER;const DEX_DELIBIRD CURSOLA
db MALE_88_PERCENT;Rhydon
db SAME_BOTH_GENDERS;const DEX_DUNSPARCE
db SAME_BOTH_GENDERS;const DEX_GIRAFARIG
db MALE_75_PERCENT;const DEX_RIOLU
db MALE_75_PERCENT;const DEX_LUCARIO
  db MALE_75_PERCENT;const DEX_SUDOWOODO
	db SAME_BOTH_GENDERS ; Poli
	db SAME_BOTH_GENDERS ; Slow
	db SAME_BOTH_GENDERS ; King
	db FEMALE_ONLY ; Bliss
	db MALE_75_PERCENT ; Hera
	db SAME_BOTH_GENDERS ; magmo
	db SAME_BOTH_GENDERS ; elect
	db NO_GENDER ; magnem
	db MALE_88_PERCENT ; rhyp
	db SAME_BOTH_GENDERS ; tangrowth
	db SAME_BOTH_GENDERS ; licky
	db SAME_BOTH_GENDERS ; Eeveelution Espeon
	db SAME_BOTH_GENDERS ; U
	db SAME_BOTH_GENDERS ; G
	db SAME_BOTH_GENDERS ; L
	db SAME_BOTH_GENDERS ; Sylv
	db SAME_BOTH_GENDERS ; Sc
	db SAME_BOTH_GENDERS ; Steelix
	db SAME_BOTH_GENDERS; Exeggutor
	db SAME_BOTH_GENDERS; Charmander
	db SAME_BOTH_GENDERS; Squirtle
		db SAME_BOTH_GENDERS; Bulbasaur
			db SAME_BOTH_GENDERS; Ivysaur
	db SAME_BOTH_GENDERS; Venusaur
	db SAME_BOTH_GENDERS; Charmeleon
	db SAME_BOTH_GENDERS; Wartortle
	db SAME_BOTH_GENDERS; Blastoise
	db SAME_BOTH_GENDERS; Charizard
	db SAME_BOTH_GENDERS ; wobbuffet