rtsetparams(44100, 8)
set_option("clobber_on")
// rtoutput("sgran2_8chan.wav")

// MAKE THIS SCORE MOVE BETWEEN POSITIONS DETERMINED IN ADVANCE BY AN ARRAY

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
dur = 70

mast_amp = maketable("line", "nonorm", 1000, 0, 0, 1, 1, 20, 1, 21, 0)

ratelo = 0.0004
ratemid =0.008 // maketable("line", "nonorm", 200, 0, 0.08, 1, 0.008)
ratehi = 0.04 // maketable("line", "nonorm", 200, 0, 0.4, 1, 0.04)
rateti = 0.3// maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.001
durmid = 0.03
durhi = .1
durti = 0.2

freqlo = maketable("curve", "nonorm", 200, 
0, cpspch(5.00), 0, 3, cpspch(5.00) , 9, 5, cpspch(4.00), -9, 6, cpspch(6.00), 0, 9, cpspch(6.00), 7, 9.5, 200, -7, 10.5, cpspch(5.00), 7, 12, cpspch(5.00))

freqmid = maketable("curve", "nonorm", 200, 
0, cpspch(5.00), 0, 3, cpspch(5.00), 9, 6, cpspch(6.00), 0, 9, cpspch(6.00), 0, 9.5, cpspch(6.00), 0, 11, cpspch(5.00), 0, 12, cpspch(5.00))

freqhi = maketable("curve", "nonorm", 200, 
0, cpspch(5.00), 0, 3, cpspch(5.00), 9, 5, cpspch(8.00), -9, 6, cpspch(6.00), 0, 9, cpspch(6.00), 7, 9.5, 600, -7, 10.5, cpspch(5.00), 7, 12, cpspch(5.00))

freqti = 4 // maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

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
harms = 32

float randrange(float low, float high){
	return abs(rand()) * (high - low) + low;
}



for (i = 0; i < harms; i = i + 1){
    mult = i + 1
	phase = rand() * 360
	amp_cycles = rand() + 2
    ampbase = (maketable("wave3", 1000, amp_cycles, 1, phase) + 1)
	amp = (maketable("wave3", 1000, amp_cycles, 1, phase) + 1)
	steepness = 9

	for (j = 0; j < steepness - 1; j = j + 1){
		amp = mul(amp, ampbase)
	}
	amp = amp / pow(2, steepness)
	print(pow(2, steepness))
    dist_travel = randrange(360 * 10, 360 * 20)
	start_angle = randrange(0, 360)
	if (rand() > 0){
		dist_travel = dist_travel * -1
		start_angle -= dist_travel
	}
		
    angle = maketable("line", "nonorm", 1000, 0,start_angle, 1, start_angle + dist_travel)
    radius = 0.7 // maketable("line", "nonorm", 1000, 0,0, 1,6)
    SGRAN2MULTI(inskip, dur, 1600 * amp * mast_amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    freqlo * mult, freqmid * mult, freqhi * mult, freqti, angle, distance, radius, wave, env, "polar")
}
