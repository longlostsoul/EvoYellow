# Pokémon EvoYellow

This is a disassembly of Pokémon Yellow with bonus features; Pikachu now evolves, and all pokemon now follow as of version v3. There are also branches with a following [**meowth**][evomeowth] and following [**eevee**][evoeevee] instead of Pikachu for a starter; these get updated less often.
There is also now a minimalist version [**elsewhere**][minyellow], if you wanted JUST following, running, evolving Raichu, boy/girl choice, and 151 mons, you want the minimalist one.
You do have my permission to use this for whatever you like.

Version version 4:
+ Play as girl or boy
+ Cute Raichu graphics when you evolve Pikachu.
+ Ride pokemon on a saddle
+ Press B to run
+ Can complete the Pokedex.
+ Optional Level Adjuster Mode, trainers will have their levels matched to your party's, although elite will be slightly higher. In this mode, you can also use surf on water without the move surf as soon as you want, so you can play the game in reverse order and fight Cinnabar first! (Seafoam is a bit of a pain, but you can get through it without Strength. Surf around Snorlax.)
+ Day and night system
+ Over 250 pokemon, many Johto but also new Kanto evolutions have been added. All Eeveelutions available.
+ Legend Dogs roam after special randomized Fearow encounter, Mew roams after enough badges as a very rare encounter.
+ Munchlax and Mantyke babymons can be gotten from daycare if you leave a parent mon there.
+ More moves, like Crunch. Custom coding has been added for Sketch, Hidden Power and Mirror Move.
+ Some moves have been tweaked; Wrap no longer traps you forever, nor do you get stuck raging. Roar can switch trainer parties out now (if a little terribly, as it displays the wrong text 'trainer switched mons' for enemies).
+ More types, Dark, Steel, Fairy
+ Slightly different TMs, to reflect the new types.
+ Different kinds of shinies, get Pink, Blue, Black, Orange/red
+ Hold items for Pokemon (very basic, use 'give' from item menu and 'take' from party menu): Berries and type-changing stones (Give moon stone to your meowth to make it part dark type like an Alolan Meowth!) [Working on very basic mega functionality for Charizard, Venusaur, and Blastoise]
+ New Area, Mt. Silver
+ Slight difficulty curve adjustment in normal mode, with larger anime-inspired Teams for Gym Leaders, example: Brock has Vulpix, Misty has Corsola and Togekiss
+ OLDER versions (below 3.3) had type re-adjustments. In the new version, you can choose to adjust types by making your pokemon hold special stones!
+ Uses Dannye's Gen 2 Sprites version of the Yellow disassembly as a base; so, updated sprites. Exception is Yellow's Pikachu sprite; that one I revamped myself.


* To see a list of all Pokémon included, look [**here**](constants/pokemon_constants.asm).
* To see Pokémon skill sets and evolutions, look [**here**](data/evos_moves.asm).
* To see what the TMs/HMs teach, and where to find them, look [**here**](data/tms.asm).
* Move alterations [**here**](data/moves.asm).
* To see pokemon that come out at night [**here**](data/handle_nightmons.asm) and the rest in [**here**](data/wildPokemon)
* Hold items (Keep in mind some were actually renamed) [**here**](engine/items/holditems.asm) and item list [**here**](constants/item_constants.asm)


Known bugs:
* #One person reported a crash after dig, which I haven't been able to replicate.
* Mon follow sprites do not match party sprites. This isn't really a bug, I just never made that functionality because it was a pain, and follow sprites have different frames from party sprites anyway.
* Diglett Cave might be green if you go into it from the same route as Viridian Forest, due to a palette over-ride quick fix for day-night.
* (resolved?) The move tutor was buggy for awhile. Now it should be just annoying in a very large loop, but not buggy per say.
* should be resolved: on eevee version (and as far as I could tell, only eevee version) there was a crash due to old man for some reason in Viridian city.


It builds the following rom:

* Pokemon Yellow (UE) [C][!].gbc  `md5: d9290db87b1f0a23b89f99ee4469e34b`

To set up the repository, see [**INSTALL.md**](INSTALL.md).


## See also

* Disassembly of [**Pokémon Red/Blue**][pokered]
* Disassembly of [**Pokémon Yellow with Gen 2 Sprites**][pokeyellow]
* Disassembly of [**Pokémon Crystal**][pokecrystal]
* irc: **irc.freenode.net** [**#pret**][irc]

[evomeowth]:https://github.com/longlostsoul/EvoYellow/tree/meowth
[evoeevee]:https://github.com/longlostsoul/EvoYellow/tree/eevee2
[pokered]: https://github.com/iimarckus/pokered
[pokeyellow]: https://github.com/dannye/pokeyellow-gen-II
[minyellow]: https://github.com/longlostsoldier/pokeyellow-gen-II
[pokecrystal]: https://github.com/kanzure/pokecrystal
[irc]: https://kiwiirc.com/client/irc.freenode.net/?#pret
# EvoYellow
