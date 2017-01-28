#include "Timer.h"
#include "Magt.h"

module MagtC {
  uses {
    
    interface SplitControl as RadioControl;
    interface Boot;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet;
    interface Read<uint16_t>;
  }
}
implementation {

  message_t packet;

  bool locked = FALSE;
  
  event void Boot.booted() {
    dbg("boot","I'm node 2 [Temp Sensor]: Application booted.\n");
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      dbg("radio","[Temp Sensor]: Radio on!\n");
      call MilliTimer.startPeriodic(1000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}

  event void MilliTimer.fired() {
    dbg("role","[Temp Sensor]: start sensing periodically temp value...\n");
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) {
    dbg("role","[Temp Sensor]: Temp value is \n");

    if (locked) {
      dbg("role","[Temp Sensor]: Can't read the value, Channel is blocked!");
      return;
    }

    else {
    	magt_msg_t* rsm;
    	rsm = (magt_msg_t*)call Packet.getPayload(&packet, sizeof(magt_msg_t));

    	dbg("radio_packet","[Temp Sensor]: Packeting the data");

      if (rsm == NULL) {
        return;
      }

      rsm->data = data;
      rsm->msg_type = 1;
      
      if (call Packet.maxPayloadLength() < sizeof(magt_msg_t)) {
        dbg("radio_packet","[Temp Sensor]: The data is larger than max length");
        return;
      }

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(magt_msg_t)) == SUCCESS) {
        locked = TRUE;
        dbg("radio","[Temp Sensor]: Sending temp value to sink.\n");
      }
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t err) {
    dbg("radio","[Temp Sensor]: Packet sent successfully!");
    if (&packet == bufPtr) {
      locked = FALSE;
      dbg("radio","[Temp Sensor]: Channel is open again");
    }
  }
}