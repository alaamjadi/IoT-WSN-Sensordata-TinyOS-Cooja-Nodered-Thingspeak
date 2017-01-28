#include "Timer.h"
#include "Magh.h"

module MaghC {
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
    dbg("boot","I'm node 3 [Hum Sensor]: Application booted.\n");
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      dbg("radio","[Hum Sensor]: Radio on!\n");
      call MilliTimer.startPeriodic(1000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}

  event void MilliTimer.fired() {
    dbg("role","[Hum Sensor]: start sensing periodically hum value...\n");
    call Read.read();
  }

  event void Read.readDone(error_t result, uint16_t data) {
    dbg("role","[Hum Sensor]: Hum value is \n");

    if (locked) {
      dbg("role","[Hum Sensor]: Can't read the value, Channel is blocked!");
      return;
    }

    else {
    	magh_msg_t* rsm;
    	rsm = (magh_msg_t*)call Packet.getPayload(&packet, sizeof(magh_msg_t));

    	dbg("radio_packet","[Hum Sensor]: Packeting the data");

      if (rsm == NULL) {
        return;
      }

      rsm->data = data;
      rsm->msg_type = 2;
      
      if (call Packet.maxPayloadLength() < sizeof(magh_msg_t)) {
        dbg("radio_packet","[Hum Sensor]: The data is larger than max length");
        return;
      }

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(magh_msg_t)) == SUCCESS) {
        locked = TRUE;
        dbg("radio","[Hum Sensor]: Sending hum value to sink.\n");
      }
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t err) {
    dbg("radio","[Hum Sensor]: Packet sent successfully!");
    if (&packet == bufPtr) {
      locked = FALSE;
      dbg("radio","[Hum Sensor]: Channel is open again");
    }
  } 
}