#include <wiringPiSPI.h>
#include <stdio.h>
#include <sys/time.h>

#define SAMPLE_COUNT 3

float med3(float *f) {
    if (f[0] < f[1])
        if (f[1] < f[2]) return f[1]; else if (f[2] < f[0]) return f[0]; else return f[2];
	else
        if (f[2] < f[1]) return f[1]; else if (f[0] < f[2]) return f[0]; else return f[2];
}

void get4chDataFromMCP3204(unsigned int *data) {
	const int CH = 4;
	const unsigned char in[][3] = {
		{0b00000110, 0b00000000, 0b00000000},
		{0b00000110, 0b01000000, 0b00000000},
		{0b00000110, 0b10000000, 0b00000000},
		{0b00000110, 0b11000000, 0b00000000}
	};
	int i, j;
	unsigned int out[CH][SAMPLE_COUNT];
	unsigned char buf[3];

	// GROVE (moisture)
	for (i = SAMPLE_COUNT - 1; i >= 0; --i) {
		for (j = 0; j < sizeof(data[0]); j++) {
			// set input data
			buf[0] = in[j][0]; buf[1] = in[j][1]; buf[2] = in[j][2];

			// send and receive data with spi
			wiringPiSPIDataRW (0, buf, sizeof(buf));

			// convert unit to lux
			out[j][i] = (((buf[1] << 8) + buf[2]) & 0x0FFF);
			printf ("%d %d - %u\n", i, j, out[j][i]);
		}
	}
}

int main() {
	float lux[SAMPLE_COUNT];
	float moisture[SAMPLE_COUNT];
	float lux_med;
	float moisture_med;
	int i;
	float median;

	// setup wiringpi spi
	wiringPiSPISetup(0, 1000000) ;

//	get4chDataFromMCP3204(lux);
//	return 0;

	// njl7502 (lux)
	for (i = SAMPLE_COUNT - 1; i >= 0; --i) {
		unsigned char data[] = {0b00000110, 0b00000000, 0b00000000};

		// send and receive data with spi
		wiringPiSPIDataRW (0, data, sizeof(data));
	
		// convert unit to lux
		lux[i] = (float)(((data[1] << 8) + data[2]) & 0x0FFF) * 1200.0f / 4096.0f;
	}

	// GROVE (moisture)
	for (i = SAMPLE_COUNT - 1; i >= 0; --i) {
		unsigned char data[] = {0b00000110, 0b01000000, 0b00000000};

		// send and receive data with spi
		wiringPiSPIDataRW (0, data, sizeof(data));
	
		// convert unit to lux
		moisture[i] = (float)(((data[1] << 8) + data[2]) & 0x0FFF) * 193.0f / 4096.0f;
	}

#if SAMPLE_COUNT == 3
	lux_med = med3(lux);
	moisture_med = med3(moisture);
#else
# error "implement a function to find the median"
#endif	

	printf("illuminance: %.2f lux\n", lux_med);
	printf("moisture: %.2f %\n", moisture_med);
	
	return 0;
}
