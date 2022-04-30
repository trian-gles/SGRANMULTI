rtsetparams(44100, 8)
rtoutput("sgran2_8chan.wav")
load("./libSGRAN2_NPAN.so")

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
dur = 25

amp = maketable("line", 1000, 0, 0, 8, 0.8, 16, 1, 17, 0)

ratelo = 0.00004
ratemid = maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = maketable("line", "nonorm", 200, 0, 0.004, 1, 0.0004)
rateti = maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.1
durmid = 0.5
durhi = 0.8
durti = 0.1

freqlo = maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid = maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi = maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
freqti = maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

angle = maketable("line", "nonorm", 1000, 0,0, 1,360)
distance = 1
radius = 6

wave = maketable("wave", 1000, "square")
env = src_env = maketable("window", 1000, "hanning")

SGRAN2_NPANspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1) 

SGRAN2_NPAN(inskip, dur, 200 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env)


