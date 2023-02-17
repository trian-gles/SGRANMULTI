
#include <stdio.h>
#include <stdlib.h>
#include <ugens.h>
#include <math.h>
#include <algorithm>
#include <PField.h>
#include <Instrument.h>
#include "STGRAN2MULTI.h"			  // declarations for this instrument class
#include <rt.h>
#include <rtdefs.h>
#include <iostream>
#include <vector>

#define MAXBUFFER 441000
#define MAXGRAINS 1500

#define TWO_PI       (M_PI * 2.0)
#define PI_OVER_2    (M_PI / 2.0)

//#define DEBUG

AUDIOBUFFER::AUDIOBUFFER(int size): _full(false), _head(0)
{
    _buffer = new std::vector<double>(MAXBUFFER);
	_size = size;
	// size refers to the PREFERRED size
}

AUDIOBUFFER::~AUDIOBUFFER()
{
    delete _buffer;
}

void AUDIOBUFFER::Append(double sample)
{
    (*_buffer)[_head] = sample;
    if (_head == _buffer->size() -1)
		_full = true;
    _head = (_head + 1) % _buffer->size();
}

double AUDIOBUFFER::Get(float index)
{
	while (index < 0)
		index += (float) _buffer->size();
	while (index > _buffer->size())
		index -= (float) _buffer->size();
	int i = (int) index;
	int k = i + 1;
	float frac = index - i;

    return (*_buffer)[i] + ((*_buffer)[k] - (*_buffer)[i]) * frac;
}

int AUDIOBUFFER::GetHead()
{
    return _head;
}

int AUDIOBUFFER::GetSize()
{
    return _size;
}

int AUDIOBUFFER::GetMaxSize()
{
	return _buffer->size();
}

void AUDIOBUFFER::SetSize(int size)
{
	_size = size;
}

bool AUDIOBUFFER::GetFull()
{
    return _full;
}

bool AUDIOBUFFER::CanRun()
{
	return (GetFull() || GetHead() > GetSize());
}

void AUDIOBUFFER::Print()
{
    for (size_t i = 0; i < _buffer->size(); i++)
    {
        std::cout << (*_buffer)[i] << " ,";
    }
    std::cout << "\n";
}

STGRAN2MULTI::STGRAN2MULTI() : branch(0), configured(false)
{
}


// Destruct an instance of this instrument, freeing any memory you've allocated.

STGRAN2MULTI::~STGRAN2MULTI()
{
	//std::cout << " grains used " << grainsUsed << "\n";
	if (!configured)
		return;
	for (size_t i = 0; i < grains->size(); i++)
	{
		delete (*grains)[i];
	}
	delete grains;
	delete buffer;
	delete in;
}



int STGRAN2MULTI::init(double p[], int n_args)
{

	/* Args:
		p0: inskip
		p1: outskip
		p2: dur
		p3: amp
		p4: grainRateVarLow
		p5: grainRateVarMid
		p6: grainRateVarHigh
		p7: grainRateVarTigh
		p8: grainDurLow
		p9: grainDurMid
		p10: grainDurHigh
		p11: grainDurTight
		p12: transLow (cents)
		p13: transMid
		p14: transHigh
		p15: transTight
		p16: angle
		p17: distance
		p18: radius
		p19: grainEnv
		p20: mode "polar" or "xy" (or "cartesian")
		p21: bufferSize=1
		p22: grainLimit=1500
	*/

	if (rtsetinput(p[1], this) == -1)
      		return DONT_SCHEDULE; // no input

	if (rtsetoutput(p[0], p[2], this) == -1)
		return DONT_SCHEDULE;


	if (n_args < 22)
		return die("STGRAN2MULTI", "21 arguments are required");

	else if (n_args > 24)
		return die("STGRAN2MULTI", "too many arguments");

	if (STGRAN2MULTI_get_speakers(&num_speakers, speakers, &min_distance) == -1)
		return die("STGRAN2MULTI", "Call SGRAN2MULTIspeakers before SGRAN2MULTI to set up speaker locations.");

	if (outputChannels() != num_speakers)
	      return die("SGRAN2MULTI", "Ouput channels must match number of speakers");

	if (inputChannels() > 1)
		rtcmix_advise("STGRAN2MULTI", "Only the first input channel will be used");

	_nargs = n_args;

	grainEnvLen = 0;
	amp = p[3];

	if (n_args > 22)
	{
		grainLimit = p[22];
		if (grainLimit > MAXGRAINS)
		{
			rtcmix_advise("STGRAN2MULTI", "user provided max grains exceeds limit, lowering to 1500");
			grainLimit = MAXGRAINS;
		}
			
	}
	else
		grainLimit = MAXGRAINS;


	newGrainCounter = 0;

	// init tables
	grainEnv = (double *) getPFieldTable(19, &grainEnvLen);

	oneover_cpsoct10 = 1.0 / cpsoct(10.0);

	return nSamps();
}

