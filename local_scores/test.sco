

 rtsetparams(44100, 1)
load("WAVETABLE")
linoct = maketable("line", "nonorm", 2000, 0, 5, 1, 8)
freq = makeconverter(linoct, "cpsoct")
// this will make 278.0 hz sine wave tone for 3.4 seconds
WAVETABLE(0, 3.4, 10000, freq)