#include <wiringPiSPI.h>
#include <stdio.h>
#include <sys/time.h>

#define SAMPLE_COUNT 3
#define CH 4

float med3(unsigned int *d) {
    if (d[0] < d[1])
        if (d[1] < d[2]) return d[1]; else if (d[2] < d[0]) return d[0]; else return d[2];
	else
        if (d[2] < d[1]) return d[1]; else if (d[0] < d[2]) return d[0]; else return d[2];
}

void getDataFromMCP3204(unsigned int *data) {
	const unsigned char in[][3] = {
		{0b00000110, 0b00000000, 0b00000000},
		{0b00000110, 0b01000000, 0b00000000},
		{0b00000110, 0b10000000, 0b00000000},
		{0b00000110, 0b11000000, 0b00000000}
	};
	int i, j;
	unsigned int out[CH][SAMPLE_COUNT];
	unsigned char buf[3];

	// setup wiringpi spi
	wiringPiSPISetup(0, 1000000) ;

	// get adc value
	for (i = SAMPLE_COUNT - 1; i >= 0; --i) {
		for (j = 0; j < CH; j++) {
			// set input data
			buf[0] = in[j][0]; buf[1] = in[j][1]; buf[2] = in[j][2];

			// send and receive data with spi
			wiringPiSPIDataRW (0, buf, sizeof(buf));

			// convert to integer
			out[j][i] = (((buf[1] << 8) + buf[2]) & 0x0FFF);
		}
	}

	for (j = 0; j < CH; j++) {
		data[j] = med3(out[j]);
	}
}

void calcUnit(unsigned int *adc_val, float *data) {
	float illuminance, moisture, celsius, humidity;

	// illuminance (lux)
	illuminance = (float)adc_val[0] * 1200.0f / 4096.0f;

	// moisture (%)
	moisture = (float)adc_val[1] * 193.0f / 4096.0f;

	// celsius
	celsius = (((float)adc_val[2] * 3.3f * 1000.0f / 4096.0f) - 424.0f) / 6.25f;
	
	// humidity
#if 0
	{
		float v = adc_val[3] / 4096.0f * 3.3;
		float r = 7.5*(3.3 / v - 1);
		humidity = 30 - 20 * (float)log10((double)r);
	}
#endif

	printf("illuminance: %.2f lux\n", illuminance);
	printf("moisture: %.2f %\n", moisture);
	printf("celsius: %.2f %\n", celsius);
	printf("celsius: %.2f %\n", celsius);
#if 0
	printf("humidity: %.2f %\n", humidity);
#endif
}

int main() {
	unsigned int adc_val[CH];
	float data[CH];

	getDataFromMCP3204(adc_val);
	calcUnit(adc_val, data);

	return 0;
}
