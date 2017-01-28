#include "DATA/HUM_DATA.h"
 
generic module HumSensorP() {

	provides interface Read<uint16_t> as HumRead;
	
	uses interface Timer<TMilli> as TimerReadHum;

} implementation {

	uint16_t hum_index = 0;
	uint16_t hum_read_value = 0;

	command error_t HumRead.read(){
		hum_read_value = HUM_DATA[hum_index];
		hum_index++;
		if(hum_index==HUM_DATA_SIZE)
			hum_index = 0;

		call TimerReadHum.startOneShot( 2 );
		return SUCCESS;
	}

	event void TimerReadHum.fired() {
		signal HumRead.readDone( SUCCESS, hum_read_value );
	}
}