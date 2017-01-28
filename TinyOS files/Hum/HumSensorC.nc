generic configuration HumSensorC() {

	provides interface Read<uint16_t> as HumRead;

} implementation {

	components MainC;
	components new HumSensorP();
	components new TimerMilliC() as ReadHumTimer;
	
	HumRead = HumSensorP.HumRead;

	HumSensorP.TimerReadHum -> ReadHumTimer;
}