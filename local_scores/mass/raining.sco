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

srand(20)
inskip = 0
dur = 5

lowfreq = 50

amp = maketable("line", 1000, 0, 0, 1, 1, 60, 0)

rate = 0.0003

ratelo = 0.0001 
ratemid = 0.0003//maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
ratehi = 0.0004//maketable("line", "nonorm", 200, 0, 0.04, 1, 0.00004)
rateti = 1//maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.0003
durmid = 0.003
durhi = 0.03
durti = 3
linoct = maketable("line", "nonorm", 2000, 0, 12, 1, 4)
freq = makeconverter(linoct, "cpsoct")

freqlo = freq //maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
freqmid = freq // maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
freqhi = freq * 2 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)



distance = 1 //maketable("line", "nonorm", 1000, 0,5, 1, 1)
radius = 0.5//maketable("line", "nonorm", 1000, 0,5, 4, 0, 8, .1)

squarewave = maketable("wave", 1000, "square")
sinewave = maketable("wave", 1000, "sine")
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
rate = 0.5
for (i = 0; i < 64; i = i + 1){

	linoct = maketable("line", "nonorm", 2000, 0, 11 + rand() * 2, 1, 5 + rand())
	freq = makeconverter(linoct, "cpsoct")

	freqlo = freq //maketable("line", "nonorm", 200, 0, 400, 1, 200,4, 200)
	freqmid = freq // maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600, 4, 600)
	freqhi = freq * 2 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 900, 4, 900)
	freqti = 1//maketable("line", "nonorm", 200, 0, 6, 1, 0.2, 2, 1)

	trueratemid = ratemid + .0001 * rand()

	if (i % 5 == 0)
	{
		rate *= 1.1
	}
	inskip += (rate + 1 * rand())
	if (inskip < 0){
		inskip = 0
	}
	angle += 180 * rand()
	truedur = dur + rand()
	if (i % 2 == 1) {
		SGRAN2MULTI(inskip, truedur, 2000 * amp, ratelo, trueratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqlo, freqmid, freqhi, freqti, angle, distance, radius, squarewave, tightenv, "polar")
	}
	else {
		direction = 1
		if (rand() < 0) {
			direction = -1
		}
		angletab = maketable("line", "nonorm", 1000, 0, angle, 1, angle + 180 * direction)
		SGRAN2MULTI(inskip, truedur, 2000 * amp, ratelo, trueratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
		freqlo, freqmid, freqhi, freqti, angletab, distance, radius, squarewave, tightenv, "polar")
	}

	
}

roomsize = 0.8
predelay = .03
ringdur = 3
damp = 20
dry = 40
wet = 20
   
   
MULTIVERB(0, 0, 120, 0.5, roomsize, predelay, ringdur, damp, dry, wet)


