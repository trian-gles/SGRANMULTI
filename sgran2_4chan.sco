rtsetparams(44100, 4)
set_option("clobber_on")
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

durlo = 0.01
durmid = 0.5
durhi = 0.8
durti = 0.6

freqlo = maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid = maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi = maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
freqti = maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

angle = 0// maketable("line", "nonorm", 1000, 0,0, 1,-360)
distance = 1
radius = 0// maketable("line", "nonorm", 1000, 0,1, 1,0)

wave = maketable("wave", 1000, "sine")
env = src_env = maketable("window", 1000, "hanning")

SGRAN2_NPANspeakers("polar",
       45, 1,     // left front
      -45, 1,     // right front
       135, 1,    // left rear
      -135, 1)    // right rear

SGRAN2_NPAN(inskip, dur, 800 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env)


