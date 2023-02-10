rtsetparams(44100, 8)
set_option("clobber_on")
rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")
load("WAVETABLE")

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

amp = maketable("line", 1000, 0, 0, 1, 1, 26, 1, 27, 0)

ratelo = 0.000004
ratemid = 0.000008
ratehi = 0.00004
rateti = 1

durlo = 0.01
durmid = 0.05
durhi = 0.08
durti = 0.1

freqlo = maketable("line", "nonorm", 200, 0, cpspch(8.085), 1, cpspch(8.088), 2, cpspch(6.118), 8, cpspch(6.118))
freqmid = maketable("line", "nonorm", 200, 0, cpspch(8.09), 1, cpspch(8.09), 2, cpspch(7.00), 4, cpspch(7.00))
freqhi = maketable("line", "nonorm", 200, 0, cpspch(8.095), 1, cpspch(8.092), 2, cpspch(7.002), 4, cpspch(7.002))
freqti = 16 // maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

distance = 1 // maketable("line", "nonorm", 1000, 0,1, 1,-1)
  angle = 0 //maketable("line", "nonorm", 1000, 0,0, 1,360)
radius = 0.3//maketable("line", "nonorm", 1000, 0,0, 1,6)

wave = maketable("wave", 1000, "saw")
sinewave = maketable("wave", 1000, "sine")
env = src_env = maketable("window", 1000, "hanning")

   SGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center
// og
SGRAN2MULTI(inskip, dur, 400 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env, "polar")


amp2 = maketable("line", 1000, 0, 0, 10, 1, 16, 1, 17, 0)
SGRAN2MULTI(dur / 4, dur * 3 / 4, 400 * amp2, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
cpspch(7.068), cpspch(7.07), cpspch(7.072), freqti, 270, distance, radius, wave, env, "polar")

SGRAN2MULTI(dur / 4, dur * 3 / 4, 400 * amp2, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
cpspch(7.098), cpspch(7.10), cpspch(7.12), freqti, 90, distance, radius, wave, env, "polar")