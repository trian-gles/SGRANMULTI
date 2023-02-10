## About
multichannel per-grain panning of SGRAN2 and STGRAN2.  More documentation coming soon

## Examples
### SGRAN2MULTI
### STGRAN2MULTI




## Usage

Make sure the package.conf points to the appropriate RTcmix makefile.conf before building, then `make`

Both instruments rely on Dr. Helmuth's `prob` function, which takes four floating point parameters: `low`, `mid`, `high` and `tight`.  Calling this function returns a stochastically chosen value based on a distribution centered around `mid` with upper and lower bounds at `low` and `high`.  The `tight` value determines how closely the distribution clusters at `mid`.  `tight` of 1 will be an even distribution, with more than one being closer to the `mid` value, and less than one spreading towards the `low` and `high` bounds.

Every time a new grain spawns, multiple `prob` functions run to generate properties of that grain.  These include the time until the next grain, the duration of this grain, the frequency/transposition of this grain, and the panning of this grain.

SGRAN2MULTI creates grains from a user provided periodic wavefornm.

STGRAN2MULTI works with a provided audio file or realtime audio source.  Grain start points are chosen randomly between the present and "buffer start size" (p20) seconds ago.  High p20 values result in the smearing of short impulses to long lasting clouds.  Extreme transpositions may be ignored so grains don't move "into the future", or go too far into the past.

See [TRANS usage notes](http://rtcmix.org/reference/instruments/TRANS.php#usage_notes) regarding dynamically updating STGRAN2 transposition values.

Both apply a user provided windowing function for each grain.

See the included scorefiles.

### SGRAN2MULTI

Args:  
    - p0: inskip  
    - p1: duration
    - p2: amplitude*  
    - p3-6: rate values (seconds before the next grain grain)* 
    - p7-10: duration values (length of grain in seconds)*
    - p11-14: pitch values (Hz or oct.pc)*
    - p15-18: pan values(0 - 1.0)* 
    - p19: synthesis waveform**  
    - p20: grain amplitude envelope**  
    - p21: maximum concurrent grains [optional; default is 1500]
    
\* may receive a reference to a pfield handle  
\*\* must receive a reference to a pfield maketable handle  


### STGRAN2

Args:  
    - p0: inskip  
    - p1: dur  
    - p2: amp* 
    - p3-6: rate values (seconds before the next grain grain)* 
    - p7-10: duration values (length of grain in seconds)*
    - p11-14: transposition values (oct.pc)*
    - p15-18: pan values(0 - 1.0)*  
    - p19: grain amplitude envelope**
    - p20: size of the buffer used to choose grain start points [optional; default is 1]*
    - p21: maximum concurrent grains [optional; default is 1500]
    
\* may receive a reference to a pfield handle  
\*\* must receive a reference to a pfield maketable handle