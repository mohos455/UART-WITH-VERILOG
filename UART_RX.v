`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2023 03:45:30 PM
// Design Name: 
// Module Name: UART_RX
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


module UART_RX #(parameter D_bits = 8 , S_TICKS = 16)(
    input clk,
    input reset_n,
    input rx,
    input tick,
    output [ D_bits-1 :0] dataout,
    output reg RX_done
    );
    
    reg [1:0] state_reg , state_next ;
    reg [D_bits-1:0] data_reg,data_next;
    reg [2:0] n_reg , n_next;
    reg [3:0] s_reg , s_next ;

    localparam IDLE  = 0,
               START = 1,
               DATA  = 2,
               STOP  = 3;
   always @(posedge clk , negedge reset_n)
        begin
            if(!reset_n)
            begin
                state_reg <= IDLE ;
                n_reg <= 0;
                s_reg <= 0;
                data_reg <= 0;
            end
            else
            begin
                state_reg <= state_next;
                n_reg <= n_next;
                s_reg <= s_next;
                data_reg <= data_next ;
            end
        end
   always @(*)
        begin
        RX_done = 1'b0;
        s_next=s_reg;
        n_next= n_reg;
        data_next =data_reg ;
        case(state_reg)
            IDLE :begin if (rx)
                    state_next = IDLE;
                   else
                   begin
                    state_next = START;
                    s_next = 0 ;
                   end
                  end
            START:begin
                    if(tick)
                    begin
                    if(s_reg==7)
                        begin
                        s_next = 0 ;
                        n_next=0;
                        state_next = DATA;
                        end 
                    else
                        begin
                        s_next = s_reg+1;
                        state_next = START;
                        end
                  end
                  else
                  state_next = START;
                  end
            DATA : begin
                    if(tick)
                    begin
                    if(s_reg==15)
                        begin
                        s_next= 0 ;
                        data_next = {rx,data_reg[7:1]};
                        if(n_reg== (D_bits-1))
                             state_next = STOP;
                        else
                            begin
                                n_next = n_reg+1;
                                state_next = DATA;
                            end
                        end 
                    else
                        begin
                        s_next = s_reg+1;
                        state_next = DATA;
                        end
                    end
                    else
                        state_next = DATA;
                  end
            STOP:begin 
            if(tick)
            begin
                    if(s_reg== S_TICKS-1)
                        begin
                          RX_done = 1'b1;
                          state_next = IDLE;
                        end
                    else
                        begin
                        s_next= s_reg+1;
                        state_next = STOP;
                        end
             end
             else
                state_next = STOP;
             end
             default : state_next = IDLE;
        endcase
        end
        assign dataout = data_reg;
endmodule
