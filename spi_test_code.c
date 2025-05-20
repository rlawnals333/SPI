/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "sleep.h"
#include <stdint.h>

typedef struct {
	volatile uint32_t CR; // [1:0] mode {CPOL,CPHA}, [11:4] address, address msb = read/write, [12] start_trigger
	volatile uint32_t SOD; // WDATA
	volatile uint32_t SID; // RDATA
	volatile uint32_t SR; //READY
} SPI_Typedef;
#define BASEADDR 0x44A00000U
#define SPI ((SPI_Typedef*)(BASEADDR))

void write_data(SPI_Typedef* SPIx, uint32_t data);

void start_spi(SPI_Typedef* SPIx, uint32_t rw, uint32_t address, uint32_t mode);

int read_ready(SPI_Typedef* SPIx);

int read_rdata(SPI_Typedef* SPIx);



int main()
{

    init_platform();
    uint32_t temp_rdata;
while(1){
	write_data(SPI, 0x10203040);
	xil_printf("%0x,%0x\n",SPI->SOD,SPI->CR);
	start_spi(SPI, 1, 0, 0);  // 쓰기
	xil_printf("%0x,%0x\n",SPI->SOD,SPI->CR);
//
	while (!read_ready(SPI)){};  // SPI ready 되길 기다림
//
	start_spi(SPI, 0, 1, 0);  // 읽기

	while (!read_ready(SPI)){};  // 읽기도 완료 대기

	temp_rdata = read_rdata(SPI);

    xil_printf("RDATA : %0x\n",temp_rdata);


//    else {xil_printf("nothing\n");}
    usleep(2000000);
}
    return 0;
}

void write_data(SPI_Typedef* SPIx, uint32_t data) {
	SPIx->SOD = data;
	xil_printf("wdata:%0x\n ",SPI->SOD);
}

void start_spi(SPI_Typedef* SPIx, uint32_t rw, uint32_t address, uint32_t mode) {
	SPIx->CR = 0x00001000 + (rw << 11 )+ (address  << 4) + mode; //start trigger
	xil_printf("address:%0x,mode:%0x,rw:%0x, start_trigger 1 \n ",address,mode,rw);
	usleep(10);
	SPIx->CR = 0x00000000;
	xil_printf("start_trigger 0\n");
	usleep(10000);
}

//void start_spi_w(SPI_Typedef* SPIx) {
//	SPIx->CR = 0x00001800;  //start trigger
//	usleep(10);
//	SPIx->CR = 0x00000000;
//	usleep(10000);
//}
//
//void start_spi_r(SPI_Typedef* SPIx) {
//	SPIx->CR = 0x00001000;  //start trigger
//	usleep(10);
//	SPIx->CR = 0x00000000;
//	usleep(10000);
//}


int read_ready(SPI_Typedef* SPIx){
	return SPIx->SR;
}

int read_rdata(SPI_Typedef* SPIx){
	return SPIx->SID;
}

