#include <stdio.h>
#include <stdlib.h>
#include <ugens.h>
#include <math.h>
#include <algorithm>
#include <PField.h>
#include <Instrument.h>
#include "SGRAN2_NPAN.h"
#include <rt.h>
#include <rtdefs.h>
#include <iostream>
#include <vector>
#include <float.h> 

#define MAXGRAINS 1500

#define TWO_PI       (M_PI * 2.0)
#define PI_OVER_2    (M_PI / 2.0)

//#define DEBUG

SGRAN2_NPAN::SGRAN2_NPAN() : branch(0)
{
	num_speakers = 0;
	prev_angle = -DBL_MAX;
	src_x = DBL_MAX;
	src_y = DBL_MAX;
}



SGRAN2_NPAN::~SGRAN2_NPAN()
{
	if (!configured)
		return;
	for (size_t i = 0; i < grains->size(); i++)
	{
		delete (*grains)[i];
	}
	delete grains;
}


int SGRAN2_NPAN::init(double p[], int n_args)
{
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
	if (rtsetoutput(p[0], p[1], this) == -1)
		return DONT_SCHEDULE;

	

	if (n_args < 20)
		return die("SGRAN2_NPAN", "19 arguments are required");
	else if (n_args > 20)
		return die("SGRAN2_NPAN", "too many arguments");

	if (SGRAN2_NPAN_get_speakers(&num_speakers, speakers, &min_distance) == -1)
      return die("NPAN",
                 "Call NPANspeakers before NPAN to set up speaker locations.");

	if (outputChannels() != num_speakers)
	      return die("SGRAN2_NPAN", "Ouput channels must match number of speakers");
	
	grainEnvLen = 0;
	wavetableLen = 0;
	amp = p[2];

	newGrainCounter = 0;

	// init tables
	wavetable = (double *) getPFieldTable(18, &wavetableLen);
	grainEnv = (double *) getPFieldTable(19, &grainEnvLen);

	if (n_args > 20)
	{
		grainLimit = p[20];
		if (grainLimit > MAXGRAINS)
		{
			rtcmix_advise("STGRAN2", "user provided max grains exceeds limit, lowering to 1500");
			grainLimit = MAXGRAINS;
		}
			
	}
	else
		grainLimit = MAXGRAINS;

	return nSamps();
}



int SGRAN2_NPAN::configure()
{
	// make the needed grains, which have no values yet as they need to be set dynamically
	grains = new std::vector<Grain*>();
	// maybe make the maximum grain value a non-pfield enabled parameter

	for (int i = 0; i < grainLimit; i++)
	{
		grains->push_back(new Grain());
	}

	configured = true;

	return 0;	// IMPORTANT: Return 0 on success, and -1 on failure.
}

double SGRAN2_NPAN::prob(double low,double mid,double high,double tight)
        // Returns a value within a range close to a preferred value
                    // tightness: 0 max away from mid
                     //               1 even distribution
                      //              2+amount closeness to mid
                      //              no negative allowed
{
	double range, num, sign;

	range = (high-mid) > (mid-low) ? high-mid : mid-low;
	do {
	  	if (rrand() > 0.)
			sign = 1.;
		else  sign = -1.;
	  	num = mid + sign*(pow((rrand()+1.)*.5,tight)*range);
	} while(num < low || num > high);
	return(num);
}

// returns the smaller angle
inline double sideangleside_toangle(double sideB, double angleA, double sideA)
{
	return asin(sideB * sin(angleA) / sideA);
}

// returns the missing side
inline double sideangleside_toside(double sideB, double angleA, double sideC)
{
	return sqrt(pow(sideB, 2) + pow(sideC, 2) - 2 * sideB * sideC * cos(angleA));
}

