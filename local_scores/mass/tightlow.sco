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
dur = 20

lowfreq = 50

amp = maketable("line", 1000, 0, 0, 1, 1, 60, 1, 61, 0)

rate = 0.0003

ratelo = 0.0001
ratemid = 0.0003//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.0004//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 1//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.003
durmid = 0.03
durhi = 0.3
durti = 3

linoct = 7.00
freq = 80

freqlo = 20// maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = 400// maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = 20000 // maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = maketable("curve", "nonorm", 1000, 0, 50, -6, 1, 0.5, 6, 2, 50)


angle = maketable("line", "nonorm", 10000000, 0,0, 1, 360 * dur * lowfreq)
distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 0//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)

wave = maketable("wave", 1000, "square")
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

SGRAN2MULTI(inskip, dur, 6000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env, "polar")

