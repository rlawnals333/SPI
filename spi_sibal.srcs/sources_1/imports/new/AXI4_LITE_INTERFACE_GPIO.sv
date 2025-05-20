`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/13 10:41:15
// Design Name: 
// Module Name: AXI4_LITE_INTERFACE_GPIO
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/13 10:40:12
// Design Name: 
// Module Name: AXI4_LITE_INTERFACE_GPIO
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


module AXI4_LITE_INTERFACE_GPIO(
    input logic ACLK,
    input logic ARESETn,
    //Write transaction. Aw channel
    input logic [3:0] AWADDR,
    input logic AWVALID,
    output logic AWREADY,
    //WRITE transaction, Wchannel
    input logic [31:0] WDATA,
    input logic WVALID,
    output logic WREADY,
    //WRITE transaction, Bchannel
    output logic [1:0] BRESP,
    output logic BVALID,
    input logic BREADY,
    //READ transaction, ARchannel
    input logic ARVALID,
    input logic [3:0] ARADDR,
    output logic ARREADY,
    // READ transcation , Rchannel
    output logic [31:0] RDATA,
    output logic RVALID,
    input logic RREADY,
    input logic [1:0] RRESP

    //GPIO
    // inout logic [7:0] IOPORT
    );
    logic [7:0] SPI_RDATA;
    logic ready_rw;
    logic [31:0] slv_reg0_reg, slv_reg0_next, // CR mode [1:0] address [9:2] 
    slv_reg1_reg, slv_reg1_next, // SOD //wdata
    slv_reg2, //rdata
    slv_reg3; //ready_rw
    // slv_reg4; // ready_rw;
    // slv_reg3; 

    assign slv_reg2 = {{24{1'b0}},SPI_RDATA};
    assign slv_reg3 = {{31{1'b0}},ready_rw};
    typedef enum bit {AW_IDLE_S,AW_READY_S} aw_state_e;
    typedef enum bit {W_IDLE_S,W_READY_S} w_state_e;
    typedef enum bit {B_IDLE_S,B_VALID_S} b_state_e;
    typedef enum bit {AR_IDLE_S,AR_READY_S} ar_state_e;
    typedef enum bit {R_IDLE_S,R_VALID_S} r_state_e;


    aw_state_e aw_state, aw_state_next;
    w_state_e w_state, w_state_next;
    b_state_e b_state, b_state_next;
    ar_state_e ar_state, ar_state_next;
    r_state_e r_state, r_state_next;
    
    
    logic[3:0] aw_addr_next, aw_addr_reg;
    logic[3:0] ar_addr_next, ar_addr_reg;

    always_ff@(posedge  ACLK) begin
        if(!ARESETn) begin
            aw_state <= AW_IDLE_S;
            w_state <= W_IDLE_S;
            b_state <= B_IDLE_S;
            ar_state <= AR_IDLE_S;
            r_state <= R_IDLE_S;
            aw_addr_reg <= 0;
            ar_addr_reg <= 0;
            slv_reg0_reg <= 0;
            slv_reg1_reg <= 0;


        end
        else begin
            aw_state <= aw_state_next;
            w_state <= w_state_next;
            b_state <= b_state_next;
            ar_state <= ar_state_next;
            r_state <= r_state_next;
            aw_addr_reg <= aw_addr_next;
            ar_addr_reg <= ar_addr_next;
            slv_reg0_reg <= slv_reg0_next;
            slv_reg1_reg <= slv_reg1_next;

        end
    end

    always_comb begin : AWchannel
        aw_addr_next = aw_addr_reg;
        aw_state_next = aw_state;
        AWREADY = 0;
        case(aw_state)
        AW_IDLE_S: begin
            if (AWVALID) begin
                aw_state_next = AW_READY_S; //valid값이랑 data같이 들어옴
                aw_addr_next = AWADDR;
            end
        end
        AW_READY_S: begin
            AWREADY = 1'b1;
            if(AWVALID && AWREADY) aw_state_next = AW_IDLE_S;
        end
        endcase
    end

        always_comb begin : Wchannel
        w_state_next = w_state;
        slv_reg0_next = slv_reg0_reg;
        slv_reg1_next = slv_reg1_reg;
        // slv_reg2_next = slv_reg2_reg;
        WREADY = 0;
        case(w_state)
        W_IDLE_S: begin
            if (AWVALID) begin
                w_state_next = W_READY_S; //valid값이랑 data같이 들어옴
            end
        end
        W_READY_S: begin
            WREADY = 1'b1;
            
            if(WVALID) begin
                w_state_next = W_IDLE_S;
                case(aw_addr_reg[3:2])
                0: slv_reg0_next = WDATA;
                1: slv_reg1_next = WDATA;
                // 2: slv_reg2_next = WDATA;/
                // 8: slv_reg0 = WDATA;
                // 12:slv_reg0 = WDATA;
                endcase
             end
        end
        endcase
    end

    always_comb begin : Bchannel
    b_state_next = b_state;
    BVALID = 0;
    BRESP = 0;
    case(b_state)
    B_IDLE_S: begin
        if(WVALID && WREADY) begin //Wchannel 끝날때
            b_state_next = B_VALID_S;
        end
    end
    B_VALID_S: begin
        BVALID = 1'b1;
        BRESP = 0;
        if(BREADY) b_state_next = B_IDLE_S;
    end
    endcase
    end

    always_comb begin : ARchannel
        ARREADY = 0;
        ar_state_next = ar_state;
        ar_addr_next = ar_addr_reg;
        case(ar_state) 
        AR_IDLE_S: begin
            if (ARVALID) ar_state_next = AR_READY_S;
            ar_addr_next = ARADDR;
        end

        AR_READY_S: begin
            ARREADY = 1'b1;
            if(ARVALID && ARREADY) ar_state_next = AR_IDLE_S;
        end
        endcase
    end

    always_comb begin : Rchannel
        r_state_next = r_state;
        RVALID = 0;
        RDATA = 0;
        case(r_state)
        R_IDLE_S: begin
            if(ARVALID && ARREADY) r_state_next = R_VALID_S; // 얘가 보내는 입장 
        end
        R_VALID_S: begin
            RVALID = 1'b1;
            if(RVALID && RREADY) begin
                r_state_next = R_IDLE_S;
                case(ar_addr_reg[3:2])
                0: RDATA = slv_reg0_reg;
                1: RDATA = slv_reg1_reg;
                2: RDATA = slv_reg2;
                3: RDATA = slv_reg3;
                

                // 12:RDATA = slv_reg3;
                endcase
            end
        end
        endcase
    end

top_module_spi u_spi(
    .clk(ACLK),
    .reset(~ARESETn),
    // input logic btn,
    .MODE(slv_reg0_reg[1:0]), //start ,address, {CPOL,CPHA}
    .WDATA({slv_reg0_reg[11:4],slv_reg1_reg}), // msb 8 비트 addr msb:read or write // 나머지 write byte 4개 
    // output logic [3:0] fnd_comm,
    // output logic [7:0] fnd_font,
    .RDATA(SPI_RDATA),
    .start_trigger(slv_reg0_reg[12]),
    .ready_rw(ready_rw)

            );
endmodule

module GPIO_IP(
    output logic [7:0] idata,
    input logic [7:0] odata,
    input logic [7:0] mode, //input or output
    inout logic [7:0] io
    );

    genvar i;
    generate
        for(i=0;i<8;i++) begin
            assign io[i] = (mode[i]) ? odata[i] : 1'bz; //3-state buffer 
            assign idata[i] = (~mode[i]) ? io[i] : 1'bz; //inout이 아니면 걍 끊는거임 
        end
    endgenerate

    // initial에서는 걍 박아도 되는데 generate에서는 assign 
endmodule