void SGRAN2_NPAN::setgains(Grain* grain)
{
//#ifdef DEBUG
//   rtcmix_advise("NPAN", "----------------------------------------------------------");
//   rtcmix_advise("NPAN", "src: x=%f, y=%f, angle=%g, dist=%g",
//      src_x, src_y, src_angle / TWO_PI * 360.0, src_distance);
//#endif
   const double pi_over_2 = PI_OVER_2;


   // select a point randomly around the circle centered at the pan position
   double offset_dist = (rrand() + 1) * radius / 2;
   double offset_angle = (rrand() + 1) * M_PI * 2; 

   //double offset_dist = 6;
   //double offset_angle = 3;

   // calculate the distance from the center for this point
   //double true_distance = sqrt(pow(src_distance) + pow(offset_dist) - 2 * src_distance * offset_dist * cos(offset_angle));
   double true_distance = sideangleside_toside(src_distance, offset_angle, offset_dist);



   // the angle between this vector and the pan position vector
   double true_angle;
   if (offset_dist < src_distance)
   {
   	// angle2 = asin(offset_dist * sin(offset_angle) / true_distance);
	   true_angle = sideangleside_toangle(offset_dist, offset_angle, true_distance);
   }
   else // finish this!!!
   {
		true_angle = M_PI - sideangleside_toangle(src_distance, offset_angle, true_distance);
   }

   true_angle += src_angle;

   //double true_distance = 4;
   //double true_angle = 1;


   // Minimum distance from listener to source; don't get closer than this.
   if (true_distance < min_distance)
      true_distance = min_distance;

	#ifdef DEBUG
		std::cout << "Base distance : " << src_distance << " , Base angle " << src_angle << " \n";
		std::cout << "Offset distane : " << offset_dist << " , Offset angle " << offset_angle << " \n";
		std::cout << "Grain distance : " << true_distance << ", Grain angle " << true_angle << " \n";
	#endif

   // Speakers are guaranteed to be in ascending angle order, from -PI to PI.
   for (int i = 0; i < num_speakers; i++) {
      const double spk_angle = speakers[i]->angle();
      const double spk_prev_angle = speakers[i]->prevAngle();
      const double spk_next_angle = speakers[i]->nextAngle();

      // Handle angle wraparound for first and last speakers
      double source_angle = true_angle;
      if (i == 0 && true_angle > 0.0)
         source_angle -= TWO_PI;
      else if (i == num_speakers - 1 && true_angle < 0.0)
         source_angle += TWO_PI;

      if (source_angle > spk_prev_angle && source_angle < spk_next_angle) {
         // then this speaker gets some signal

         // Scale difference between src angle and speaker angle so that
         // max range is [0, 1].
         double scale;
         if (source_angle < spk_angle)
            scale = (spk_angle - spk_prev_angle) / pi_over_2;
         else
            scale = (spk_next_angle - spk_angle) / pi_over_2;
         const double diff = fabs(source_angle - spk_angle) / scale;

         // Gain is combination of src angle and distance, rel. to speaker.
         const double distfactor = speakers[i]->distance() / true_distance;

         grain->gains[i] = cos(diff) * distfactor;
		 //std::cout<<"activating channel " << i << "\n";
      }
      else
         grain->gains[i] = 0;

//#ifdef DEBUG
//      rtcmix_advise("NPAN", "speaker[%d]: chan=%d, angle=%g, dist=%g, gain=%.12f",
//             i, speakers[i]->channel(), speakers[i]->angleDegrees(),
//             speakers[i]->distance(), speakers[i]->gain());
//#endif
   }
}

// set new parameters and turn on an idle grain
void SGRAN2_NPAN::resetgrain(Grain* grain)
{
	float freq = cpsmidi((float)prob(midicps(freqLow), midicps(freqMid), midicps(freqHigh), freqTight));
	float grainDurSamps = (float) prob(grainDurLow, grainDurMid, grainDurHigh, grainDurTight) * SR;
	//float panR = (float) prob(panLow, panMid, panHigh, panTight);
	setgains(grain);
	grain->waveSampInc = wavetableLen * freq / SR;
	grain->ampSampInc = ((float)grainEnvLen) / grainDurSamps;
	grain->currTime = 0;
	grain->isplaying = true;
	grain->wavePhase = 0;
	grain->ampPhase = 0;
	//grain->panR = panR;
	//grain->panL = 1 - panR; // separating these in RAM means fewer sample rate calculations
	(*grain).dur = (int)round(grainDurSamps);
	//std::cout<<"sending grain with freq : " << freq << " dur : " << grain->dur << " panR " << panR << "\n";

	
	#ifdef DEBUG
	for (int i = 0; i < num_speakers; i++)
		std::cout << "Grain gain for channel " << i << " = " << grain->gains[i] << " \n";
	#endif
}

void SGRAN2_NPAN::resetgraincounter()
{
	newGrainCounter = (int)round(SR * prob(grainRateVarLow, grainRateVarMid, grainRateVarHigh, grainRateVarTight));
}

// determine the maximum grains we need total.  Needs to be redone using ZE CALCULUS
int SGRAN2_NPAN::calcgrainsrequired()
{
	return ceil(grainDurMid / (grainRateVarMid * grainRate)) + 1;
}


