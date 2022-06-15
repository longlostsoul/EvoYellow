;I thiiiink this was originally done in crystal, so one may want to go through and look at differences as I suspect it won't be a straight transfer over. But would be cool for Eevee version...
;Music_YellowIntro_Ch1::
;	tempo 116
;	volume 7, 7
;	duty 3
;	vibrato 8, 1, 4
;	notetype 12, 11, 2
;	octave 3
;	G# 2
;	endchannel
Music_CipherPeonBattle:
	musicheader 4, 1, Music_CipherPeonBattle_Ch1
	musicheader 1, 2, Music_CipherPeonBattle_Ch2
	musicheader 1, 3, Music_CipherPeonBattle_Ch3
	musicheader 1, 4, Music_CipherPeonBattle_Ch4


Music_CipherPeonBattle_Ch1:
	dutycycle 2
	vibrato $12, $15
	tone $0001
	tempo 128
	notetype $c, $81
	octave 6
	note C_, 2
	octave 5
	note D#, 2
	octave 6
	note D_, 2
	octave 5
	note A#, 2
	octave 6
	note C_, 2
	octave 5
	note D#, 2
	octave 6
	note D_, 2
	octave 5
	note F_, 2
	octave 6
	note C_, 2
	octave 5
	note D#, 2
	octave 6
	note D#, 2
	octave 5
	note G#, 2
	octave 6
	note D_, 2
	octave 5
	note D_, 2
	note B_, 2
	note G_, 2
	octave 6
	note C_, 2
	octave 5
	note D#, 2
	octave 6
	note C_, 2
	octave 5
	note G#, 2
	octave 6
	note D_, 2
	octave 5
	note G_, 2
	octave 6
	note D_, 2
	octave 5
	note B_, 2
	intensity $72
	octave 4
	note C_, 1
	note C_, 1
	note C_, 1
	note C_, 2
	note C_, 2
	note C_, 1
	note C_, 4
	intensity $56
	note C_, 4
	intensity $81
Music_CipherPeonBattle_Ch1_loop_1:
	callchannel Music_CipherPeonBattle_Ch1_branch_1
	loopchannel 2, Music_CipherPeonBattle_Ch1_loop_1
	octave 6
	note C_, 2
	octave 5
	note A_, 2
	octave 6
	note C_, 2
	octave 5
	note F_, 2
	octave 6
	note C_, 2
	octave 5
	note A_, 2
	octave 6
	note C_, 2
	octave 5
	note C_, 2
Music_CipherPeonBattle_Ch1_loop_2:
	callchannel Music_CipherPeonBattle_Ch1_branch_1
	loopchannel 3, Music_CipherPeonBattle_Ch1_loop_2
	octave 6
	note C_, 2
	octave 5
	note A_, 2
	octave 6
	note C_, 2
	octave 5
	note F_, 2
	octave 6
	note C_, 2
	octave 5
	note A_, 2
	octave 6
	note C_, 2
	octave 5
	note C_, 2
	callchannel Music_CipherPeonBattle_Ch1_branch_1
	callchannel Music_CipherPeonBattle_Ch1_branch_2
	note __, 2
	note G#, 2
	octave 6
	note C#, 2
	octave 5
	note F_, 2
	octave 6
	note C#, 2
	octave 5
	note G#, 2
	octave 6
	note C#, 1
	octave 5
	note G#, 1
	note F_, 4
	note B_, 2
	octave 6
	note D_, 2
	octave 5
	note G_, 2
	octave 6
	note D_, 2
	octave 5
	note B_, 2
	octave 6
	note D_, 1
	octave 5
	note B_, 1
	note G_, 2
	callchannel Music_CipherPeonBattle_Ch1_branch_2
	intensity $92
	octave 2
	note F_, 1
	note G_, 1
	note G#, 2
	note G_, 1
	note G#, 1
	note A#, 2
	note G#, 1
	note A#, 1
	octave 3
	note C_, 2
	octave 2
	note B_, 1
	octave 3
	note C_, 1
	note D_, 2
	intensity $a2
	note C_, 1
	note D_, 1
	note D#, 2
	note D_, 1
	note D#, 1
	note F_, 2
	intensity $b2
	note D#, 1
	note F_, 1
	note G_, 2
	note F#, 1
	note G_, 1
	note A_, 6
	dutycycle 1
	intensity $97
	note A_, 8
	intensity $91
	note A_, 1
	note A_, 2
	note A_, 1
	intensity $90
	note A_, 4
	intensity $97
	note A_, 12
	octave 4
	intensity $90
	note C_, 4
	intensity $97
	note C_, 12
	octave 3
	intensity $90
	note B_, 4
	intensity $97
	note B_, 12
	loopchannel 0, Music_CipherPeonBattle_Ch1
	
Music_CipherPeonBattle_Ch1_branch_1:
	octave 6
	note C_, 2
	octave 5
	note G_, 2
	octave 6
	note C_, 2
	octave 5
	note D#, 2
	octave 6
	note C_, 2
	octave 5
	note G_, 2
	octave 6
	note C_, 2
	octave 5
	note C_, 2
	endchannel
	
