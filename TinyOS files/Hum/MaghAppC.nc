#include "Magh.h"

configuration MaghAppC {}
implementation {
  
  components MaghC as App, MainC, ActiveMessageC;
  App.Boot -> MainC.Boot;
  App.RadioControl -> ActiveMessageC;
  
  components new AMSenderC(RADIO_MSG);
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;

  components new TimerMilliC();
  App.MilliTimer -> TimerMilliC;
  
  components new HumSensorC();
  App.Read -> HumSensorC;
}