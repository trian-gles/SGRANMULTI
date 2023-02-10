//consider making curves for the movement of the larger gesture

rtsetparams(44100, 8)
set_option("clobber_on")
rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")
load("../libMULTIVERB.so")
bus_config("SGRAN2MULTI", "aux 0-7 out")
bus_config("MULTIVERB", "aux 0-7 in", "out 0-7")

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

float randrange(float low, float high){
	return abs(rand()) * (high - low) + low;
}

lowfreq = 50

amp = maketable("curve", 1000, 0, 0, -4, 1, 1, 0, 2, 1)

rate = 0.0003


rateti = 1//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)







distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 0//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)

wave = maketable("wave", 1000, "buzz")
env =  maketable("line", "nonorm", 10000, 0,0, 1,1, 32, 0,1700, 0)

SGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center
srand(22)

inskip_lo = maketable("line", "nonorm", 100, 0, 1, 4, 0.3, 4.1, 1, 4.5, 1, 6, 0.1, 7, 0.1)
inskip_hi = maketable("line", "nonorm", 100, 0, 2, 4, 0.6, 4.1, 1.7, 4.5, 1.7, 6, 0.3, 6, 0.3)
print(randrange(1, 4))
for (i = 0; i < 80; i = i + 1) {
	dur = randrange(0.9, 1.6)
	freq = randrange(40, 60)

	freqlo = freq//maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
	freqmid = maketable("line", "nonorm", 200, 0, freq, 1, freq * 2)
	freqhi = maketable("line", "nonorm", 200, 0, freq, 1, freq * 4)
	freqti = 0.2//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)

	start_angle = randrange(360, 720)
	angle_distance = randrange(-270, 270)

	ratelostart = randrange(0.00001, 0.0001) 
	rateloend = randrange(0.01, 0.004)
	ratelomid = randrange(0.0008, 0.006)
	ratelo = maketable("spline", "nonorm", 1000, 4, 0, ratelostart, 1, ratelomid, 2, rateloend)
	ratemid = ratelo * randrange(2, 6)//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
	ratehi = ratemid * randrange(4, 7)//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)

	durlo = ratelo * 6
	durmid = ratemid * 20
	durhi = ratehi * 50
	durti = 3

	tablelength = tablelen(inskip_lo)

	angle = maketable("line", "nonorm", 1000, 0, start_angle, 1, start_angle + angle_distance)
	SGRAN2MULTI(inskip, dur, 8000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
	freqlo, freqmid, freqhi, freqti, angle, distance, radius, wave, env, "polar")
	inskip += randrange(samptable(inskip_lo, (i / 64) * tablelength), samptable(inskip_hi, (i / 64) * tablelength))

	
}

roomsize = 0.9
predelay = .03
ringdur = 3
damp = 20
dry = 40
wet = 10
   
   
MULTIVERB(0, 0, 120, 0.5, roomsize, predelay, ringdur, damp, dry, wet)
