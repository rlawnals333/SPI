`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 15:48:59
// Design Name: 
// Module Name: spi_slave
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

// msb 1: write  0: read address 에서 
// ff와 조합회로는 서로 업데이트를 공유할 수는 없지만 그냥 값 사용은 가능
module spi_slave(
        input  logic SCLK,
        input  logic clk,
        input  logic reset,
        input  logic MOSI,
        output logic MISO,
        input logic  CS,
        input logic done,
        output logic start_trigger,
        output logic ready_rw
     ////output logic read_done///

      //   input logic [7:0] rx_data;
        
      //   output logic [:0] fnd_data

    );
      logic [7:0] slave_reg[0:3], slave_next[0:3];
      logic [7:0] DATA_IN;
      logic [7:0] ADDRESS_REG,ADDRESS_NEXT;
      logic [7:0] WDATA_NEXT,WDATA_REG, RDATA;
      logic [3:0] SCLK_COUNT;
      logic [2:0] CYCLE_COUNT;
      logic start_trigger_reg, start_trigger_next;
      logic miso_reg, miso_next;
      typedef enum {IDLE,ADDRESS,DATA_WRITE,DATA_READ} state_e;
      state_e state,state_next;
      logic SCLK_NEXT, SCLK_EDGE;
      logic ready_reg, ready_next;
      logic [2:0] cycle_count, cycle_count_next;

      assign SCLK_EDGE = ~SCLK_NEXT & SCLK;
      assign ready_rw = ready_reg;
      logic RW;
      assign RW = ADDRESS_NEXT[7];
      assign MISO = miso_reg;
      assign start_trigger = start_trigger_reg;

      always_comb begin
         start_trigger_next = 0;
         state_next = state;
         slave_next = slave_reg;
         ready_next = ready_reg;
         cycle_count_next = cycle_count;
         miso_next = miso_reg;
         ADDRESS_NEXT = ADDRESS_REG;
         // WDATA_NEXT = WDATA_REG;
         case(state)
         IDLE: begin
            ready_next = 1'b1;
            if(CS == 0) state_next = ADDRESS;
         end
         ADDRESS: begin
            ready_next = 0;
            if(done) start_trigger_next = 1'b1;
            if(SCLK_COUNT == 8 && done) begin
               ADDRESS_NEXT = DATA_IN;
               if(RW) state_next = DATA_WRITE;
               else   state_next = DATA_READ;
            end
         end
         DATA_WRITE: begin
            if(done && (cycle_count !=4)) begin
               start_trigger_next = 1'b1;
              
            end
            if((SCLK_COUNT == 8) && done && cycle_count != 4) begin
               slave_next[ADDRESS_REG[1:0]] = DATA_IN;
               ADDRESS_NEXT = ADDRESS_REG + 1;
               cycle_count_next = cycle_count + 1;
            end
            if((cycle_count_next == 4) && (done)) begin
               state_next = IDLE;
               cycle_count_next = 0;
            end
            
          
            end

         DATA_READ: begin
            if(SCLK_EDGE) begin
               miso_next = slave_reg[ADDRESS_REG[1:0]][8-SCLK_COUNT];
            end
            if((SCLK_COUNT == 8) && done) begin
               state_next = IDLE;
            end

         end

         endcase
      end


         always_ff@(posedge clk, posedge reset) begin
            if(reset) begin
               state <= IDLE;
               ADDRESS_REG <= 0;
               WDATA_REG <= 0;
               start_trigger_reg <= 0; 
               miso_reg <= 0;
               ready_reg <= 0;
               SCLK_NEXT <= 0;
               cycle_count <= 0;
               for(int i=0; i<4; i++) begin
               slave_reg[i] <= 0;
               end
            end
            else begin
               state <= state_next;
               ready_reg <= ready_next;
               ADDRESS_REG <= ADDRESS_NEXT;
               WDATA_REG <= WDATA_NEXT;
               miso_reg <= miso_next;
               cycle_count <= cycle_count_next;
               start_trigger_reg <= start_trigger_next;
               SCLK_NEXT <= SCLK;
               for(int i=0; i<4; i++) begin
               slave_reg[i] <= slave_next[i];
               end
            end
         end

        always_ff@(posedge SCLK,posedge reset) begin
           if(reset) begin
            DATA_IN <= 0;
            SCLK_COUNT <= 0;
 //          CYCLE_COUNT <=      // ADDRESS_REG <= 0;
               // for(int i=0; i<4; i++) begin
               // slave_reg[i] <= 0;
               // end
           end

           else begin
              if(CS == 0) begin
                  if(SCLK_COUNT == 8) begin
                     SCLK_COUNT <= 1;
                     // if(state == ADDRESS) ADDRESS_REG <= DATA_IN;
                     // if(state == DATA_WRITE) begin
                     //     slave_reg[ADDRESS_REG[6:0]] <= DATA_IN;
                     //     ADDRESS_REG <= ADDRESS_REG + 1; 
                     // end
  //                   if(CYCLE_COUNT == 4) CYCLE_COUNT <= 0; 
   //                  else CYCLE_COUNT <= CYCLE_COUNT + 1;

                     end
                  else begin   
                      SCLK_COUNT <= SCLK_COUNT + 1;
                     //  MISO <= slave_reg[ADDRESS_REG[1:0]][8-SCLK_COUNT]; 
                      DATA_IN <= {DATA_IN[6:0],MOSI}; 
                  end
              end
           end
        end
endmodule


