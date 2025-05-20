`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/12 14:40:20
// Design Name: 
// Module Name: tb_axi
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


module tb_axi();

 
    logic ACLK;
    logic ARESETn;
    //e transaction. Aw channel
    logic [3:0] AWADDR;
    logic AWVALID;
     logic AWREADY;
    //E transaction, W;hannel
    logic [31:0] WDATA;
    logic WVALID;
     logic WREADY;
    //E transaction, B;hannel
     logic [1:0] BRESP;
     logic BVALID;
    logic BREADY;
     //transaction, AR;hannel
    logic ARVALID;
    logic [3:0] ARADDR;
     logic ARREADY;
    //D transcation , ;channel
     logic [31:0] RDATA;
     logic RVALID;
    logic RREADY;
    logic [1:0] RRESP;

    //GPIO
    // wire [7:0] IOPORT; //wire 선언 
    // initial begin
    // for(int i=0; i<8; i++) begin
    // IOPORT[i] = mode[i] ? temp_io[i] : 1'bz; 
    // end
    // end
    logic transfer;
     logic ready;
    logic [3:0] addr;
    logic [31:0] wdata;
    logic write;
     logic [31:0] rdata;
    logic [7:0] mode;
    logic [7:0] temp_io;
    // genvar i;
    // generate
    //     for(i=0; i<8;i++) begin
    // assign IOPORT[i] = (mode[i])? 1'bz : temp_io[i]; //gpio와 반대로 
    //     end
    // endgenerate
axi4_lite_master u_axi_master(.*);
AXI4_LITE_INTERFACE_GPIO u_gpio_slave(.*);

always #5 ACLK = ~ACLK;

initial begin
    ACLK = 0;
    ARESETn = 0;
    #10 ARESETn = 1'b1;

    // @(posedge ACLK);
    // #1; addr =0; wdata = 32'h0000_0_80_0; write = 1'b1; transfer = 1'b1; // 모드 설정 및 주소 
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    @(posedge ACLK);
    #1; addr =4; wdata = 32'h10203040; write = 1'b1; transfer = 1'b1; // 데이타 넣기
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);

    @(posedge ACLK);
    #1; addr =0; wdata = 32'h0000_1_80_0; write = 1'b1; transfer = 1'b1; //주소 및 시작
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);   
    
     @(posedge ACLK);
    #1; addr =0; wdata = 32'h0000_0_00_0; write = 1'b1; transfer = 1'b1; //끄기
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);

    #100000;

     @(posedge ACLK);
    #1; addr =0; wdata = 32'h0000_1_00_0; write = 1'b1; transfer = 1'b1; // 읽기
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);

     @(posedge ACLK);
    #1; addr =0; wdata = 32'h0000_0_00_0; write = 1'b1; transfer = 1'b1; //끄기
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);
    #100000;
     @(posedge ACLK);
    #1; addr =8; wdata = 32'h0000_0_00_0; write = 0; transfer = 1'b1; //끄기
    @(posedge ACLK);
    #1; transfer = 0;
    wait(ready == 1'b1);

    // if(rdata == 1) begin

    // @(posedge ACLK);
    // #1; addr =8; wdata = 32'h10203040; write = 0; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1); //데이터 읽기
    // end

    
    // @(posedge ACLK);
    // #1; addr =4; wdata = 11; write = 1'b1; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    // @(posedge ACLK);
    // #1; addr =8; wdata = 12; write = 1'b1; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);
    
    // @(posedge ACLK);
    // #1; addr =12; wdata = 13; write = 1'b1; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    // @(posedge ACLK);
    // #1; addr =0; wdata = 13; write = 0; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    //     @(posedge ACLK);
    // #1; addr =4; wdata = 13; write = 0; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    //     @(posedge ACLK);
    // #1; addr =8; wdata = 13; write = 0; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);

    //     @(posedge ACLK);
    // #1; addr =12; wdata = 13; write = 0; transfer = 1'b1;
    // @(posedge ACLK);
    // #1; transfer = 0;
    // wait(ready == 1'b1);
    
    #200 $finish;
    
end
endmodule
