rtsetparams(44100, 8)
set_option("clobber_on")
rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")

        /* NEW Args:
		p0: inskip
		p1: dur
		p2: amp
		p3: grainRateVarLow
		p4: grainRateVarMid
		p5: grainRateVarHigh
		p6: grainRateVarTigh
		p7: grainDurLow
		p8: grainDurMid
		p9: grainDurHigh
		p10: grainDurTight
		p11: freqLow
		p12: freqMid
		p13: freqHigh
		p14: freqTight
		p15: angle
		p16: distance
		p17: radius
		p18: wavetable
		p19: grainEnv
		p20: grainLimit=1500
	*/
inskip = 0
dur = 1
steps = 62

inc = dur * (steps - 1) / steps

lowfreq = 40

amp = maketable("line", 1000, 0, 0, 1, 1, steps-2, 1, steps-1, 0)

rate = 0.0003

ratelo = 0.0001
ratemid = 0.0003//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.0004//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 1//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.003
durmid = 0.03
durhi = 0.3
durti = 3

freq = 50

freqlo = freq//maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = freq * 2// maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = freq * 4 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = 0.2//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)


angle = maketable("line", "nonorm", 10000000, 0,0, 1, 360 * dur * lowfreq)
distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 0//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)

sinewave = maketable("wave", 1000, "sine")
squarewave = maketable("wave", 1000, "square")
triwave = maketable("wave", 1000, "tri")
pulsewave = maketable("wave", 1000, "buzz")
all_waves = {sinewave, squarewave, triwave, pulsewave}
wave_index = 0 

linoct = maketable("line", "nonorm", 2000, 0, 4, 1, 12)
frequp = makeconverter(linoct, "cpsoct")

freqloup = frequp //maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmidup = frequp // maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhiup = frequp * 2 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)

env =  maketable("line", "nonorm", 10000, 0,0, 1,1, 20, 0,1700, 0)

SGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center
for (i = 0; i < 32; i = i + 1){
	if (rand() < 0.3){
		dur = 0.1 + abs(rand() / 4)
	}
	else {
		dur = 1
	}
	inc = dur * (steps - 1) / steps
	freqti *= 0.9
	if (i % 4 == 3) {
		SGRAN2MULTI(inskip, dur, 4000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqloup, freqmidup, freqhiup, freqti, angle, distance, radius, all_waves[wave_index], env, "polar")
	}
	else {
		SGRAN2MULTI(inskip, dur, 4000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqlo, freqmid, freqhi, freqti, angle, distance, radius, all_waves[wave_index], env, "polar")
	}
	
	inskip += inc
	wave_index = (wave_index + 1) % len(all_waves)
}


