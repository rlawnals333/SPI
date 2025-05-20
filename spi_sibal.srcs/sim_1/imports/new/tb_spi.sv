`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/17 22:30:47
// Design Name: 
// Module Name: tb_spi
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


module tb_spi();
logic clk,reset;
logic [39:0] WDATA;
logic [7:0] RDATA;
// logic [3:0] fnd_comm;:
// logic [7:0] fnd_font;
logic [1:0] MODE;
logic start_trigger;
top_module_spi dut(.*);
logic ready_rw; 

always #5 clk = ~clk;
 initial begin
    clk=0;reset=1'b1; 
    #10; reset = 0; WDATA = 40'h8010203040; MODE = 0; start_trigger = 0;   
    #100 start_trigger = 1'b1;
    #10 start_trigger = 1'b0; 
    @(posedge ready_rw);
 #10; reset = 0; WDATA = 40'h0010203040; MODE = 0; start_trigger = 0;   
    #100 start_trigger = 1'b1;
    #10 start_trigger = 1'b0; 
    @(posedge ready_rw);


 end           
endmodule
