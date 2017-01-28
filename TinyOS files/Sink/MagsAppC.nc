#include "Mags.h"

configuration MagsAppC {}
implementation {

  components MagsC as App, MainC, ActiveMessageC;
  App.Boot -> MainC.Boot;
  App.RadioControl -> ActiveMessageC;

  components SerialActiveMessageC;
  App.SerialControl -> SerialActiveMessageC;
  
  components new SerialAMSenderC(SERIAL_MSG);
  App.SAMSend -> SerialAMSenderC;
  App.SPacket -> SerialAMSenderC;

  components new AMReceiverC(RADIO_MSG);
  App.Receive -> AMReceiverC;

  components new TimerMilliC();
  App.MilliTimer -> TimerMilliC;  
}