int STGRAN2MULTI::getmode()
{
   const PField &field = getPField(20);
   const char *str = field.stringValue(0);
   if (str == NULL)
      return -1;
   if (strncmp(str, "pol", 3) == 0)
      return PolarMode;
   return CartesianMode;
}


int STGRAN2MULTI::configure()
{
	// make the needed grains, which have no values yet as they need to be set dynamically
	grains = new std::vector<Grain*>();
	// maybe make the maximum grain value a non-pfield enabled parameter
	for (int i = 0; i < grainLimit; i++)
	{
		grains->push_back(new Grain());
	}

	buffer = new AUDIOBUFFER(MAXBUFFER);

	in = new float[RTBUFSAMPS*inputChannels()];

	configured = true;

	return 0;	// IMPORTANT: Return 0 on success, and -1 on failure.
}

double STGRAN2MULTI::prob(double low,double mid,double high,double tight)
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

void STGRAN2MULTI::setgains(Grain* grain)
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

	if (true_distance < 0){
		true_distance *= -1;
		true_angle += TWO_PI;
   }

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
void STGRAN2MULTI::resetgrain(Grain* grain)
{

	if (!buffer->CanRun())
		return;

	float trans = (float)prob(transLow, transMid, transHigh, transTight);
	float increment = cpsoct(10.0 + trans) * oneover_cpsoct10;
	float offset = increment - 1;
	float grainDurSamps = (float) prob(grainDurLow, grainDurMid, grainDurHigh, grainDurTight) * SR;
	int sampOffset = (int) round(abs(grainDurSamps * offset)); // how many total samples the grain will deviate from the normal buffer movement

	if (sampOffset >= buffer->GetMaxSize()) // this grain cannot exist with size of the buffer
	{
		rtcmix_advise("STGRAN2MULTI", "GRAIN IGNORED, TRANSPOSITION OR DURATION TOO EXTREME");
		return;
	}

	else if ((sampOffset >= buffer->GetSize()) && (offset > 0))
	{
		// shift this grain
		grain->currTime = buffer->GetHead() - sampOffset;
	}
	else
	{
		int minShift;
		int maxShift;

		if (offset< 0)
		{
			minShift = sampOffset;
			maxShift = buffer->GetSize();
		}
		else
		{
			minShift = 1;
			maxShift = buffer->GetSize() - sampOffset;
		}

		if (maxShift == minShift)
		{
			//std::cout<<" the shifts messed up... \n";
			return; // There's a better way to handle this that I'll add at some point...
		}
		
		grain->currTime = buffer->GetHead() - (rand() % (maxShift - minShift) + minShift);
		
	}

	
	
	setgains(grain);
	grain->waveSampInc = increment;
	grain->ampSampInc = ((float)grainEnvLen) / grainDurSamps;

	grain->isplaying = true;
	grain->ampPhase = 0;
	grain->endTime = grainDurSamps * increment + grain->currTime;
	//std::cout<<"sending grain with start time : "<< grain->currTime << " first sample : " << buffer->Get(grain->currTime) << "\n";
}

void STGRAN2MULTI::resetgraincounter()
{
	newGrainCounter = (int)round(SR * prob(grainRateVarLow, grainRateVarMid, grainRateVarHigh, grainRateVarTight));
}

