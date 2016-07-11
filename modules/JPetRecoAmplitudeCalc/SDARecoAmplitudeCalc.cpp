#include "./SDARecoAmplitudeCalc.h"
#include "../../tools/JPetRecoSignalTools/JPetRecoSignalTools.h"

SDARecoAmplitudeCalc::SDARecoAmplitudeCalc(const char* name, const char* description) 
  : JPetTask(name, description),
    fBadSignals(0),
    fCurrentEventNumber(0)
{}

SDARecoAmplitudeCalc::~SDARecoAmplitudeCalc()
{
}

void SDARecoAmplitudeCalc::init(const JPetTaskInterface::Options& /* opts */)
{
  INFO(
       Form("Starting amplitude calculation")
       );
  fBadSignals =0;
}

void SDARecoAmplitudeCalc::exec()
{
  // first take signal from fEvent
  const JPetRecoSignal& signal = (JPetRecoSignal&)(*getEvent());

  //find the amplitude of the signal
  double amplitude = JPetRecoSignalTools::calculateAmplitude(signal);

  // if something went wrong with finding amplitude, handle the error
  if (amplitude == JPetRecoSignalTools::ERRORS::badAmplitude) {
    WARNING( Form("Something went wrong when calculating charge for event: %d", fCurrentEventNumber) );
    JPetRecoSignalTools::saveBadSignalIntoRootFile(signal, fBadSignals, "badAmplitudes.root");
    fBadSignals++;
    fCurrentEventNumber++; 
    return;
  }



  //to save Reco signal one needs to copy it to non const variable
  JPetRecoSignal signalWithAmplitude = signal;

  //setting offset of signal
  signalWithAmplitude.setAmplitude(amplitude);
  
  //saving singal into output root file
  fWriter->write(signalWithAmplitude);

  // increase event counter
  fCurrentEventNumber++;
}

void SDARecoAmplitudeCalc::terminate()
{
  int fEventNb = fCurrentEventNumber; 
  double goodPercent = (fEventNb-fBadSignals) * 100.0/fEventNb;
  INFO(
       Form("Amplitude calculation complete \nAmount of bad signals: %d \n %f %% of data is good" , fBadSignals, goodPercent) );
}
