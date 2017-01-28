#include "Timer.h"
#include "Mags.h"

module MagsC {
  uses {
    
    interface Boot;
    interface SplitControl as SerialControl;
    interface SplitControl as RadioControl;
    interface Receive;
    interface AMSend as SAMSend;
    interface Timer<TMilli> as MilliTimer;
    interface Packet as SPacket;
  }
}
implementation {

  message_t packet;
  bool locked = FALSE;  
  
  task void sendResult();

  task void sendResult(){
  	if (call SAMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(mags_msg_t)) == SUCCESS) {
  		locked = TRUE;
  	}
  }
  
  event void Boot.booted() {
    call SerialControl.start();
    call RadioControl.start();
  }

  event void SerialControl.startDone(error_t err) {}
  event void SerialControl.stopDone(error_t err) {}
  
  event void RadioControl.startDone(error_t err) {
      call MilliTimer.startPeriodic(1000);
  }
  
  event void RadioControl.stopDone(error_t err) {}
  
  event void MilliTimer.fired() {
    post sendResult();
  }

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    
    mag_msg_t* rcm = (mag_msg_t*) payload;

    if (len == sizeof(mag_msg_t) && !locked)
    {

       mags_msg_t* rsm = (mags_msg_t*)call SPacket.getPayload(&packet, sizeof(mags_msg_t));
       if (rsm != NULL) { 
          if (rcm->msg_type == 1){
          rsm->datat = rcm->data;
          }
        
          if (rcm->msg_type == 2){
          rsm->datah = rcm->data;
          }
        }
    }  
      return bufPtr;
      }

  event void SAMSend.sendDone(message_t* bufPtr, error_t err) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
}