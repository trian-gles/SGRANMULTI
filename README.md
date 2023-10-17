#SGRANMULTI


## About
Multichannel per-grain panning of SGRAN2 and STGRAN2 with help from John Gibson's NPAN code


## Usage

Make sure the package.conf points to the appropriate RTcmix makefile.conf before building, then `make`

Both instruments rely on Dr. Helmuth's `prob` function, which takes four floating point parameters: `low`, `mid`, `high` and `tight`.  Calling this function returns a stochastically chosen value based on a distribution centered around `mid` with upper and lower bounds at `low` and `high`.  The `tight` value determines how closely the distribution clusters at `mid`.  `tight` of 1 will be an even distribution, with more than one being closer to the `mid` value, and less than one spreading towards the `low` and `high` bounds.

Every time a new grain spawns, multiple `prob` functions run to generate properties of that grain.  These include the time until the next grain, the duration of this grain, the frequency/transposition of this grain, and the panning of this grain.

Instead of `prob` controlled panning, the multichannel variant of this instrument takes as arguments a position in space, and a radius in which it will randomly place grains via a uniform distribution.

SGRAN2MULTI creates grains from a user provided periodic wavefornm.

STGRAN2MULTI works with a provided audio file or realtime audio source.  Grain start points are chosen randomly between the present and "buffer start size" (p20) seconds ago.  High p20 values result in the smearing of short impulses to long lasting clouds.  Extreme transpositions may be ignored so grains don't move "into the future", or go too far into the past.

See [TRANS usage notes](http://rtcmix.org/reference/instruments/TRANS.php#usage_notes) regarding dynamically updating STGRAN2 transposition values.

See [NPAN usage notes](http://rtcmix.org/reference/instruments/NPAN.php) regarding NPAN functionality.

Both apply a user provided windowing function for each grain.

See the included scorefiles.

### SGRAN2speakers/STGRAN2speakers
Must be called to position speakers prior to calling the instrument itself
(taken directly from NPAN documentation)

Args :
   - p0 = mode ("polar" or "xy" (or "cartesian"))
  
   - p1, p2, ... pN-1, pN 
      - starting with p1, the next N pfields are pairs specifying the locations of the virtual speakers, using angle/distance coordinates (for "polar" mode) or x-location/y-location (for "xy" or "cartesian" mode).  Distances are assumed to be in feet.  Up to 16 speakers may be set.

### SGRAN2MULTI

Args:  

- p0: inskip
- p1: duration
- p2: amplitude*  
- p3-6: rate values (seconds before the next grain grain)* 
- p7-10: duration values (length of grain in seconds)*
- p11-14: pitch values (Hz or oct.pc)*
- p15: pan angle*
- p16: pan distance*
- p17: pan radius*
- p18: synthesis waveform**  
- p19: grain amplitude envelope**  
- p20: maximum concurrent grains [optional; default is 1500]
    
\* may receive a reference to a pfield handle  
\*\* must receive a reference to a pfield maketable handle storing a wavetable or envelope


### STGRAN2MULTI

Args:  

- p0: inskip  
- p1: outskip
- p2: dur  
- p3: amp* 
- p4-7: rate values (seconds before the next grain grain)* 
- p8-11: duration values (length of grain in seconds)*
- p12-15: transposition values (oct.pc)*
- p16: pan angle*
- p17: pan distance*
- p18: pan radius*
- p19: grain amplitude envelope**
- p20: size of the buffer used to choose grain start points [optional; default is 1]*
- p21: maximum concurrent grains [optional; default is 1500]
    
\* may receive a reference to a pfield handle  
\*\* must receive a reference to a pfield maketable handle storing an envelope
