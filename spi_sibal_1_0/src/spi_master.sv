`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 15:21:14
// Design Name: 
// Module Name: spi_master
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


module spi_master( // tx data도 늘린다면? 
        input logic clk,
        input logic reset,
        input logic [7:0] tx_data, // 상위비트부터 ㄱㄱㄱ  
        input logic start_trigger,
        input logic [1:0] MODE,
        output logic [7:0] rx_data,
        output logic MOSI,
        input logic MISO,
        input logic [39:0] WDATA,
        input logic ready_rw,
        // input logic CPOL,
        // input logic CPHA,
        // input logic MISO_1,
        // input logic MISO_2,
        // input logic MISO_3,
        // input logic MISO_4,
        // input logic MISO_5,
        // input logic MISO_6,
        // input logic MISO_7,

        output logic done,
        output logic ready,
        output logic SCLK,
        output logic CS
        // output logic CS_0,
        // output logic CS_1,
        // output logic CS_2,
        // output logic CS_3
        // output logic CS_4,
        // output logic CS_5,
        // output logic CS_6,
        // output logic CS_7

    );
//send 하나 만들고 그때 반전 

    typedef enum {
        IDLE,CP0,CP1,DELAY
    } state_e;
    //delay 만들고 반주기, count 49일때 SCLK 반전 => 됨
    // CPO일때는 SCLK 그대로 이다가 49 되면 반전 이니까 delay state에서 반전주면됨 마지막에

    state_e state, state_next;
    logic sclk_reg, sclk_next;
    logic CPOL, CPHA;
    logic [5:0] sclk_count_reg, sclk_count_next;
    logic [2:0] cycle_reg, cycle_next;
    logic [39:0] temp_tx_reg, temp_tx_next;
    logic ready_reg, ready_next;
    logic [7:0] rx_data_reg, rx_data_next;
    logic cs_reg, cs_next;
    logic [5:0] total_cycle_reg, total_cycle_next;
    // logic [3:0] CS_SEL;
    // logic MISO;
    assign rx_data = rx_data_reg;
    assign ready = ready_reg;
    assign SCLK = sclk_reg;
    assign CS   = cs_next;
    assign CPOL = MODE[1];
    assign CPHA = MODE[0];

    // assign CS_0 = (CS_SEL[0])? cs_reg : 1'b1;
    // assign CS_1 = (CS_SEL[1])? cs_reg : 1'b1;
    // assign CS_2 = (CS_SEL[2])? cs_reg : 1'b1;
    // assign CS_3 = (CS_SEL[3])? cs_reg : 1'b1;
    // assign CS_4 = CS_SEL[4] & cs_reg;
    // assign CS_5 = CS_SEL[5] & cs_reg;
    // assign CS_6 = CS_SEL[6] & cs_reg;
    // assign CS_7 = CS_SEL[7] & cs_reg; // 원하는 SLAV만 구동 


    

    assign MOSI = temp_tx_reg[39 - (total_cycle_reg)];

    always_ff @( posedge clk ) begin 
        if(reset) begin
            state <= IDLE;
            sclk_reg <= 0;
            cycle_reg <= 0;
            temp_tx_reg <=0;
            ready_reg <= 0;
            sclk_count_reg <= 0;
            rx_data_reg <= 0;
            cs_reg <= 0;
            total_cycle_reg <= 0;
        end
        else begin
            state <= state_next;
            sclk_reg <= sclk_next;
            cycle_reg <= cycle_next;
            temp_tx_reg <= temp_tx_next;
            ready_reg <= ready_next;
            sclk_count_reg <= sclk_count_next;
            rx_data_reg <= rx_data_next;
            cs_reg <= cs_next;
            total_cycle_reg <= total_cycle_next;
        end
        
    end

    always_comb begin 
        temp_tx_next = temp_tx_reg;
        state_next = state;
        sclk_next = sclk_reg;
        cycle_next = cycle_reg;
        ready_next = ready_reg;
        sclk_count_next = sclk_count_reg;
        rx_data_next = rx_data_reg;
        cs_next = cs_reg;
        done = 0;
        total_cycle_next = total_cycle_reg;

        if(ready_rw) total_cycle_next = 0;
        case(state)
        IDLE: begin
            temp_tx_next = 8'bz;
            ready_next = 1'b1;
            if(CPOL) sclk_next =1'b1; else sclk_next = 0;
            cycle_next = 0;
            cs_next = 1'b1;

            if(start_trigger) begin
                if(CPHA) state_next = DELAY; else state_next = CP0;
                temp_tx_next = WDATA;  //latching
                ready_next = 0;
                cs_next = 0;
            end 

        end

        DELAY: begin
            if(sclk_count_reg == 49) begin
                state_next = CP0;
                sclk_next = ~sclk_reg;
                sclk_count_next = 0;
            end
            else begin
                sclk_count_next = sclk_count_reg + 1;
            end
        end

        CP0: begin
            if(sclk_count_reg == 49) begin
                state_next = CP1;
                sclk_count_next = 0;
                sclk_next = ~sclk_reg;
            end

            else begin
                sclk_count_next = sclk_count_reg + 1;
               
            end
        end

        CP1: begin
            
            if(sclk_count_reg == 49) begin
                rx_data_next = {rx_data_reg[6:0],MISO}; //ff 형태로 넣기 위해 reg_next
                if(cycle_reg == 7) begin
                    state_next = IDLE;
                    total_cycle_next = total_cycle_reg + 1;
                    cycle_next = 0;
                    sclk_count_next=0;
                    done = 1'b1; //한틱
                end
                else begin
                    cycle_next = cycle_reg + 1;
                    total_cycle_next = total_cycle_reg + 1;
                    state_next = CP0;
                    sclk_next = ~sclk_reg;
                    sclk_count_next = 0;
                end
            end
            else begin
                sclk_count_next = sclk_count_reg + 1;
            end
        end
        endcase
    end
//  decoder u_decoder (
//     .CS(CS),
//     .CS_SEL(CS_SEL)

// );

//  mux u_mux (
//     .CS(CS),

//     .MISO_0(MISO_0),
//     .MISO_1(MISO_1),
//     .MISO_2(MISO_2),
//     .MISO_3(MISO_3),
//     .MISO_4(MISO_4),
//     .MISO_5(MISO_5),
//     .MISO_6(MISO_6),
//     .MISO_7(MISO_7),

//     .MISO(MISO)
// );
endmodule

//decodr / mux

module decoder (
    input logic [1:0] CS,
    output logic [3:0] CS_SEL

);

    always_comb begin
        CS_SEL = 0;
        case(CS)
        0: CS_SEL = 4'b0001;
        1: CS_SEL = 4'b0010;
        2: CS_SEL = 4'b0100;
        3: CS_SEL = 4'b1000;
        // 4: CS_SEL = 8'b00010000;
        // 5: CS_SEL = 8'b00100000;
        // 6: CS_SEL = 8'b01000000;
        // 7: CS_SEL = 8'b10000000;
        endcase
    end
endmodule

module mux (
    input logic [2:0] CS,

    input logic MISO_0,
    input logic MISO_1,
    input logic MISO_2,
    input logic MISO_3,
    input logic MISO_4,
    input logic MISO_5,
    input logic MISO_6,
    input logic MISO_7,

    output logic MISO
);
    always_comb begin
    case(CS)
        0: MISO = MISO_0;
        1: MISO = MISO_1;
        2: MISO = MISO_2;
        3: MISO = MISO_3;
        4: MISO = MISO_4;
        5: MISO = MISO_5;
        6: MISO = MISO_6;
        7: MISO = MISO_7;
    endcase
    end
endmodule
