`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/12 12:36:04
// Design Name: 
// Module Name: axi4_lite_master
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

//multi master 여야 겠네

module axi4_lite_master(
    //global signals
    input logic ACLK,
    input logic ARESETn,
    //Write transaction. Aw channel
    output logic [3:0] AWADDR,
    output logic AWVALID,
    input logic AWREADY,
    //WRITE transaction, Wchannel
    output logic [31:0] WDATA,
    output logic WVALID,
    input logic WREADY,
    //WRITE transaction, Bchannel
    input logic [1:0] BRESP,
    input logic BVALID,
    output logic BREADY,
    //READ transaction, AR channel
    output logic [3:0] ARADDR,
    output logic ARVALID,
    input logic ARREADY,
    //READ transaction, R channel
    input logic [31:0] RDATA, // src destination 관점 
    input logic RVALID,
    output logic RREADY,
    output logic [1:0] RRESP,


    //internal signal 
    input logic transfer,
    output logic ready,
    input logic [3:0] addr,
    input logic [31:0] wdata,
    input logic write,
    output logic [31:0] rdata
      );

      //WRITE TRANSACTION, AW channel transfer
      typedef enum {
        AW_IDLE_S,
        AW_VALID_S
      } aw_state_e;

    typedef enum {
        W_IDLE_S,
        W_VALID_S
      } w_state_e;

    typedef enum {
        B_IDLE_S,
        B_READY_S
      } b_state_e;

//READ TRANSACTION AR channel / Rchannel b는 없음
      typedef enum {
        AR_IDLE_S,
        AR_VALID_S
      } ar_state_e;

    typedef enum {
        R_IDLE_S,
        R_READY_S
    } r_state_e;

      aw_state_e aw_state, aw_state_next;
      w_state_e w_state, w_state_next;
      b_state_e b_state, b_state_next;
      ar_state_e ar_state, ar_state_next;
      r_state_e r_state, r_state_next;

      logic [31:0] r_data_reg,r_data_next;
      logic w_ready, r_ready;

      assign ready = w_ready | r_ready;
      assign rdata = r_data_next;

      always_ff @( posedge ACLK ) begin : blockName
        if(!ARESETn) begin
            aw_state <= AW_IDLE_S;
            w_state <= W_IDLE_S;
            b_state <= B_IDLE_S;
            ar_state <= AR_IDLE_S;
            r_state <= R_IDLE_S;
            r_data_reg <= 0;
        end
        else begin
            aw_state <= aw_state_next;
            w_state <= w_state_next;
            b_state <= b_state_next;
            ar_state <= ar_state_next;
            r_state <= r_state_next;
            r_data_reg <= r_data_next;
        end
      end

      always_comb begin : AWchannel
        aw_state_next = aw_state;
        AWVALID = 0;
        AWADDR = addr; // latch 방지 
        case(aw_state)
        AW_IDLE_S: begin
            AWVALID = 0;
            if(transfer && write) begin
                aw_state_next = AW_VALID_S;
            end
        end
        AW_VALID_S: begin
            AWVALID = 1'b1;
            AWADDR = addr; // instruction 한개 끝날떄까지 유지
            if(AWVALID && AWREADY) begin
                aw_state_next = AW_IDLE_S;
            end
        end
        endcase
      end

       always_comb begin : Wchannel
        w_state_next = w_state;
        WVALID = 0;
        WDATA = wdata; // latch 방지 
        case(w_state)
        W_IDLE_S: begin
            WVALID = 0;
            if(transfer && write) begin
                w_state_next = W_VALID_S;
            end
        end
        W_VALID_S: begin
            WVALID = 1'b1;
            WDATA = wdata; // instruction 한개 끝날떄까지 유지
            if(WVALID && WREADY) begin
                w_state_next = W_IDLE_S;
            end
        end
        endcase
      end

      always_comb begin : Bchannel
      b_state_next = b_state; // l/s 타입 최종 단계 
        BREADY = 0;
        w_ready = 0; // to core 
        case(b_state)
        B_IDLE_S: begin
            BREADY = 0;
            if(WVALID) b_state_next = B_READY_S;
        end
        B_READY_S: begin
            BREADY = 1'b1;
            
            if(BVALID) begin
                b_state_next = B_IDLE_S;
                w_ready = 1'b1;
            end
        end
        endcase
      end

      //R transaction
      
      always_comb begin : ARchannel
        ar_state_next = ar_state;
        ARVALID = 0;
        ARADDR = addr; // latch 방지 
        case(ar_state)
        AR_IDLE_S: begin
            ARVALID = 0;
            if(transfer && ~write) begin
                ar_state_next = AR_VALID_S;
            end
        end
        AR_VALID_S: begin
            ARVALID = 1'b1;
            ARADDR = addr; // instruction 한개 끝날떄까지 유지
            if(ARVALID && ARREADY) begin
                ar_state_next = AR_IDLE_S;
            end
        end
        endcase
      end

       always_comb begin : Rchannel
        r_state_next = r_state;
        RREADY = 0;
        r_data_next = r_data_reg; // latch 방지 
        r_ready = 0;
        RRESP = 0;
        case(r_state)
        R_IDLE_S: begin
            if(RVALID) begin
                r_state_next = R_READY_S;
            end
        end
        R_READY_S: begin
            RREADY = 1'b1;
            RRESP = 0;
            // instruction 한개 끝날떄까지 유지
            if(RVALID && RREADY) begin
                r_data_next = RDATA;
                r_state_next = R_IDLE_S;
                r_ready = 1'b1;
               
            end
        end
        endcase
      end


endmodule
