   rtsetparams(44100, 4)
   load("WAVETABLE")
   load("NPAN")

   bus_config("WAVETABLE", "aux 0 out")
   bus_config("NPAN", "aux 0 in", "out 0-3")

   dur = 20
   amp = 4000
   freq = 440

   env = maketable("line", 1000, 0,0, 1,1, 19,1, 20,0)
   WAVETABLE(0, dur, amp*env, freq, 0)

   NPANspeakers("polar",
       45, 1,     // left front
      -45, 1,     // right front
       135, 1,    // left rear
      -135, 1)    // right rear

   dist = 1

   // 3 counter-clockwise trips around circle
   trips = 3
   angle = maketable("curve", "nonorm", 2000000, 0,0, 8, 1,1080000, 2, 1, 1080000)

   NPAN(0, 0, dur, 1, "polar", angle, dist)