// update pfields
void SGRAN2_NPAN::doupdate()
{
	double p[20];
	update(p, 20);
	amp =(float) p[2];

	grainDurLow = (double)p[7];
	grainDurMid = (double)p[8]; if (grainDurMid < grainDurLow) grainDurMid = grainDurLow;
	grainDurHigh = (double)p[9]; if (grainDurHigh < grainDurMid) grainDurHigh = grainDurMid;
	grainDurTight = (double)p[10];


	grainRateVarLow = (double)p[3];
	grainRateVarMid = (double)p[4]; if (grainRateVarMid < grainRateVarLow) grainRateVarMid = grainRateVarLow;
	grainRateVarHigh = (double)p[5]; if (grainRateVarHigh < grainRateVarMid) grainRateVarHigh = grainRateVarMid;
	grainRateVarTight = (double)p[6];

	freqLow = (double)p[11];
	freqMid = (double)p[12]; if (freqMid < freqLow) freqMid = freqLow;
	freqHigh = (double)p[13]; if (freqHigh < freqMid) freqHigh = freqMid;
	freqTight = (double)p[14];

	if (freqLow < 15.0)
		freqLow = cpspch(freqLow);

	if (freqMid < 15.0)
		freqLow = cpspch(freqLow);

	if (freqHigh < 15.0)
		freqLow = cpspch(freqLow);


	// NPAN STUFF
	double angle = p[15];
      const double dist = p[16];
      if (angle != prev_angle || dist != src_distance) {
         prev_angle = angle;
         angle += 90.0;                               // user -> internal
         angle *= TWO_PI / 360.0;                     // degrees -> radians
         src_angle = atan2(sin(angle), cos(angle));   // normalize to [-PI, PI]
         src_distance = dist;
         src_x = cos(src_angle) * dist;
         src_y = sin(src_angle) * dist;
	  }

	radius = (double)p[17];


	// END NPAN


	//panLow = (double)p[15];
	//panMid = (double)p[16]; if (panMid < panLow) panMid = panLow;
	//panHigh = (double)p[17]; if (panHigh < panMid) panHigh = panMid;
	//panTight = (double)p[18];

	// Ouput amplitude will eventually be adjusted here
	// grainsRequired = calcgrainsrequired();
	// amp /= grainsRequired;

}




int SGRAN2_NPAN::run()
{
	const int outchans = outputChannels();
    
	for (int i = 0; i < framesToRun(); i++) {
		float out[outchans];
		for (size_t k = 0; k < outchans; k++)
			out[k] = 0;

		if (--branch <= 0)
		{
		doupdate();
		branch = getSkip();
		}
		for (size_t j = 0; j < grains->size(); j++)
		{
			Grain* currGrain = (*grains)[j];
			if (currGrain->isplaying)
			{
				if (++(*currGrain).currTime > currGrain->dur)
				{
					currGrain->isplaying = false;
				}
				else
				{
					// should include an interpolation option at some point
					float grainAmp = oscili(1, currGrain->ampSampInc, grainEnv, grainEnvLen, &((*currGrain).ampPhase));
					float grainOut = oscili(grainAmp,currGrain->waveSampInc, wavetable, wavetableLen, &((*currGrain).wavePhase));
					for (int k = 0; k < outchans; k++)
						out[speakers[k]->channel()] += grainOut * currGrain->gains[k];
				}
			}
			// this is not an else statement so a grain can be potentially stopped and restarted on the same frame

			if ((newGrainCounter <= 0) && !currGrain->isplaying)
			{
				resetgraincounter();
				if (newGrainCounter > 0) // we don't allow two grains to be create o
					{resetgrain(currGrain);}
				else
					{newGrainCounter = 1;}

			}
		}

		// if all current grains are occupied, we skip this request for a new grain
		if (newGrainCounter <= 0)
		{
			resetgraincounter();
		}

		for (size_t j = 0; j < outchans; j++)
			out[j] *= amp;
		rtaddout(out);
		newGrainCounter--;
		increment();
	}

	// Return the number of frames we processed.

	return framesToRun();
}


Instrument *makeSGRAN2_NPAN()
{
	SGRAN2_NPAN *inst = new SGRAN2_NPAN();
	inst->set_bus_config("SGRAN2_NPAN");

	return inst;
}

#ifndef EMBEDDED
void rtprofile()
{
	RT_INTRO("SGRAN2_NPAN", makeSGRAN2_NPAN);
}
#endif

