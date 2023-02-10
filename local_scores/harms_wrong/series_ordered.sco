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



ratelo = 0.0004
ratemid = 0.008 // maketable("line", "nonorm", 200, 0, 0.008, 1, 0.0008)
ratehi = 0.04 //maketable("line", "nonorm", 200, 0, 0.04, 1, 0.004)
rateti = 8 // maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.1
durmid = 0.5
durhi = 0.8
durti = 0.1

freqlo = 400 // maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid = 430 //maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi = 440 //maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
freqti = 6 // maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

distance = 1// maketable("line", "nonorm", 1000, 0,1, 1,-1)ß
  




wave = maketable("wave", 1000, "sine")
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
harms = 16

float randrange(float low, float high){
	return abs(rand()) * (high - low) + low;
}

for (i = 0; i < harms; i = i + 1){
    mult = 1

    if (i > 0){
        mult = (i + 1) / i
    }
    amp = maketable("random", 3, 0, 0, 600)
    angle = 360 + round((i - 1) / 2) * 360 / harms
	if (i % 2 == 1) {
		angle *= -1
	}
    radius = 0 // maketable("line", "nonorm", 1000, 0,0, 1,6)
    SGRAN2MULTI(inskip, dur, 1600 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    freqlo * mult, freqmid * mult, freqhi * mult, freqti, angle, distance, radius, wave, env, "polar")
}