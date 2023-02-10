rtsetparams(44100, 8)
//set_option("clobber_on")
set_option("osc_inport = 7000")
//rtoutput("sgran2_8chan.wav")
load("./libSGRAN2MULTI.so")

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
dur = 120

amp = maketable("line", 1000, 0, 0, 8, 0.8, 16, 1, 17, 0)

ratelo = 0.0008
ratemid = 0.005//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.009//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 3//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.0005
durmid = 0.8
durhi = 1.5
durti = 1

freqlo = maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 300, 2, 1)

x = makeconnection("osc", "/sgran2", index=0, inmin=-100, inmax=100,
        outmin=-100, outmax=100, dflt=0, lag=10)
y = makeconnection("osc", "/sgran2", index=1, inmin=-100, inmax=100,
        outmin=-100, outmax=100, dflt=0, lag=10)
radius = makeconnection("osc", "/sgran2", index=2, inmin=0, inmax=10,
        outmin=0, outmax=10, dflt=0, lag=70)

wave = maketable("wave", 1000, "sine")
//env =  maketable("line", "nonorm", 10000, 0,0, 1,1, 20, 0.1, 1600, 0.1, 1700, 0)
env = maketable("window", 1000, "hanning")
SGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center

SGRAN2MULTI(inskip, dur, 1000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, x, y, radius, wave, env, "xy")