Music_CipherPeonBattle_Ch1_branch_2:
	note __, 2
	octave 6
	note C_, 2
	note D#, 2
	octave 5
	note G#, 2
	octave 6
	note D#, 2
	note C_, 2
	note D#, 1
	note C_, 1
	octave 5
	note G#, 4
	note A#, 2
	octave 6
	note D_, 2
	octave 5
	note G_, 2
	octave 6
	note D_, 2
	octave 5
	note A#, 2
	octave 6
	note D_, 1
	octave 5
	note A#, 1
	note G_, 2
	endchannel
	
Music_CipherPeonBattle_Ch2:
	dutycycle $3
	vibrato $12, $15
	tone $0001
	notetype $8, $94
	octave 3
	note D#, 2
	note C_, 2
	octave 2
	note G#, 2
	note A#, 2
	octave 3
	note D_, 2
	note F_, 2
	note G_, 2
	note D#, 2
	note C_, 2
	note D_, 2
	note F_, 2
	note A#, 2
	note G#, 2
	note D#, 2
	note C_, 2
	note D#, 2
	note G#, 2
	octave 4
	note C_, 2
	octave 3
	note B_, 2
	note G_, 2
	note D_, 2
	note G_, 2
	note B_, 2
	octave 4
	note D_, 2
	note C_, 2
	octave 3
	note G#, 2
	note D#, 2
	note G#, 2
	octave 4
	note C_, 2
	note D#, 2
	note D_, 2
	octave 3
	note B_, 2
	note G_, 2
	note B_, 2
	octave 4
	note D_, 2
	note F_, 2
	notetype $c, $92
	note G_, 1
	note G_, 1
	note G_, 1
	note G_, 2
	note G_, 2
	note G_, 1
	note G_, 4
	octave 3
	intensity $56
	note G_, 4
	intensity $b4
	octave 3
	note C_, 4
	octave 2
	note G_, 2
	octave 3
	note C_, 4
	intensity $b3
	note D_, 4
	note D#, 4
	note F_, 4
	intensity $b6
	note G_, 8
	note A#, 2
	note A_, 1
	note F_, 1
	note C_, 10
	intensity $b4
	note A_, 4
	intensity $b7
	note G_, 16
	intensity $b4
	octave 3
	note C_, 4
	octave 2
	note G_, 2
	octave 3
	note C_, 4
	intensity $b3
	note D_, 4
	note D#, 4
	note F_, 4
	intensity $b6
	note G_, 8
	note A#, 2
	note A_, 1
	note A#, 1
	octave 4
	note C_, 10
	octave 3
	intensity $b4
	note A_, 4
	intensity $b7
	note G_, 12
	dutycycle 0
	octave 4
	note C_, 2
	note D_, 2
	note D#, 4
	note C_, 2
	octave 3
	note G#, 4
	intensity $b2
	note D#, 2
	note G#, 1
	octave 4
	note C_, 1
	note D#, 2
	intensity $b7
	note D_, 4
	octave 3
	note A#, 2
	note G_, 4
	intensity $b2
	note D_, 2
	note G_, 1
	note A#, 1
	octave 4
	note D_, 2
	octave 3
	intensity $b7
	note F_, 6
	note G#, 6
	octave 4
	note C#, 4
	note C_, 6
	octave 3
	note B_, 6
	octave 4
	note C_, 2
	note D_, 2
	note D#, 4
	note C_, 2
	octave 3
	note G#, 4
	intensity $b2
	note D#, 2
	note G#, 1
	octave 4
	note C_, 1
	note D#, 2
	intensity $b7
	note D_, 4
	octave 3
	note A#, 2
	note G_, 4
	intensity $b2
	note D_, 2
	note G_, 1
	note A#, 1
	octave 4
	note D_, 2
	octave 3
	note F_, 1
	note G_, 1
	note G#, 2
	note G_, 1
	note G#, 1
	note A#, 2
	note G#, 1
	note A#, 1
	octave 4
	note C_, 2
	octave 3
	note B_, 1
	octave 4
	note C_, 1
	note D_, 2
	intensity $c2
	note C_, 1
	note D_, 1
	note D#, 2
	note D_, 1
	note D#, 1
	note F_, 2
	intensity $d2
	note D#, 1
	note F_, 1
	note G_, 2
	note F#, 1
	note G_, 1
	note A_, 2
	intensity $50
	dutycycle 1
	octave 5
	vibrato $12, $24
	note D_, 16
	note D_, 8
	intensity $57
	note D_, 8
	intensity $50
	note G_, 16
	note G_, 8
	intensity $57
	note G_, 8
	loopchannel 0, Music_CipherPeonBattle_Ch2
	
