#include "DATA/TEMP_DATA.h"
 
generic module TempSensorP() {

	provides interface Read<uint16_t> as TempRead;
	
	uses interface Timer<TMilli> as TimerReadTemp;

} implementation {

	uint16_t temp_index = 0;
	uint16_t temp_read_value = 0;

	command error_t TempRead.read(){

		temp_read_value = TEMP_DATA[temp_index];
		temp_index++;
		if(temp_index==TEMP_DATA_SIZE)
			temp_index = 0;

		call TimerReadTemp.startOneShot( 2 );
		return SUCCESS;
	}

	event void TimerReadTemp.fired() {
		signal TempRead.readDone( SUCCESS, temp_read_value );
	}
}