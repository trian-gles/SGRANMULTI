rtsetparams(44100, 8)
set_option("clobber_on")
//rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")
load("../libMULTIVERB.so")

bus_config("SGRAN2MULTI", "aux 0-7 out")
bus_config("MULTIVERB", "aux 0-7 in", "out 0-7")
// more variations try metallic to round
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


lowfreq = 50

amp = maketable("line", 1000, 0, 0, 1, 1, 60, 0)

rate = 0.0003

ratelo = 0.001 
ratemid = 0.003//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.004//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 1//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.003
durmid = 0.03
durhi = 0.3
durti = 3
linoct = maketable("line", "nonorm", 2000, 0, 12, 1, 4)
freq = makeconverter(linoct, "cpsoct")

freqlo = freq //maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = freq // maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = freq * 2 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)

float randrange(float low, float high){
	return abs(rand()) * (high - low) + low;
}

distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 0.3//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)

squarewave = maketable("wave", 1000, "square")
tightenv =  maketable("line", "nonorm", 10000, 0,0, 1,1, 20, 0)
hannenv = maketable("window", 10000, "hanning")

SGRAN2MULTIspeakers("polar",
       45, 1,   // front left
      -45, 1,   // front right
       90, 1,   // side left
      -90, 1,   // side right
      135, 1,   // rear left
     -135, 1,   // rear right rear
        0, 1,   // front center
      180, 1)   // rear center

angle = 0
rate = 1
for (i = 0; i < 32; i = i + 1){

	dur = randrange(3, 6)

	start_freq = randrange(11.5, 13)
	linoct = maketable("line", "nonorm", 2000, 0, start_freq, 1, 4)
	freq = makeconverter(linoct, "cpsoct")

	freqlo = freq //maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
	freqmid = freq // maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
	freqhi = freq * 2 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
	freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)

	if (i % 5 == 0)
	{
		rate *= 0.9
	}
	inskip += (rate + 1 * rand())
	angle += 75
	if (i % 2 == 1) {
		SGRAN2MULTI(inskip, dur, 2000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqlo, freqmid, freqhi, freqti, angle, distance, radius, squarewave, tightenv, "polar")
	}
	else {
		direction = 1
		if (rand() < 0) {
			direction = -1
		}
		angletab = maketable("line", "nonorm", 1000, 0, angle, 1, angle + 180 * direction)
		SGRAN2MULTI(inskip, dur, 2000 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqlo, freqmid, freqhi, freqti, angletab, distance, radius, squarewave, tightenv, "polar")
	}
}

roomsize = 0.8
predelay = .03
ringdur = 3
damp = 20
dry = 30
wet = 20
   
   
MULTIVERB(0, 0, 25, 0.3, roomsize, predelay, ringdur, damp, dry, wet)


