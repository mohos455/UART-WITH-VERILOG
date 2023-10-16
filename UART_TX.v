`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 04:23:05 PM
// Design Name: 
// Module Name: UART_TX
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


module UART_TX 
    #(parameter D_bits = 8 , S_TICKS = 16)(
    input clk,
    input reset_n,
    input [D_bits-1 : 0] tx_n ,
    input tx_start,
    input tick,
    output TX,
    output reg TX_done_Tick
    );
    
     reg [1:0] state_reg , state_next ;
     reg [3:0] s_reg , s_next ;
     reg [2:0] n_reg , n_next;
     reg [D_bits-1:0] data_reg,data_next;
     reg t_reg , t_next ; 
     localparam IDLE  = 0,
               START = 1,
               DATA  = 2,
               STOP  = 3;
               
     always @(posedge clk , negedge reset_n) begin
            if(!reset_n)
                begin
                 state_reg <= IDLE ;
                n_reg <= 0;
                s_reg <= 0;
                data_reg <= 0;
                t_reg<= 1'b1;
                end
             else
              begin
                state_reg <= state_next;
                n_reg <= n_next;
                s_reg <= s_next;
                data_reg <= data_next ;
                t_reg <= t_next;
            end
         end
         
         always@(*) begin
        TX_done_Tick = 0;
        s_next=s_reg;
        n_next= n_reg;
        data_next =data_reg ;
        t_next = t_reg;
         
         case(state_reg)
         IDLE : begin
                t_next= 1'b1 ;
                if(tx_start)
                    begin
                        s_next = 0;
                        data_next = tx_n;
                        state_next = START ;
                    end
                else
                    state_next = IDLE;
                 
            end
          
         START : begin
            t_next= 1'b0 ;
            if(tick)
                begin
                    if(s_reg == 15 )
                        begin
                            s_next = 0;
                            n_next = 0;
                            state_next = DATA ;
                        end
                    else
                        begin
                            s_next = s_reg +1 ;
                            state_next = START ;
                        end           
                end
               else
                    state_next = START ;
            
         end
         DATA : begin
            t_next = data_reg[0];
            if(tick)
                 begin
                    if(s_reg == 15)
                        begin
                            s_next = 0;
                            data_next = data_reg >>1;
                                if(n_reg == (D_bits -1))
                                    begin
                                        state_next = STOP;
                                    end
                                else
                                    begin
                                        n_next = n_reg +1 ;
                                        state_next = DATA;
                                    end
                        end
                     else
                        begin
                            s_next = s_reg + 1;
                            state_next = DATA;
                        end
                 end
               else
                state_next = DATA;
            
         end
         
         STOP : begin
                 t_next = 1'b1;
                 if(tick)
                  begin
                        if(s_reg == (S_TICKS -1))
                            begin
                                TX_done_Tick = 1'b1;
                                state_next = IDLE;
                                
                            end
                        else
                            begin
                                s_next = s_reg +1;
                                state_next = STOP;
                            end
                        
                  end  
                 else
                    state_next = STOP;
          end      
          
          default : state_next = IDLE;
         endcase
         end
         
   assign TX = t_reg;
endmodule
