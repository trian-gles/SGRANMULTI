rtsetparams(44100, 8)
set_option("clobber_on")
// rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")

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
dur = 40

mast_amp = maketable("line", "nonorm", 1000, 0, 0, 1, 1, 20, 1, 21, 0)



freqlo = 430 / 4// maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid = 440 / 4//maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi = 445 / 4//maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
freqti = 1 // maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

distance = 1// maketable("line", "nonorm", 1000, 0,1, 1,-1)
  

srand(41)


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
	mult = i + 1
	phase = rand() * 360
	rate_cycles = rand() + 2
	ratebase = maketable("wave3", 300, rate_cycles, 1, phase)
	ratelo = (((add(mul(ratebase, ratebase), ratebase)) + 0.25) / 8) + 0.0003
	ratemid = ratelo * 10
	ratehi = ratelo * 20
	rateti = 1// maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

	durlo = 0.3 / (i + 2) // maketable("line", "nonorm", 200, 0, randrange(0.001, 0.1), 1, randrange(0.001, 0.1))
	durmid = durlo * 5
	durhi = durlo * 10
	durti = 0.1

	amp = 800 * mast_amp * 0.02 / durlo
	
    dist_travel = randrange(360 * 10, 360 * 20)
	start_angle = randrange(0, 360)
	if (rand() > 0){
		dist_travel = dist_travel * -1
		start_angle -= dist_travel
	}
		
    angle = maketable("line", "nonorm", 1000, 0,start_angle, 1, start_angle + dist_travel)
    radius = 0.7 // maketable("line", "nonorm", 1000, 0,0, 1,6)
	SGRAN2MULTI(inskip, dur, amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    	freqlo * mult, freqmid * mult, freqhi * mult, freqti, angle, distance, radius, wave, env, "polar")
    
}
