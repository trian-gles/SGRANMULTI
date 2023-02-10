#include <Ougens.h>
#include <vector>
#include "speakers.h"

typedef struct {
	float waveSampInc; 
	float ampSampInc; 
	float wavePhase; 
	float ampPhase; 
	int dur;
	int currTime; 
	bool isplaying;
	double gains[MAX_SPEAKERS];
	} Grain;


class SGRAN2MULTI : public Instrument {

public:
	SGRAN2MULTI();
	virtual ~SGRAN2MULTI();
	virtual int init(double *, int);
	virtual int configure();
	virtual int run();
	void addgrain();
	double prob(double low,double mid,double high,double tight);
	void resetgrain(Grain* grain);
	void resetgraincounter();
	int calcgrainsrequired();
	int getmode();

	void setgains(Grain* grain);
	inline double anglesideangle(double angle1, double side, double angle2);
	inline double sideangleside(double side1, double angle, double side2);

private:
	enum { PolarMode = 0, CartesianMode = 1 };

	bool configured;
	int branch;

	double radius;

	int num_speakers;
	int mode;
	double prev_angle, src_angle, src_distance, min_distance, src_x, src_y;
	Speaker *speakers[MAX_SPEAKERS];

	double freqLow;
	double freqMid;
	double freqHigh;
	double freqTight;

	double grainDurLow;
	double grainDurMid;
	double grainDurHigh;
	double grainDurTight;

	double panLow;
	double panMid;
	double panHigh;
	double panTight;

	float amp;

	std::vector<Grain*>* grains;
	int grainLimit;
	int newGrainCounter;

	double grainRateVarLow;
	double grainRateVarMid;
	double grainRateVarHigh;
	double grainRateVarTight;

	double* wavetable;
	int wavetableLen;
	double* grainEnv;
	int grainEnvLen;
	float grainRate;
	void doupdate();
};

