rtsetparams(44100, 8, 4096)
set_option("clobber_on")
// rtoutput("sgran2_8chan.wav")
load("../../libSGRAN2MULTI.so")
load("../libMULTIVERB.so")
bus_config("SGRAN2MULTI", "aux 0-7 out")
bus_config("MULTIVERB", "aux 0-7 in", "out 0-7")

srand(40)

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
dur = 30

dist_coef = 1
shift = 0

dist_coef_end = 1.1
shift_end = -100
center_pitch_start = 45
center_pitch_end = 44
bandwidth = 0.01

mast_amp = maketable("line", "nonorm", 1000, 0, 0, 1, 1, 20, 1, 21, 0)

ratelo = 0.0004
ratemid = maketable("line", "nonorm", 200, 0, 0.008, 1, 0.0008)
ratehi = maketable("line", "nonorm", 200, 0, 0.04, 1, 0.004)
rateti = maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

durlo = 0.1
durmid = 0.5
durhi = 0.8
durti = 0.1

freqlo_start = cpsmidi(center_pitch_start * (1 - bandwidth))// maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid_start = cpsmidi(center_pitch_start)//maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi_start = cpsmidi(center_pitch_start * (1 + bandwidth))//maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
freqti = 6 // maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

freqlo_end = cpsmidi(center_pitch_end * (1 - bandwidth))// maketable("line", "nonorm", 200, 0, 400, 1, 200)
freqmid_end = cpsmidi(center_pitch_end)//maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
freqhi_end = cpsmidi(center_pitch_end * (1 + bandwidth))//maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)

distance = 1// maketable("line", "nonorm", 1000, 0,1, 1,-1)
  




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
	amp_cycles = rand() + 4
    ampbase = (maketable("wave3", 1000, amp_cycles, 1, phase) + 1)
	amp = (maketable("wave3", 1000, amp_cycles, 1, phase) + 1)
	steepness = 9

	for (j = 0; j < steepness - 1; j = j + 1){
		amp = mul(amp, ampbase)
	}
	amp = 1
	print(pow(2, steepness))
    dist_travel = randrange(360 * 10, 360 * 20)
	start_angle = randrange(0, 360)
	if (rand() > 0){
		dist_travel = dist_travel * -1
		start_angle -= dist_travel
	}


	real_freqlo_start = pow(freqlo_start * mult, dist_coef) + shift
	real_freqmid_start = pow(freqmid_start * mult, dist_coef) + shift
	real_freqhi_start = pow(freqhi_start * mult, dist_coef) + shift

	real_freqlo_end = pow(freqlo_end * mult, dist_coef_end) + shift_end
	real_freqmid_end = pow(freqmid_end * mult, dist_coef_end) + shift_end
	real_freqhi_end = pow(freqhi_end * mult, dist_coef_end) + shift_end

	real_freqlo = maketable("line", "nonorm", 1000, 0, real_freqlo_start, 1, real_freqlo_end)
	real_freqmid = maketable("line", "nonorm", 1000, 0, real_freqmid_start, 1, real_freqmid_end)
	real_freqhi = maketable("line", "nonorm", 1000, 0, real_freqhi_start, 1, real_freqhi_end)
		
    angle = maketable("line", "nonorm", 1000, 0,start_angle, 1, start_angle + dist_travel)
    radius = 0.7 // maketable("line", "nonorm", 1000, 0,0, 1,6)
    SGRAN2MULTI(inskip, dur, 800 * amp * mast_amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    real_freqlo, real_freqmid, real_freqhi, freqti, angle, distance, radius, wave, env, "polar")
}

roomsize = 0.8
predelay = .03
ringdur = 3
damp = 20
dry = 40
wet = 20
   
   
MULTIVERB(0, 0, 30, 0.5, roomsize, predelay, ringdur, damp, dry, wet)