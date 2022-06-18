# Pokémon EvoYellow

This is a disassembly of Pokémon Yellow with bonus features; Pikachu now evolves, and all pokemon now follow as of version v3. There are also branches with a following [**meowth**][evomeowth] and following [**eevee**][evoeevee] instead of Pikachu for a starter; these get updated less often.
There is also now a minimalist version [**elsewhere**][minyellow], if you wanted JUST following, running, evolving Raichu, boy/girl choice, and 151 mons, you want the minimalist one.
You do have my permission to use this for whatever you like.

IMPORTANT:
Some of the latest patches weren't working. The really old patches (3.3) seem to still be working though.
I have now created a new patch and I believe I found the problem. My computer's memory file re-writing is apparently corrupted. So when I made a minor edit to the latest patch and re-made the file with the same name, the patch went from usable to corrupted. I created a brand new UPS patch with a different name and this one works.


For disassembling, I use a VERY old version of pokeyellow apparently, so one user found success using using an older version of rgbds,  0.2.5.
Another user also manually edited the sound file inclusions as they seemed to cause the compilation mismatch errors with the modern versions. I hope this helps!

At some point, I will try to get access to a more modern computer that isn't a bajillion years old so I can install a more modern version of things like rgbds and make this more widely available. In the meantime, I am incredibly sorry for the inconvenience!



Latest Version:
+ Play as girl or boy
+ Cute Raichu graphics when you evolve Pikachu, Eevee and Meowth instead in those versions.
+ Ride pokemon on a saddle
+ Press B to run
+ Can complete the Pokedex.
+ Optional Level Adjuster Mode, trainers will have their levels matched to your party's, although elite will be slightly higher. In this mode, you can also use surf on water without the move surf as soon as you want, so you can play the game in reverse order and fight Cinnabar first! (Seafoam is a bit of a pain, but you can get through it without Strength. Surf around Snorlax.)
+ Refight gym leaders by talking to the gym guide (or in Celadon's case, the guy right outside the gym) -latest update 3.5 only-
+ Day and night system
+ Over 250 pokemon, many Johto but also new Kanto evolutions have been added. All Eeveelutions available. Put a pokemon in first slot to have it follow you.
+ Legend Dogs roam after special randomized Fearow encounter, Mew roams after enough badges as a very rare encounter.
+ Snag balls have been coded in the latest version 3.5 which can catch the last MON of a trainer. This is intended for use in the Meowth hack or possibly a Colosseum centric style hack with Eevee (you are free to use this as a base if you want for your own hack or steal any of the code).
+ Munchlax and Mantyke babymons can be gotten from daycare if you leave a parent mon there.
+ Charmander is available earlier from a bugcatcher in Viridian.
+ More moves, like Crunch. Custom coding has been added for Sketch, Hidden Power and Mirror Move.
+ Some moves have been tweaked; Wrap no longer traps you forever, nor do you get stuck raging. Roar can switch trainer parties out now (if a little terribly, as it displays the wrong text 'trainer switched mons' for enemies).
+ More types, Dark, Steel, Fairy
+ Slightly different TMs, to reflect the new types.
+ Different kinds of shinies, get Pink, Blue, Black, Orange/red
+ Hold items for Pokemon (very basic, use 'give' from item menu and 'take' from party menu): Berries and type-changing stones (Give moon stone to your meowth to make it part dark type like an Alolan Meowth!)
+ Very basic megas functionality for Charizard, Venusaur, and Blastoise.
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


I apologize for not updating this very actively... It's just that I had most of the features I wanted so there wasn't much impetus, and more advanced features I'd kinda like are of the more tedious variety to implement.

Known bugs: (# - game breaking. ! - somewhat important)
* ! Mud slap can be a bit buggy and sometimes lower accuracy of both parties. Just switch. I might remove it in the future.
* #One person reported a crash after dig, which I haven't been able to replicate.
* # Viewing lots of TMs by clicking 'use' and then canceling can cause crashes. To help avoid the need for this, I have modified TMs to often show their types, except for a couple rare ones.
*If you somehow manage to lose the first battle against ROCKET in the Mart, there's a bit of a lag before you end up back at your house. Just hit a and be patient; you won't have to refight them, either, just go straight to Oak.
*Minor. Mon follow sprites do not match party sprites. This isn't really a bug, I just never made that functionality because it was a pain, and follow sprites have different frames from party sprites anyway.
*Minor. Diglett Cave might be green if you go into it from the same route as Viridian Forest, due to a palette over-ride quick fix for day-night.

resolved:
* Smeargle's Sketch only worked properly if Smeargle was first mon in one test I did, so I'm removing Smeargle and replacing him with Mimikyu. If you desperately want to play him despite the bugs, he's in vers. 3.9.
x* (resolved) there was a spikes activating in cinnabar bug, I don't thiiink any of the saved ipses I had up had it though but the github vers did.
x* (resolved?) The move tutor was buggy for awhile. Now it should be just annoying in a xvery large loop, but not buggy per say.
x* (Resolved) Move deleter suffered from the same type of crash. Now HMs are just normally deletable so you don't need them.
x* should be (resolved): on eevee version (and as far as I could tell, only eevee version) there was a crash due to old man for some reason in Viridian city.
x* Should be (resolved) in version 3.5: there was an issue with using multiple TMs in a row causing crashes, especially Dark Pulse. Side effect of the fix is that you lose your position in the bag after canceling TM use, but that's pretty minor.



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
[minyellow]: https://github.com/longlostsoul/pokeyellow-gen-II
[pokecrystal]: https://github.com/kanzure/pokecrystal
[irc]: https://kiwiirc.com/client/irc.freenode.net/?#pret
# EvoYellow