Music_CipherPeonBattle_Ch3:
Music_CipherPeonBattle_Ch3_loop_1:
	notetype $6, $19
	octave 2
	note C_, 3
	note __, 1
	loopchannel 24, Music_CipherPeonBattle_Ch3_loop_1
	note G_, 1
	note __, 1
	note G_, 1
	note __, 1
	note G_, 1
	note __, 1
	note G_, 2
	note __, 2
	note G_, 2
	note __, 2
	note G_, 1
	note __, 1
	note G_, 2
	note __, 14
Music_CipherPeonBattle_Ch3_loop_2:
	note C_, 3
	note __, 1
	loopchannel 16, Music_CipherPeonBattle_Ch3_loop_2
Music_CipherPeonBattle_Ch3_loop_3:
	note F_, 3
	note __, 1
	loopchannel 8, Music_CipherPeonBattle_Ch3_loop_3
Music_CipherPeonBattle_Ch3_loop_4:
	note C_, 3
	note __, 1
	loopchannel 24, Music_CipherPeonBattle_Ch3_loop_4
Music_CipherPeonBattle_Ch3_loop_5:
	note F_, 3
	note __, 1
	loopchannel 8, Music_CipherPeonBattle_Ch3_loop_5
Music_CipherPeonBattle_Ch3_loop_6:
	note C_, 3
	note __, 1
	loopchannel 8, Music_CipherPeonBattle_Ch3_loop_6
	note G#, 11
	note __, 1
	note G#, 7
	note __, 1
	note G#, 3
	note __, 1
	note G#, 3
	note __, 1
	note G#, 3
	note __, 1
	note G_, 11
	note __, 1
	note G_, 7
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note C#, 11
	note __, 1
	note C#, 7
	note __, 1
	note C#, 3
	note __, 1
	note C#, 3
	note __, 1
	note C#, 3
	note __, 1
	note G_, 11
	note __, 1
	note G_, 7
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note G#, 11
	note __, 1
	note G#, 7
	note __, 1
	note G#, 3
	note __, 1
	note G#, 3
	note __, 1
	note G#, 3
	note __, 1
	note G_, 11
	note __, 1
	note G_, 7
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note G_, 3
	note __, 1
	note C#, 6
	note __, 2
	note D#, 6
	note __, 2
	note F_, 6
	note __, 2
	note G_, 6
	note __, 2
	note G#, 3
	note __, 1
	note G#, 3
	note __, 1
	note A#, 3
	note __, 1
	note A#, 3
	note __, 1
	octave 3
	note C_, 3
	note __, 1
	note C_, 3
	note __, 1
	note D_, 3
	note __, 1
	note D_, 4
	octave 1
	note D_, 8
	octave 2
	note D_, 15
	note __, 1
	note D_, 1
	note __, 1
	note D_, 2
	note __, 2
	note D_, 1
	note __, 1
	note D_, 16
	intensity $29
	note D_, 16
	octave 1
	intensity $19
	note G_, 16
	intensity $29
	note G_, 16
	intensity $19
	note G_, 16
	intensity $29
	note G_, 16
	loopchannel 0, Music_CipherPeonBattle_Ch3
	
Music_CipherPeonBattle_Ch4:
	togglenoise $3
	notetype $c
Music_CipherPeonBattle_Ch4_loop_main:
	note B_, 4
	note D_, 4
	note D_, 4
	note D_, 4
	note D_, 4
	note D_, 2
	note C_, 2
	note D#, 4
	note D_, 2
	note C_, 2
	note D_, 4
	note D_, 4
	note D_, 4
	note D_, 4
	note C_, 1
	note C_, 1
	note C_, 1
	note C_, 2
	note C_, 2
	note D#, 1	
	note C_, 8
Music_CipherPeonBattle_Ch4_loop_1:
	callchannel Music_CipherPeonBattle_Ch4_branch_1
	loopchannel 7, Music_CipherPeonBattle_Ch4_loop_1
	note D#, 2
	note C_, 2
	note C#, 2
	note C_, 2
	note C#, 1
	note C#, 1
	note C_, 2
	note C_, 2
	note C_, 2
Music_CipherPeonBattle_Ch4_loop_2:
	note D_, 1
	note C#, 1
	note D_, 1
	note G#, 1
	note C_, 2
	note C#, 1
	note C#, 1
	note D#, 1
	note C_, 2
	note D#, 1
	note C_, 2
	note C#, 1
	note C#, 1
	loopchannel 6, Music_CipherPeonBattle_Ch4_loop_2
Music_CipherPeonBattle_Ch4_loop_3:
	note D#, 2
	note C_, 2
	loopchannel 8, Music_CipherPeonBattle_Ch4_loop_3
Music_CipherPeonBattle_Ch4_loop_4:
	callchannel Music_CipherPeonBattle_Ch4_branch_1
	loopchannel 4, Music_CipherPeonBattle_Ch4_loop_4
	loopchannel 0, Music_CipherPeonBattle_Ch4_loop_main
	
Music_CipherPeonBattle_Ch4_branch_1:
	note D#, 2
	note D#, 2
	note C_, 2
	note C#, 1
	note C#, 1
	note D#, 1
	note C#, 1
	note D#, 2
	note C_, 2
	note C#, 1
	note C#, 1
	endchannel