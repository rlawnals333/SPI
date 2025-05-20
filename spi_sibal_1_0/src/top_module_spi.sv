`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 16:53:09
// Design Name: 
// Module Name: top_module_spi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module_spi(
    input logic clk,
    input logic reset,
    // input logic btn,
    input logic [1:0] MODE, //{CPOL,CPHA}
    input logic [39:0] WDATA, // msb 8 비트 addr msb:read or write // 나머지 write byte 4개 
    // output logic [3:0] fnd_comm,
    // output logic [7:0] fnd_font,
    input logic start_trigger,
    output logic [7:0] RDATA,
    output logic ready_rw

            );
    
    logic [13:0] fnd_data;
    logic SCLK,MOSI,MISO,done,ready,CS;
    logic [7:0] tx_data;
    logic btn_debo;
    logic w_ready_rw;
    logic start_trigger_slave;
    assign ready_rw = w_ready_rw;
    // logic [1:0] CS; //주소 0~3
    // logic CS_0,CS_1,CS_2,CS_3;

    // fnd_controller fnd(
    //     .clk(clk),
    //     .reset(reset),
    //     .fnd_data(fnd_data),

    //     .fnd_comm(fnd_comm),
    //     .fnd_font(fnd_font)
    // );
    spi_slave slave(
        .SCLK(SCLK),
        .clk(clk),
        .reset(reset),
        .MOSI(MOSI),
        .MISO(MISO),
        .CS(CS),
        .done(done),
        .start_trigger(start_trigger_slave),
        .ready_rw(w_ready_rw)
       

    );

    spi_master master(
        .clk(clk),
        .reset(reset),
        .tx_data(tx_data), // 상위비트부터 ㄱㄱㄱ  
        .start_trigger(start_trigger | start_trigger_slave),
        .WDATA(WDATA),
        // .CPHA(CPHA),
        .MODE(MODE),
        .rx_data(RDATA),
        .MOSI(MOSI),
        .MISO(MISO),
        .done(done),
        .ready(ready),
        .SCLK(SCLK),
        .CS(CS),
        .ready_rw(w_ready_rw)
        // .CS_0(CS_0),
        // .CS_1(CS_1),
        // .CS_2(CS_2),
        // .CS_3(CS_3)

    );
    // cu controlUnit(
    //    .clk(clk),
    //    .reset(reset),
    //    .btn(btn_debo),
    //    .switch(switch),
    //    .done(done),
    // //    .CS_IN()
    // //    .CS(CS),
    //    .start_trigger(start_trigger),
    //    .tx_data(tx_data)
    // );
    // btn_debounce btn_deboun(
    // .clk(clk),
    // .reset(reset),
    // .btn(btn),
    // .btn_debo(btn_debo)
    // );
    


endmodule