// update pfields
void STGRAN2MULTI::doupdate()
{
	double p[22];
	update(p, 22); // this could be fixed to only update necessary p-fields
	amp =(float) p[3];

	grainDurLow = (double)p[8];
	grainDurMid = (double)p[9]; if (grainDurMid < grainDurLow) grainDurMid = grainDurLow;
	grainDurHigh = (double)p[10]; if (grainDurHigh < grainDurMid) grainDurHigh = grainDurMid;
	grainDurTight = (double)p[11];


	grainRateVarLow = (double)p[4];
	grainRateVarMid = (double)p[5]; if (grainRateVarMid < grainRateVarLow) grainRateVarMid = grainRateVarLow;
	grainRateVarHigh = (double)p[6]; if (grainRateVarHigh < grainRateVarMid) grainRateVarHigh = grainRateVarMid;
	grainRateVarTight = (double)p[7];

	transLow = octpch((double)p[12]);
	transMid = octpch((double)p[13]); if (transMid < transLow) transMid = transLow;
	transHigh = octpch((double)p[14]); if (transHigh < transMid) transHigh = transMid;
	transTight = octpch((double)p[15]);


	panLow = (double)p[16];
	panMid = (double)p[17]; if (panMid < panLow) panMid = panLow;
	panHigh = (double)p[18]; if (panHigh < panMid) panHigh = panMid;
	panTight = (double)p[19];

	if (_nargs > 21)
	{
		int bufferSize = (int) floor(SR * p[21]);
		
		if (bufferSize > MAXBUFFER)
		{
			rtcmix_advise("STGRAN2MULTI", "Buffer size capped at 10 seconds at 44.1k sample rate");
			bufferSize = MAXBUFFER;
		}
		buffer->SetSize(bufferSize);
	}

	// NPAN STUFF
	if (mode == PolarMode) {
	  double angle = p[16];
      double dist = p[17];
      if (angle != prev_angle || dist != src_distance) {
		if (dist < 0) {
			dist *= -1;
			angle += 180;
		}
         prev_angle = angle;
         angle += 90.0;                               // user -> internal
         angle *= TWO_PI / 360.0;                     // degrees -> radians
         src_angle = atan2(sin(angle), cos(angle));   // normalize to [-PI, PI]
         src_distance = dist;
         src_x = cos(src_angle) * dist;
         src_y = sin(src_angle) * dist;
	  }
	}
	else {
		
		 const double x = p[16];
         const double y = p[17];
		 if (x != src_x || y != src_y) {
			src_x = x;
			src_y = y;
			src_angle = atan2(src_y, src_x);
			src_distance = sqrt((src_x * src_x) + (src_y * src_y));
		 }
	}


	// END NPAN
	radius = (double)p[18];

}

int STGRAN2MULTI::run()
{	
	// std::cout<<"new control block with grain counter " << newGrainCounter <<"\n";
	const int outchans = outputChannels();
	int samps = framesToRun() * inputChannels();

	rtgetin(in, this, samps);
	//int grainsCurrUsed = 0;
	for (int i = 0; i < samps; i += inputChannels()) {
		// std::cout<<"new sample block with grain counter " << newGrainCounter <<"\n";
		buffer->Append(in[i]); // currently only takes the left input

		float out[outchans];
		for (size_t k = 0; k < outchans; k++)
			out[k] = 0;

		if (--branch <= 0)
		{
			doupdate();
			branch = getSkip();
		}

		out[0] = 0;
		out[1] = 0;

		for (size_t j = 0; j < grains->size(); j++)
		{
			Grain* currGrain = (*grains)[j];

			if (currGrain->isplaying)
			{
				if ((*currGrain).currTime > currGrain->endTime)
				{
					//std::cout<<" stopping grain  \n";
					currGrain->isplaying = false;
				}
				else
				{
					// at some point, make your own interpolation
					float grainAmp = oscil(1, currGrain->ampSampInc, grainEnv, grainEnvLen, &((*currGrain).ampPhase));
					float grainOut = grainAmp * buffer->Get(currGrain->currTime);
					currGrain->currTime += currGrain->waveSampInc;
					//std::cout<<" outputing grain " << grainAmp << "\n";
					for (int k = 0; k < outchans; k++)
						out[speakers[k]->channel()] += grainOut * currGrain->gains[k];
				}
			}
			// this is not an else statement so a grain can be potentially stopped and restarted on the same frame

			if ((newGrainCounter <= 0) && !currGrain->isplaying)
			{
				//std::cout<<" grain counter finished\n";
				resetgraincounter();
				if (newGrainCounter > 0) // we don't allow two grains to be created on the same frame
					{
						//std::cout<<" resetting grain\n";
						resetgrain(currGrain);
					
					}
				else
					{newGrainCounter = 1;
					}

			}
		}

		// if all current grains are occupied, we skip this request for a new grain
		if (newGrainCounter <= 0)
		{
			//std::cout<<" all grains are occupied\n";
			resetgraincounter();
		}

		for (size_t j = 0; j < outchans; j++)
			out[j] *= amp;
		rtaddout(out);
		newGrainCounter--;
		increment();
	}
	return framesToRun();
}


Instrument *makeSTGRAN2MULTI()
{
	STGRAN2MULTI *inst = new STGRAN2MULTI();
	inst->set_bus_config("STGRAN2MULTI");

	return inst;
}


#ifndef EMBEDDED
void rtprofile()
{
	RT_INTRO("STGRAN2MULTI", makeSTGRAN2MULTI);
}
#endif

