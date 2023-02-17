rtsetparams(44100, 8)
set_option("clobber_on")
rtinput("whistle-1-norm.wav")
rtoutput("sgran2_8chan.wav")
load("./libSTGRAN2MULTI.so")

        /* NEW Args:
		p0: inskip
		p1: outskip
		p2: dur
		p3: amp
		p4: grainRateVarLow
		p5: grainRateVarMid
		p6: grainRateVarHigh
		p7: grainRateVarTigh
		p8: grainDurLow
		p9: grainDurMid
		p10: grainDurHigh
		p11: grainDurTight
		p12: transLow (cents)
		p13: transMid
		p14: transHigh
		p15: transTight
		p16: angle
		p17: distance
		p18: radius
		p19: grainEnv
		p20: mode "polar" or "xy" (or "cartesian")
		p21: bufferSize=1
		p22: grainLimit=1500
	*/
inskip = 0
outskip = 0
dur = 10

amp = maketable("line", 1000, 0, 0, 8, 0.8, 16, 1, 17, 0)

ratelo = 0.0004
ratemid = 0.001
ratehi = .004
rateti = 3 

durlo = maketable("line", "nonorm", 1000, 0, 0.02, 1, 0.08)
durmid = maketable("line", "nonorm", 1000, 0, 0.08, 1, 0.4)
durhi = maketable("line", "nonorm", 1000, 0, 0.1, 1, 0.8)
durti = 0.6

translo = -1.00
transmid = 0
transhi = 1.00
transtight = maketable("line", "nonorm", 1000, 0, 2, 1, 0.1)

angle = maketable("line", "nonorm", 1000, 0, 0, 1, 720) + 180
distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 4//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)


env =  maketable("line", "nonorm", 10000, 0,0, 1,1, 20, 0.1, 1600, 0.1, 1700, 0)

STGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center

STGRAN2MULTI(inskip, outskip, dur,  0.5 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
translo, transmid, transhi, transtight, angle, distance, radius, env, "polar", 1)


