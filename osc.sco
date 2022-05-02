rtsetparams(44100, 4)
set_option("clobber_on")
set_option("osc_inport = 7000")
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
dur = 120

amp = maketable("line", 1000, 0, 0, 8, 0.8, 16, 1, 17, 0)

ratelo = 0.00008
ratemid = 0.0005//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.002//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 100//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.0005
durmid = 0.005
durhi = 0.8
durti = 3

freqlo = maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)

angle = makeconnection("osc", "/sgran2", index=0, inmin=0, inmax=360,
        outmin=0, outmax=360, dflt=0, lag=70)
distance = makeconnection("osc", "/sgran2", index=1, inmin=0, inmax=10,
        outmin=0, outmax=10, dflt=0, lag=70)
radius = makeconnection("osc", "/sgran2", index=2, inmin=0, inmax=10,
        outmin=0, outmax=10, dflt=0, lag=70)

wave = maketable("wave", 1000, "square")
env =  maketable("line", "nonorm", 10000, 0,0, 1,1, 20, 0.1, 1600, 0.1, 1700, 0)

SGRAN2_NPANspeakers("polar",
       45, 1,     // left front
      -45, 1,     // right front
       135, 1,    // left rear
      -135, 1)    // right rear

SGRAN2_NPAN(inskip, dur, 6000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env)