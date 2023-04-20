#include <Ougens.h>
#include <vector>
#include "speakers.h"

typedef struct {
	float waveSampInc; 
	float ampSampInc; 
	float currTime; 
	float ampPhase; 
	float endTime;
	bool isplaying;
	double gains[MAX_SPEAKERS];
	} 
Grain;

class AUDIOBUFFER {
public:
    AUDIOBUFFER(int size);
    ~AUDIOBUFFER();
    double Get(float index);
    int GetHead();
    int GetSize();
	void SetSize(int size);
	int GetMaxSize();
    bool GetFull();
	bool CanRun();
    void Append(double samp);
    void Print();

private:
    bool _full;
    int _head;
	int _size;
    std::vector<double>* _buffer;
};

class STGRAN2MULTI : public Instrument {

public:
	STGRAN2MULTI();
	virtual ~STGRAN2MULTI();
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
	int _nargs;
	int branch;

	bool configured;
	AUDIOBUFFER* buffer;
	float* in;

	enum { PolarMode = 0, CartesianMode = 1 };
	double radius;
	int num_speakers;
	int mode;
	double prev_angle, src_angle, src_distance, min_distance, src_x, src_y;
	Speaker *speakers[MAX_SPEAKERS];

	double oneover_cpsoct10;
	double transLow;
	double transMid;
	double transHigh;
	double transTight;

	double grainDurLow;
	double grainDurMid;
	double grainDurHigh;
	double grainDurTight;

	float amp;

	std::vector<Grain*>* grains;
	int grainLimit;
	int newGrainCounter;

	double grainRateVarLow;
	double grainRateVarMid;
	double grainRateVarHigh;
	double grainRateVarTight;

	double* grainEnv;
	int grainEnvLen;
	void doupdate();
};

