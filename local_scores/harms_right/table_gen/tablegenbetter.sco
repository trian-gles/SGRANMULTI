//rtsetparams(44100, 2)
//load("../libSGRAN2.so")

// fix this to allow floating point cycles


handle make_ktable(float cycles, float phase, float duty, float lag, float numpoints){
    single_cycle_points = numpoints / cycles
    base_table = maketable("linebrk", "nonorm", single_cycle_points, (duty * single_cycle_points), 1,  0, 1, 0, ((1-duty) * single_cycle_points + 1))
    final_table = copytable(base_table)
    for (j = 1; j < cycles; j = j+1){
        final_table = modtable(final_table, "concat", base_table)
    }

    remainder = round((j - cycles) * single_cycle_points)
    if (remainder > 1){

        remain_table = maketable("linebrk", "nonorm", remainder, remainder, 0, 1, 0)
        final_table = modtable(final_table, "concat", remain_table)
    }
    
    
    initial_val = samptable(final_table, "nointerp", 0)
    
    lag = single_cycle_points * lag / 2
    filtered_table = makefilter(final_table, "smooth", lag, 0)

    filtered_table = modtable(filtered_table, "shift", phase * single_cycle_points)
    return filtered_table
}

float main(){
    outskip = 0
    dur = 25

    amp = make_ktable(3, 0, .2, 0.65, 1000)

    ratelo = 0.00004
    ratemid = maketable("line", "nonorm", 200, 0, 0.0008, 1, 0.00008)
    ratehi = maketable("line", "nonorm", 200, 0, 0.004, 1, 0.0004)
    rateti = maketable("line", "nonorm", 200, 0, 8, 1, 0.2)

    durlo = 0.1
    durmid = 0.5
    durhi = 0.8
    durti = 0.1

    freqlo = maketable("line", "nonorm", 200, 0, 400, 1, 200)
    freqmid = maketable("line", "nonorm", 200, 0, 430, 1, 350, 2, 600)
    freqhi = maketable("line", "nonorm", 200, 0, 440, 1, 460, 2, 800)
    freqti = maketable("line", "nonorm", 200, 0, 6, 1, 0.2)

    panlo = 0
    panmid = maketable("line", "nonorm", 200, 0, 0.1, 1, 0.1, 2, 0.5)
    panhi = maketable("line", "nonorm", 200, 0, 0.2, 1, 0.5, 2, 1)
    panti = 0.4

    wave = maketable("wave", 1000, "square")
    env = src_env = maketable("window", 1000, "hanning")

    SGRAN2(outskip, dur, 800 * amp, ratelo, ratemid, ratehi, rateti, durlo, durmid, durhi, durti, 
    freqlo, freqmid, freqhi, freqti, panlo, panmid, panhi, panti, wave, env)

    return 0
}

