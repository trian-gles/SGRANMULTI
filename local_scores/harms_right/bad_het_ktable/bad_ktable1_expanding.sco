rtsetparams(44100, 8)
set_option("clobber_on")
// rtoutput("sgran2_8chan.wav")
load("../../../libSGRAN2MULTI.so")
load("../../libMULTIVERB.so")
bus_config("SGRAN2MULTI", "aux 0-7 out")
bus_config("MULTIVERB", "aux 0-7 in", "out 0-7")
include ../table_gen/tablegenbad.sco

srand(42)

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
dur = 60

mast_amp = maketable("line", "nonorm", 1000, 0, 0, 1, 1, 20, 1, 21, 0)
dist_coef = 1
shift = 0


freqlo = maketable("line", "nonorm", 200, 0, 435 / 3, 1, 200 / 3)
freqmid = 440 / 3//maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi = maketable("line", "nonorm", 200, 0, 440 / 3, 1, 800)
freqti = maketable("line", "nonorm", 200, 0, 6, 1, 1)

distance = 1// maketable("line", "nonorm", 1000, 0,1, 1,-1)
  

srand(47)


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


	ratelo = irand(0.0004, 0.0008)
	ratemid = ratelo * 10// maketable("line", "nonorm", 200, 0, 0.008, 1, 0.0008)
	ratehi = ratelo * 20// maketable("line", "nonorm", 200, 0, 0.04, 1, 0.004)
	rateti = 1// maketable("line", "nonorm", 200, 0, 8, 1, 0.2)
	durlo = maketable("line", "nonorm", 200, 0, log(trand(2, 10)) / trand(20, 90), 1, log(trand(2, 10)) / trand(20, 90))

	durmid = durlo * 5
	durhi = durlo * 10
	durti = 0.6

    mult = i + 1
	phase = irand(0, 1)
	amp_cycles = irand(7, 9)
    amp_duty = (-1 * (mult - 16)) / 16
	lag = irand(0.5, 0.65)
	// (float cycles, float phase, float duty, float lag, float numpoints)
	amp = make_ktable(amp_cycles, phase, amp_duty, lag, 3000)

	real_freqlo = freqlo * mult + shift
	real_freqmid = freqmid * mult + shift
	real_freqhi = freqhi * mult + shift

	dist_travel = randrange(360 * 10, 360 * 20)
	start_angle = randrange(0, 360)
	if (rand() > 0){
		dist_travel = dist_travel * -1
		start_angle -= dist_travel
	}
		
    angle = maketable("line", "nonorm", 1000, 0,start_angle, 1, start_angle + dist_travel)
    radius = 0.7 // maketable("line", "nonorm", 1000, 0,0, 1,6)
    SGRAN2MULTI(inskip, dur, 4000 * amp * mast_amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    real_freqlo, real_freqmid, real_freqhi, freqti, angle, distance, radius, wave, env, "polar")
}

roomsize = 0.8
predelay = .03
ringdur = 3
damp = 20
dry = 40
wet = 20
   
   
MULTIVERB(0, 0, 120, 0.5, roomsize, predelay, ringdur, damp, dry, wet)
